import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  init(size: CGSize, start: Bool! = false) {
    super.init(size: size)
    self.start = start
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private var start = false
  private var spinnyNode: SKShapeNode?
  private var scoreLabel: SKLabelNode!
  private var apples = [SKSpriteNode]()
  private var gameTimer: Timer!
  private var currentIndex = 0 {
    didSet {
      if currentIndex >= score {
        gameTimer.invalidate()
        gameTimer = nil
      }
    }
  }
  private var possibleApples = ["apple"]
  private var rightApple = 0 {
    didSet{
      if rightApple == score {
        gameOver(won: true)
      }
    }
  }
  
  var score: Int = 5 {
    didSet {
      scoreLabel?.text = "Score: \(score - 5)"
    }
  }
  
  func setUpScene() {
    let w = (self.size.width + self.size.height) * 0.05
    self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
    
    if let spinnyNode = self.spinnyNode {
      spinnyNode.lineWidth = 4.0
      spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
    }
  }
  
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.darkGray
    self.setUpScene()
    scoreLabel = SKLabelNode(text: "")
    scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 100)
    scoreLabel.fontSize = 36
    scoreLabel.fontName = UIFont.systemFont(ofSize: 36).fontName
    scoreLabel.fontColor = UIColor.white
    
    if !start { new() } else {
      gameOver()
    }
  }
  
  private func new() {
    let savedScore = UserDefaultsHelper.shared.getInt(key: .score)
    score = savedScore != 0 ? savedScore : score
    
    for _ in 0..<score { addApple() }
    
    gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
    self.addChild(scoreLabel)
  }
  
  func makeSpinny(at pos: CGPoint, color: SKColor) {
    if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
      spinny.position = pos
      spinny.strokeColor = color
      self.addChild(spinny)
    }
  }
  
  @objc func addApple() {
    possibleApples = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleApples) as! [String]
    
    let alien = SKSpriteNode(imageNamed: possibleApples[0])
    let width: CGFloat = 50
    let height: CGFloat = width
    alien.size.width = width
    alien.size.height = height
    
    let randomXPosition = GKRandomDistribution(lowestValue: Int(width), highestValue: Int(self.size.width - width))
    let positionX = CGFloat(randomXPosition.nextInt())
    let randomYPosition = GKRandomDistribution(lowestValue: Int(height), highestValue: Int(self.size.height - height))
    let positionY = CGFloat(randomYPosition.nextInt())
    
    alien.position = CGPoint(x: positionX, y: positionY)
    self.addChild(alien)
    apples.append(alien)
  }
  
  @objc func animate() {
    let apple = apples[currentIndex]
    let pulseUp = SKAction.scale(to: 3.0, duration: 1.0)
    let pulseDown = SKAction.scale(to: 1.0, duration: 1.0)
    let pulse = SKAction.sequence([pulseUp, pulseDown])
    let repeatPulse = SKAction.repeat(pulse, count: 1)
    apple.run(repeatPulse)
    
    currentIndex = currentIndex + 1
  }
  
  func gameOver(won: Bool! = true) {
    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
    let gameOverScene = GameOverScene(size: self.size, won: won, score: score, new: start)
    self.view?.presentScene(gameOverScene, transition: reveal)
  }
  
  override func update(_ currentTime: TimeInterval) {  }
}

extension GameScene {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard gameTimer == nil else { return }
    for t in touches {
      let location = t.location(in: self)
      let apple = apples[rightApple]
      if apples.contains(where: {$0.contains(location)}) {
        switch apple.contains(location) {
        case true:
          self.makeSpinny(at: t.location(in: self), color: SKColor.green)
          rightApple = rightApple + 1
        case false:
          self.makeSpinny(at: t.location(in: self), color: SKColor.red)
          gameOver(won: false)
        }
      }
    }
  }
  
}

