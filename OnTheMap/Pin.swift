//
//  Student.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 16/09/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import Foundation

struct Pin {
  
  // MARK: Properties
  
  var createdAt: String? = ""
  var firstName: String? = "Unkown"
  var lastName: String? = "Name"
  var latitude: Double? = 0.0
  var longitude: Double? = 0.0
  var mapString: String? = ""
  var mediaURL: String? = ""
  var objectID: String? = ""
  var uniqueKey: String? = ""
  var updatedAt: String? = ""
  
  
  // MARK: Initializers
  
  init(dictionary: [String:AnyObject]) {
    
    if let createdAt = dictionary[FBOTMClient.Constants.PinJSONResponse.CreatedAt] as? String {
      self.createdAt = createdAt
    }
    
    if let firstName = dictionary[FBOTMClient.Constants.PinJSONResponse.FirstName] as? String {
      self.firstName = firstName
    }
    
    if let lastName = dictionary[FBOTMClient.Constants.PinJSONResponse.LastName] as? String {
      self.lastName = lastName
    }
    
    if let latitude = dictionary[FBOTMClient.Constants.PinJSONResponse.Latitude] as? Double {
      self.latitude = latitude
    }
    
    if let longitude = dictionary[FBOTMClient.Constants.PinJSONResponse.Longitude] as? Double {
      self.longitude = longitude
    }
    
    if let objectID = dictionary[FBOTMClient.Constants.PinJSONResponse.ObjectId] as? String {
      self.objectID = objectID
    }
    
    if let mapString = dictionary[FBOTMClient.Constants.PinJSONResponse.MapString] as? String {
      self.mapString = mapString
    }
    
    if let uniqueKey = dictionary[FBOTMClient.Constants.PinJSONResponse.UniqueKey] as? String {
      self.uniqueKey = uniqueKey
    }
    
    if let mediaURL = dictionary[FBOTMClient.Constants.PinJSONResponse.MediaURL] as? String {
      self.mediaURL = mediaURL
    }
    
    if let updatedAt = dictionary[FBOTMClient.Constants.PinJSONResponse.UpdatedAt] as? String {
      self.updatedAt = updatedAt
    }
    
  }
  
  static func dataFromPins(_ results: [[String:AnyObject]]) -> [Pin] {
    
    var PinData = [Pin]()
    
    for result in results { PinData.append(Pin(dictionary: result)) }
    
    return PinData
  }
  
}


