//
//  LabelModel.swift
//  PingPong
//
//  Created by Samir Akhmadi on 21.09.2022.
//
import UIKit

class LabelModel: UILabel {
    
  override init(frame: CGRect) {
      super.init(frame: frame)
      self.text = ""
      self.font = UIFont(name: "Avinir", size: 14)
      self.textAlignment = .center
      self.translatesAutoresizingMaskIntoConstraints = false
      self.textColor = .white
  }
    
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }
    
}
