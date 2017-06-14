//
//  AHFeedBaseCell.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import Cartography
import UIKit

protocol AHFeedBaseCellDelegate: class {
  func didTapCommentButton(_ sender:UIButton, forHoot hoot:Hoot)
}

class AHFeedBaseCell: UITableViewCell {
  weak var delegate:AHFeedBaseCellDelegate?
  
  var hoot:Hoot?
  
  private lazy var locationLabel:UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "SFUIText-Medium", size: 11.0)
    label.textColor = UIColor.black.withAlphaComponent(0.55)
    
    return label
  }()
  
  private lazy var optionsButton:UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "icon-hoot-more"), for: .normal)
    
    return button
  }()
  
  lazy var buttonContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white.withAlphaComponent(0.25)
    
    return view
  }()
  
  private lazy var hootContainer: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    
    return view
  }()
  
  private(set) lazy var contentContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    view.layer.masksToBounds = false
    view.layer.shadowOpacity = 0.6
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    
    return view
  }()
  
  private lazy var divider: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    
    return view
  }()
  
  private lazy var likeButton:UIButton = { [unowned self] in
    let button = UIButton()
    button.setImage(UIImage(named: "icon-hoot-thumbUp"), for: .normal)
    button.addTarget(self, action: #selector(AHFeedBaseCell.didTapButton(_:)), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var likeLabel:UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "SFUIText-Medium", size: 11.0)
    label.textColor = UIColor.black.withAlphaComponent(0.55)
    
    return label
  }()
  
  private lazy var dislikeButton:UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "icon-hoot-thumbDown"), for: .normal)
    button.addTarget(self, action: #selector(AHFeedBaseCell.didTapButton(_:)), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var dislikeLabel:UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "SFUIText-Medium", size: 11.0)
    label.textColor = UIColor.black.withAlphaComponent(0.55)
    
    return label
  }()
  
  private lazy var commentButton:UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "icon-hoot-comments"), for: .normal)
    button.addTarget(self, action: #selector(AHFeedBaseCell.didTapButton(_:)), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var commentLabel:UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "SFUIText-Medium", size: 11.0)
    label.textColor = UIColor.black.withAlphaComponent(0.55)
    
    return label
  }()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    self.constrainViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func constrainViews() {
    self.contentView.addSubview(self.locationLabel)
    self.contentView.addSubview(self.optionsButton)
    self.contentView.addSubview(self.hootContainer)
    self.contentView.addSubview(self.divider)
    
    constrain(self.locationLabel, self.optionsButton, self.hootContainer, self.divider) { (location, options, content, divider) in
      location.leading == location.superview!.leading + 15
      location.top == location.superview!.top + 30
      
      options.centerY == location.centerY
      options.trailing == options.superview!.trailing - 15
      
      content.leading == location.leading
      content.trailing == options.trailing
      content.top == location.bottom + 10
      content.bottom == content.superview!.bottom - 35
      
      divider.leading == divider.superview!.leading
      divider.trailing == divider.superview!.trailing
      divider.bottom == divider.superview!.bottom
      divider.height == 1
    }
    
    self.hootContainer.addSubview(self.contentContainer)
    self.hootContainer.addSubview(self.buttonContainer)
    constrain(self.hootContainer, self.contentContainer, self.buttonContainer) { (hoot, content, buttons) in
      content.leading == content.superview!.leading
      content.trailing == content.superview!.trailing
      content.top == content.superview!.top
      content.bottom == buttons.top
      
      buttons.leading == buttons.superview!.leading
      buttons.trailing == buttons.superview!.trailing
      buttons.bottom == buttons.superview!.bottom
      buttons.height == 35
    }
    
    self.buttonContainer.addSubview(self.likeButton)
    self.buttonContainer.addSubview(self.likeLabel)
    self.buttonContainer.addSubview(self.dislikeButton)
    self.buttonContainer.addSubview(self.dislikeLabel)
    self.buttonContainer.addSubview(self.commentButton)
    self.buttonContainer.addSubview(self.commentLabel)
    
    constrain(self.likeButton, self.likeLabel, self.dislikeButton, self.dislikeLabel) { (like, likeLabel, dislike, dislikeLabel) in
      like.leading == like.superview!.leading + 10
      like.centerY == like.superview!.centerY
      
      likeLabel.leading == like.trailing + 8
      likeLabel.centerY == likeLabel.superview!.centerY
      
      dislike.leading == dislike.superview!.leading + 70
      dislike.centerY == dislike.superview!.centerY
      
      dislikeLabel.leading == dislike.trailing + 8
      dislikeLabel.centerY == dislikeLabel.superview!.centerY
    }
    
    constrain(self.commentButton, self.commentLabel) { (comment, label) in
      comment.trailing == comment.superview!.trailing - 50
      comment.centerY == comment.superview!.centerY
      
      label.leading == comment.trailing + 8
      label.centerY == label.superview!.centerY
    }
  }
  
  func configure(withHoot hoot:Hoot) {
    self.hoot = hoot
    self.locationLabel.text = hoot.timeLocationLabelText
    self.likeLabel.text = hoot.num_ups
    self.dislikeLabel.text = hoot.num_downs
    self.commentLabel.text = hoot.num_replies
  }
  
  func didTapButton(_ sender:UIButton) {
    guard let hoot = self.hoot else { return }
    let generator = UIImpactFeedbackGenerator(style: .light)
    switch sender {
    case self.likeButton:
      generator.impactOccurred()
      hoot.like().then { hoot -> Void in
        self.configure(withHoot: hoot)
      }.end()
    case self.dislikeButton:
      generator.impactOccurred()
      hoot.dislike().then { hoot -> Void in
        self.configure(withHoot: hoot)
      }.end()
    case self.commentButton:
      guard let hoot = self.hoot else { break }
      self.delegate?.didTapCommentButton(sender, forHoot: hoot)
    default:
      break
    }
  }
}
