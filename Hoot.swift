//
//  Hoot.swift
//  airhoot
//
//  Created by Craig Cronin on 6/2/17.
//  Copyright © 2017 130R Studios. All rights reserved.
//

import Foundation
import SwiftDate
import SwiftyJSON
import PromiseKit

public class Hoot:NSObject {
  enum HootType {
    case text, photo, photoText, giphy
  }
  
  private var jsonHootObject:JSON

//TODO:  File task to move this logic to API
  var type: HootType {
    if (self.isGiphy) {
      return .giphy
    }
    
    if (self.photo != nil) {
      if (self.text != "") {
        return .photoText
      }
      
      return .photo
    }
    
    return .text
  }
  
//TODO: Switch to guid once new API is live
  var guid: String {
    return self.jsonHootObject["hoot_id"].stringValue
    //return self.jsonHootObject["guid"].stringValue
  }
  
  var key_hash: String {
    return self.jsonHootObject["key_hash"].stringValue
  }
  
  var key_id: String {
    return self.jsonHootObject["key_id"].stringValue
  }
  
  var text: String? {
    return self.jsonHootObject["text"].stringValue
  }
  
  var photo: URL? {
    if let photoString = self.jsonHootObject["photo"].string {
      return URL(string: photoString, relativeTo: AHApiClient.photoUrl)
    } else {
      return nil
    }
  }
  
  var giphy: GiphyObject? {
    let giphyJson = self.jsonHootObject["giphy"]
    if giphyJson.exists() {
      return GiphyObject(withServerJSON: giphyJson)
    }
    
    return nil
  }
  
  var num_ups:String {
    return self.jsonHootObject["num_ups"].stringValue
  }
  
  var isGiphy:Bool {
    return self.jsonHootObject["is_giphy"].boolValue
  }
  
  var isLiked:Bool {
    return self.jsonHootObject["is_liked"].boolValue
  }
  
  var num_downs:String {
    return self.jsonHootObject["num_downs"].stringValue
  }
  
  var isDisliked:Bool {
    return self.jsonHootObject["is_disliked"].boolValue
  }
  
  var num_favorites:String {
    return self.jsonHootObject["num_favorites"].stringValue
  }
  
  var isFavorite:Bool {
    return self.jsonHootObject["is_favorite"].boolValue
  }
  
  var num_replies:String {
    return self.jsonHootObject["num_replies"].stringValue
  }
  
  var isReplied:Bool {
    return self.jsonHootObject["is_replied"].boolValue
  }
  
  var creation: Date {
    let seconds = self.jsonHootObject["creation"].intValue
    return Date(timeIntervalSince1970: TimeInterval(seconds))
  }
  
  var coordinates:HootCoordinates? {
    let coordinateJson = self.jsonHootObject["coordinates"]
    if coordinateJson.exists() {
      return HootCoordinates(withJson: coordinateJson)
    }
    
    return nil
  }
  
  var replies:[HootReply] {
    guard let replyJsonArray = self.jsonHootObject["replies"].array else { return [HootReply]() }
    var array = [HootReply]()
    for replyJson in replyJsonArray {
      if let reply = HootReply(withJson: replyJson) {
        array.append(reply)
      }
    }
      
    return array
  }
  
  var redoodles:[ReDoodle] {
    var array = [ReDoodle]()
    for x in 0..<self.replies.count {
      let reply = self.replies[x]
      if reply.is_redoodle {
        array.append(ReDoodle(reply: reply, index: x))
      }
    }
    
    return array
  }
  
  var timeLocationLabelText:String {
    guard let coordinates = self.coordinates else { return "" }
    let date = DateInRegion(absoluteDate: self.creation)
    let (colloquial, _) = try! date.colloquialSinceNow()
    
    return colloquial + " in \(coordinates.locality), \(coordinates.admin)"
  }
  
  init?(withJson json:JSON) {
    guard let _ = json["hoot_id"].string else {
      return nil
    }
    
    self.jsonHootObject = json
    super.init()
  }
  
  func update(withJson jsonObject:JSON) {
    self.jsonHootObject = jsonObject
  }
  
  func fetchDetails() -> Promise<Hoot> {
    return AHApiClient.shared.fetchHoot(withId: self.guid).then { apiResponse -> Hoot in
      self.update(withJson: apiResponse)
      return self
    }
  }
  
  func like() -> Promise<Hoot> {
    return AHApiClient.shared.like(hootWithId: self.guid).then { (_) -> Promise<JSON> in
      return AHApiClient.shared.fetchHoot(withId: self.guid)
    }.then { hootJson -> Hoot in
      self.update(withJson: hootJson)
      return self
    }
  }
  
  func dislike() -> Promise<Hoot> {
    return AHApiClient.shared.dislike(hootWithId: self.guid).then { (_) -> Promise<JSON> in
      return AHApiClient.shared.fetchHoot(withId: self.guid)
    }.then { hootJson -> Hoot in
      self.update(withJson: hootJson)
      return self
    }
  }
  
  func favorite() -> Promise<Hoot> {
    return AHApiClient.shared.favorite(hootWithId: self.guid).then { (_) -> Promise<JSON> in
      return AHApiClient.shared.fetchHoot(withId: self.guid)
    }.then { hootJson -> Hoot in
      self.update(withJson: hootJson)
      return self
    }
  }
  
  func reply(withText text:String, location:HootLocation?) -> Promise<Hoot> {
    return AHApiClient.shared.reply(toHootWithId: self.guid, text: text, location: location).then { apiResponse -> Promise<JSON> in
      return AHApiClient.shared.fetchHoot(withId: self.guid)
    }.then { hootJson -> Hoot in
      self.update(withJson: hootJson)
      return self
    }
  }
  
  class func post(fromDictionary dict:[String:AnyObject]) -> Promise<Hoot> {
    return AHApiClient.shared.post(withDictionary: dict).then { jsonResponse -> Hoot in
      guard let hoot = Hoot(withJson: jsonResponse) else {
        throw NSError(domain: "post", code: 0, userInfo: [NSLocalizedDescriptionKey:"Hoot cannot be created with provided data"])
      }
      
      return hoot
    }
  }
  
  class func hootArray(fromJSON json:JSON) -> [Hoot] {
    guard let hootJSONArray = json["hoots"].array else { return [Hoot]() }
    var hootArray = [Hoot]()
    for hootJson in hootJSONArray {
      if let hoot = Hoot(withJson: hootJson) {
        hootArray.append(hoot)
      }
    }
    
    return hootArray
  }
}

extension AHApiClient {
  func like(hootWithId guid: String) -> Promise<Void> {
    var params = self.fetchStandardParams()
    params?["hoot"] = guid as AnyObject
    return self.request(withMethod: .post, forPath: "hoot/like", params: params).then { _ -> Void in }
  }
  
  func dislike(hootWithId guid: String) -> Promise<Void> {
    var params = self.fetchStandardParams()
    params?["hoot"] = guid as AnyObject
    return self.request(withMethod: .post, forPath: "hoot/dislike", params: params).then { response -> Void in }
  }
  
  func favorite(hootWithId guid: String) -> Promise<Void> {
    var params = self.fetchStandardParams()
    params?["hoot"] = guid as AnyObject
    return self.request(withMethod: .post, forPath: "hoot/favorite", params: params).then { response -> Void in }
  }
  
  func reply(toHootWithId guid:String, text:String, location:HootLocation?) -> Promise<Void> {
    var params = self.fetchStandardParams()
    params?["hoot"] = guid as AnyObject
    params?["text"] = text as AnyObject
    if let location = location {
      params?.update(other: location.toDict())
    } else {
      params?.update(other: HootLocation.unknownLocationDict())
    }
    
    return self.request(withMethod: .post, forPath: "reply/create", params: params).then { response -> Void in }
  }
  
  func fetchHoot(withId guid:String) -> Promise<JSON> {
    var params = self.fetchStandardParams()
    params?["hoot"] = guid as AnyObject
    params?["version"] = "2.00" as AnyObject
    params?["more"] = "1" as AnyObject
    
    return self.request(withMethod: .get, forPath: "hoot/single", params: params).then { response -> JSON in
      guard let hootJson = response["hoots"].arrayValue.first else {
        throw NSError(domain: "hoot/single", code: 0, userInfo: [NSLocalizedDescriptionKey:"Empty response array"])
      }
      
      return hootJson
    }
  }
  
  func post(withDictionary dict:[String:AnyObject]) -> Promise<JSON> {
    let path = "hoot/create"
    var params = self.fetchStandardParams()
    
    for (key, value) in dict {
      params?[key] = value
    }
      
    if let image = dict["image"] as? UIImage {
      return self.uploadRequest(withImage: image, withPath: path, params: params).then { response -> JSON in
        guard let hootJson = response["hoots"].arrayValue.first else {
          throw NSError(domain: "hoot/create", code: 0, userInfo: [NSLocalizedDescriptionKey:"Empty response array"])
        }
        
        return hootJson
      }
    } else {
      return self.request(withMethod: .post, forPath: path, params: params).then { response -> JSON in
        guard let hootJson = response["hoots"].arrayValue.first else {
          throw NSError(domain: "hoot/create", code: 0, userInfo: [NSLocalizedDescriptionKey:"Empty response array"])
        }
        
        return hootJson
      }
    }
  }
}

