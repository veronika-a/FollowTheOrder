import SpriteKit

class GameOverScene: SKScene {
  var button: SKNode!
  var currentScore = 0
  
  init(size: CGSize, won: Bool, score: Int) {
    super.init(size: size)
    backgroundColor = SKColor.white
    currentScore = won ? score + 1 : score
    if won { UserDefaultsHelper.shared.set(currentScore, key: .score) }
    let message = won ? "You Won!" : "Oooops"
    createView(message: message, buttonText: "Try again")
  }
  
  func createView(message: String, buttonText: String) {
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    
    
    button = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: self.size.width - 80, height: 50))
    button.position = CGPoint(x: self.frame.midX, y: size.height/2 - label.frame.height - 10)
    
    let sublabel = SKLabelNode(fontNamed: "Chalkduster")
    sublabel.text = buttonText
    sublabel.fontSize = 20
    sublabel.fontColor = SKColor.black
    sublabel.position = CGPoint(x: self.frame.midX, y: size.height/2 - label.frame.height)

    addChild(label)
    addChild(button)
    addChild(sublabel)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      let location = t.location(in: self)
      if button.contains(location) {
        run(SKAction.sequence([
          SKAction.run() { [weak self] in
            guard let self = self else { return }
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = GameScene(size: self.size)
            scene.score = self.currentScore
            self.view?.presentScene(scene, transition:reveal)
          }
        ]))
      }
    }
  }
}
  
