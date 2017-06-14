//
//  AHPhotoCell.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import Cartography
import SDWebImage
import UIKit

class AHPhotoCell: AHFeedBaseCell {
  private lazy var hootImageView:UIImageView = {
    let imageView = UIImageView()
    
    return imageView
  }()
  
  override func constrainViews() {
    super.constrainViews()
    self.contentContainer.addSubview(self.hootImageView)
    
    constrain(self.contentContainer, self.hootImageView) { (content, image) in
      image.edges == image.superview!.edges
      image.height == image.width
    }
  }
  
  override func configure(withHoot hoot:Hoot) {
    super.configure(withHoot: hoot)
    if let url = hoot.photo {
      self.hootImageView.sd_setImage(with: url)
    }
  }
}
