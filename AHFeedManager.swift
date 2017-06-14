//
//  AHFeedManager.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import PromiseKit
import UIKit

class AHFeedManager: NSObject {
  enum AHFeedType: String {
    case all = "all",
    near = "near",
    popular = "popular",
    favorite = "favorite",
    mine = "mine"
  }
  
  let tableView:UITableView
  var hoots = [Hoot]()
  var feedToDisplay:AHFeedType = .all
  
  private lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(AHFeedManager.fetchHoots), for: .valueChanged)
    
    return control
  }()
  
  init(withTableView tableView:UITableView) {
    self.tableView = tableView
    super.init()
    self.tableView.refreshControl = self.refreshControl
  }
  
  func fetchHoots() {
    AHApiClient.shared.fetchHoots(forFeed: self.feedToDisplay).then { hoots -> Void in
      self.hoots = hoots
      self.tableView.reloadData()
      if self.refreshControl.isRefreshing {
        self.refreshControl.endRefreshing()
      }
    }.end()
  }
  
  func fetchMoreHoots(withLastId hootId:String) {
    AHApiClient.shared.fetchMoreHoots(forFeed: self.feedToDisplay, withLastId: hootId).then { hoots -> Void in
      self.hoots.append(contentsOf: hoots)
      self.tableView.reloadData()
    }.end()
  }
  
  func switchFeed(toFeedType type:AHFeedType) {
    self.feedToDisplay = type
    self.fetchHoots()
  }
}

extension AHFeedManager: AHAddHootViewControllerDelegate {
  func didCreate(hoot: Hoot) {
    self.hoots.insert(hoot, at: 0)
    self.tableView.scrollToTop()
    self.tableView.beginUpdates()
    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    self.tableView.endUpdates()
  }
}

extension AHApiClient {
  func fetchHoots(forFeed type:AHFeedManager.AHFeedType) -> Promise<[Hoot]> {
    let params = self.fetchStandardParams()
    return self.request(withMethod: .get, forPath: "feed/\(type.rawValue)", params: params).then { response -> [Hoot] in
      return Hoot.hootArray(fromJSON: response)
    }
  }
  
  func fetchMoreHoots(forFeed type:AHFeedManager.AHFeedType, withLastId hootId:String) -> Promise<[Hoot]> {
      var params = self.fetchStandardParams()
      params?["last"] = hootId as AnyObject
      return self.request(withMethod: .get, forPath: "feed/\(type.rawValue)", params: params).then { response -> [Hoot] in
        return Hoot.hootArray(fromJSON: response)
      }
  }
}
