import SpriteKit

class GameOverScene: SKScene {
  
  private let networkService = NetworkService()
  private var button: SKNode!
  private var currentScore = 0
  private var gameMenuView = GameMenuView()
  
  init(size: CGSize, won: Bool, score: Int, new: Bool! = false) {
    super.init(size: size)
    backgroundColor = SKColor.white
    currentScore = won ? score + 1 : score
    if won {
      UserDefaultsHelper.shared.set(currentScore, key: .score)
    }
    networkService.getCompanyInfo { [weak self] result in
      switch result {
      case .success(let success):
        self?.createView(won: won, fortuneText: success?.fortune ?? "", new: new)
      case .failure(let error):
        print(error)
        self?.createView(won: won, fortuneText: "", new: new)
      }
    }
  }
  
  func createView(won: Bool, fortuneText: String, new: Bool! = false) {
    gameMenuView.frame = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    gameMenuView.box.delegate = self
    gameMenuView.populate(won: won, fortune: fortuneText, new: new)
    self.view?.addSubview(gameMenuView)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension GameOverScene: StackViewDelegate {
  func didTapOnView(at index: Int) {
    gameMenuView.removeFromSuperview()
    switch index {
    case 0:
      run(SKAction.sequence([
        SKAction.run() { [weak self] in
          guard let self = self else { return }
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
          let scene = GameScene(size: self.size)
          scene.score = self.currentScore
          self.view?.presentScene(scene, transition:reveal)
        }
      ]))
    case 1:
      UserDefaultsHelper.shared.set(5, key: .score)
      run(SKAction.sequence([
        SKAction.run() { [weak self] in
          guard let self = self else { return }
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
          let scene = GameScene(size: self.size)
          self.view?.presentScene(scene, transition:reveal)
        }
      ]))
    default: break
    }
    
  }
}
