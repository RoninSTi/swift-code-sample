//
//  AHPhotoTextCell.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import Cartography
import SDWebImage
import UIKit

class AHPhotoTextCell: AHFeedBaseCell {
  private lazy var hootTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "SFUIText-Regular", size: 20.0)
    label.numberOfLines = 0
    label.textColor = .white
    
    return label
  }()
  
  private lazy var hootImageView:UIImageView = {
    let imageView = UIImageView()
    
    return imageView
  }()
  
  override func constrainViews() {
    super.constrainViews()
    self.contentContainer.addSubview(self.hootImageView)
    self.contentContainer.addSubview(self.hootTextLabel)
    
    constrain(self.contentContainer, self.hootImageView, self.hootTextLabel) { (content, image, label) in
      image.top == image.superview!.top
      image.leading == image.superview!.leading
      image.trailing == image.superview!.trailing
      image.height == image.width
      image.bottom == label.top - 15
      
      label.leading == label.superview!.leading + 15
      label.trailing == label.superview!.trailing - 15
      label.bottom == label.superview!.bottom - 15
    }
  }
  
  override func configure(withHoot hoot:Hoot) {
    super.configure(withHoot: hoot)
    self.hootTextLabel.text = hoot.text
    if let url = hoot.photo {
      self.hootImageView.sd_setImage(with: url)
    }
  }
}
