import UIKit
import SnapKit

protocol StackViewDelegate: AnyObject {
  func didTapOnView(at index: Int)
}

class GameMenuView: UIView {
  
  var delegate: StackViewDelegate?
  var box = GameStackView()
  private var labelFortune = UILabel()
  private var label = UILabel()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func setup() {
    self.addSubview(box)
    self.addSubview(labelFortune)
    self.addSubview(label)

    box.snp.makeConstraints { (make) -> Void in
      make.left.right.equalTo(self).inset(40)
      make.center.equalTo(self)
      make.height.equalTo(140)
    }
    
    labelFortune.textColor = UIColor.black
    labelFortune.textAlignment = .center
    labelFortune.numberOfLines = 0
    labelFortune.font = labelFortune.font.withSize(20)
    labelFortune.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(box.snp.bottom).offset(20)
      make.left.right.equalTo(self.safeAreaLayoutGuide).inset(20)
      make.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
    }
    
    label.textColor = UIColor.darkGray
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = label.font.withSize(30)
    label.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(box.snp.top).offset(-20)
      make.left.right.equalTo(self.safeAreaLayoutGuide).inset(20)
    }
  }
  
  public func populate(won: Bool! = true, fortune: String, new: Bool! = false) {
    var message = "Hi!!!!"
    if !new {
      message = won ? "You Won!" : "Oooops"
    }
    label.text = message
    labelFortune.text = (!new && !won) ? fortune : ""
    let text = won ? ["Start", "New game"] : ["Try again", "New game"]
    box.populate(text: text)
  }
}

class GameStackView: UIStackView {
  var delegate: StackViewDelegate?
  var labels: [UILabel]?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.axis = .vertical
    self.distribution = .fillEqually
    self.alignment = .fill
    self.spacing = 20
    self.isUserInteractionEnabled = true
  }
  
  func populate(text: [String]) {
    for i in 0..<text.count {
      let label = UILabel()
      label.text = text[i]
      label.textColor = UIColor.white
      label.backgroundColor = UIColor.darkGray
      label.textAlignment = .center
      label.tag = i
      self.addArrangedSubview(label)
    }
    configureTapGestures()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureTapGestures() {
    arrangedSubviews.forEach { view in
      view.isUserInteractionEnabled = true
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
      view.addGestureRecognizer(tapGesture)
    }
  }
  
  @objc func didTapOnView(_ gestureRecognizer: UIGestureRecognizer) {
    if let index = arrangedSubviews.firstIndex(of: gestureRecognizer.view!) {
      delegate?.didTapOnView(at: index)
    }
  }
}
