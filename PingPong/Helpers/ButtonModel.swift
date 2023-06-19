//
//  ViewFactory.swift
//  PingPong
//
//  Created by Samir Akhmadi on 21.09.2022.
//

import UIKit

class ButtonModel: UIButton {
    
  override init(frame: CGRect) {
      super.init(frame: frame)
      self.translatesAutoresizingMaskIntoConstraints = false
      self.titleLabel?.textAlignment = .center
      self.setTitleColor(.white, for: .normal)
      self.backgroundColor = .systemGray3
      self.layer.cornerRadius = 10
      self.isEnabled = false
  }
    
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }
    
}

extension UIButton {

    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

}

