//
//  MainFeedViewController.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import Cartography
import UIKit

class AHMainFeedViewController: UIViewController {
  static let kTextCellIdentifier = "kTextCellIdentifier"
  static let kPhotoCellIdentifier = "kPhotoCellIdentifier"
  static let KPhotoTextCellIdentifier = "KPhotoTextCellIdentifier"
  
  fileprivate lazy var tableView: UITableView = { [unowned self] in
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.delegate = self
    table.dataSource = self
    table.rowHeight = UITableViewAutomaticDimension
    table.estimatedRowHeight = 470
    table.separatorStyle = .none
    table.contentInset = UIEdgeInsetsMake(20, 0, 50, 0)
    table.register(AHFeedTextCell.self, forCellReuseIdentifier: AHMainFeedViewController.kTextCellIdentifier)
    table.register(AHPhotoCell.self, forCellReuseIdentifier: AHMainFeedViewController.kPhotoCellIdentifier)
    table.register(AHPhotoTextCell.self, forCellReuseIdentifier: AHMainFeedViewController.KPhotoTextCellIdentifier)
    table.delaysContentTouches = false
    table.backgroundColor = .clear
    
    return table
  }()
  
  private(set) lazy var manager: AHFeedManager = { [unowned self] in
    let manager = AHFeedManager(withTableView: self.tableView)
    
    return manager
  }()
  
  deinit {
    self.removeObservers()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let gradient = AHBackgroundGradient(frame: UIScreen.main.bounds)
    self.view.layer.insertSublayer(gradient, at: 0)
    self.addObservers()
    self.constrainViews()
    self.refreshData()
  }
  
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(AHMainFeedViewController.refreshData), name: .kAHNotificationFirstLoadComplete, object: nil)
  }
  
  func removeObservers() {
    NotificationCenter.default.removeObserver(self)
  }
  
  func constrainViews() {
    self.view.addSubview(self.tableView)
    constrain(self.tableView) { (table) in
      table.edges == table.superview!.edges
    }
  }
  
  func refreshData() {
    self.manager.fetchHoots()
  }
  
  func presentDetail(withHoot hoot:Hoot) {
    let viewController = AHDetailViewController.navWrapped(withHoot: hoot)
    self.present(viewController, animated: true, completion: nil)
  }
}

extension AHMainFeedViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.manager.hoots.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let hoot = self.manager.hoots[indexPath.row]
    switch hoot.type {
    case .text:
      let cell = tableView.dequeueReusableCell(withIdentifier: AHMainFeedViewController.kTextCellIdentifier, for: indexPath) as! AHFeedTextCell
      cell.configure(withHoot: hoot)
      cell.delegate = self
      
      return cell
    case .photo:
      let cell = tableView.dequeueReusableCell(withIdentifier: AHMainFeedViewController.kPhotoCellIdentifier, for: indexPath) as! AHPhotoCell
      cell.configure(withHoot: hoot)
      cell.delegate = self
      
      return cell
    case .photoText:
      let cell = tableView.dequeueReusableCell(withIdentifier: AHMainFeedViewController.KPhotoTextCellIdentifier, for: indexPath) as! AHPhotoTextCell
      cell.configure(withHoot: hoot)
      cell.delegate = self
      
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let hoot = self.manager.hoots[indexPath.row]
    self.presentDetail(withHoot: hoot)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == self.manager.hoots.count - 1 {
      let guid = self.manager.hoots[indexPath.row].guid
      self.manager.fetchMoreHoots(withLastId: guid)
    }
  }
}

extension AHMainFeedViewController: AHFeedBaseCellDelegate {
  func didTapCommentButton(_ sender: UIButton, forHoot hoot:Hoot) {
    self.presentDetail(withHoot: hoot)
  }
}
