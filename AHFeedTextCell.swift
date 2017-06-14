//
//  AHFeedTextCell.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import Cartography
import UIKit

class AHFeedTextCell: AHFeedBaseCell {
  private lazy var hootTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "SFUIText-Regular", size: 20.0)
    label.numberOfLines = 0
    label.textColor = .white
    
    return label
  }()
  
  override func constrainViews() {
    super.constrainViews()
    self.contentContainer.addSubview(self.hootTextLabel)
    
    constrain(self.contentContainer, self.hootTextLabel) { (content, label) in
      label.edges == inset(label.superview!.edges, 15.0)
    }
  }
  
  override func configure(withHoot hoot:Hoot) {
    super.configure(withHoot: hoot)
    self.hootTextLabel.text = hoot.text
  }
}
