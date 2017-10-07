//
//  FirebaseOnTheMapConstants.swift
//  OnTheMap
//
//  Created by Mauricio Cabreira 7/9/2017.
//  Copyright (c) 2017 Mauricio. All rights reserved.
//

// MARK: - FBOTMClient (Constants)


import UIKit
import Foundation

extension FBOTMClient {
  
  // MARK: Constants
  struct Constants {
    
    // MARK: PARSE Udacity API Key
    static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    
    static let testing_offline = false
    
    // MARK: URLs
    static let AuthenticateURL = "https://www.udacity.com/api/session"
    static let SignUpPage = "https://www.udacity.com/account/auth#!/signup"
    
    static let LimitNumber = 100
    static let DescUpdatedAt = "-updatedAt"
    static let AscUpdatedAt = "updatedAt"
    
    static let AscCreatedAt = "createdAt"
    static let DescCreatedAt = "-createdAt"
    
    // MARK: Parameter Keys
    struct ParameterKeys {
      static let ApiKey = "api_key"
      static let Username = "username"
      static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
      static let SessionID = "session"
      static let UserID = "account"
      
    }
    struct PinJSONResponse {
      
      static let CreatedAt = "createdAt"
      static let FirstName = "firstName"
      static let LastName = "lastName"
      static let Latitude = "latitude"
      static let Longitude = "longitude"
      static let MapString = "mapString"
      static let MediaURL = "mediaURL"
      static let ObjectId = "objectId"
      static let UniqueKey = "uniqueKey"
      static let UpdatedAt = "updatedAt"
      
    }
  }
  
  
}
