import Foundation

public enum UserDefaultsKeys: String, CaseIterable {
case score
}

final public class UserDefaultsHelper {
  
  class var shared: UserDefaultsHelper {
    struct Static {
      static let instance = UserDefaultsHelper()
    }
    return Static.instance
  }
  
  public func set<T: Any>(_ value: T, key: UserDefaultsKeys) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
  }
  
  public func getInt(key: UserDefaultsKeys) -> Int {
    guard let value = UserDefaults.standard.value(forKey: key.rawValue) as? Int else { return Int() }
    return value
  }
  
  public func getString(key: UserDefaultsKeys) -> String {
    guard let value = UserDefaults.standard.value(forKey: key.rawValue) as? String else { return String() }
    return value
  }
  
  public func getBool(key: UserDefaultsKeys) -> Bool {
    guard let value = UserDefaults.standard.value(forKey: key.rawValue) as? Bool else { return Bool() }
    return value
  }
  
  public func getIntArray(key: UserDefaultsKeys) -> [Int] {
    guard let value = UserDefaults.standard.value(forKey: key.rawValue) as? [Int] else { return [] }
    return value
  }
  
  public func remove(key: UserDefaultsKeys) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }
  
  public func reset() {
    UserDefaultsKeys.allCases.forEach { UserDefaults.standard.removeObject(forKey: $0.rawValue) }
  }
}
