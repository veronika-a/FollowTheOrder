import Foundation

class NetworkService: NetworkDataProvider {
  
  private let baseURL = "http://yerkee.com/api"
  private let decoder = JSONDecoder()
  
  init() {
    decoder.dateDecodingStrategy = .custom({ decoder in
      let container = try decoder.singleValueContainer()
      let dateStr = try container.decode(String.self)
      guard let date = self.commonFormatter.date(from: dateStr) else { throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Cannot decode date string \(dateStr)") }
      return date
    })
  }
  
  private var commonFormatter: ISO8601DateFormatter = {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
    return dateFormatter
  }()
  
  func getCompanyInfo(completion: @escaping (Result<Fortune?, CallError>) -> Void) {
    self.requestGet(urlString: "\(baseURL)/fortune", completion: completion)
  }
  
  private func requestGet<T: Decodable>(urlString: String, completion: @escaping (Result<T?, CallError>) -> Void) {
    guard let url = URL(string: urlString) else { return }
    var urlRequest = URLRequest(url: url)
    let requestHeaders: [String: String] = [ "Content-Type": "application/json; charset=utf-8" ]
    urlRequest.httpMethod = "GET"
    urlRequest.allHTTPHeaderFields = requestHeaders
    let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
      DispatchQueue.main.async {
        if let error = error {
          if let error = error as NSError?,
             error.domain == NSURLErrorDomain &&
              error.code == NSURLErrorNotConnectedToInternet {
            completion(.failure(.networkError("Please check your internet connection or try again later")))
          } else {
            completion(.failure(.unknownError(error)))
          }
        }
        guard let data = data else {
          completion(.failure(.unknownWithoutError))
          return
        }
        if let httpResponse = response as? HTTPURLResponse {
          switch httpResponse.statusCode {
          case 200..<300:
            self?.decodeJson(type: T.self, from: data) { (result) in
              switch result {
              case .success(let decode):
                guard let decode = decode else { return }
                completion(.success(decode))
              case .failure(let error):
                completion(.failure(error))
                print(error)
              }
            }
          default:
            break
          }
        }
      }
    }
    task.resume()
  }
  
  private func decodeJson<T: Decodable>(type: T.Type, from: Data?, completion: (Result<T?, CallError>) -> Void) {
    guard let data = from else { return }
    do {
      let object = try decoder.decode(type.self, from: data)
      completion(.success(object))
    } catch let jsonError {
      completion(.failure(.jsonError(jsonError)))
    }
  }
}

// MARK: - NetworkDataProvider
protocol NetworkDataProvider { }

enum CallError: Error {
  case networkError(String)
  case jsonError(Error)
  case unknownError(Error)
  case unknownWithoutError
}

struct Fortune: Decodable {
  var fortune: String?
}
