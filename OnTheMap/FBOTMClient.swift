//
//  FBOTMClient.swift
//  OnTheMap
//
//  Created by Mauricio Cabreira 7/9/2017.
//  Copyright (c) 2017 Mauricio. All rights reserved.
//
import UIKit
import Foundation

// MARK: - FBOTMClient: NSObject

class FBOTMClient : NSObject, UIAlertViewDelegate {
  
  // MARK: Properties
  
  var session = URLSession.shared
  var currentUserPin = LoggedUserPin.sharedInstance.pin
  var sessionID: String = ""
  var userID: String = ""
  var objectID: String = ""
  var firstName: String = ""
  var lastName: String = ""
  
  // MARK: Initializers
  
  override init() {
    super.init()
  }
  
  
  // MARK: Authenticate user
  
  func authenticateWithViewController(_ username: String, _ password: String, _ hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
    self.getSessionID(username: username, password: password) { (success, sessionID, userID, errorString) in
      
      if success {
        
        self.sessionID = sessionID!
        self.userID = userID!
        
        completionHandlerForAuth(success, errorString)
      } else {
        completionHandlerForAuth(success, errorString)
      }
    }
  }
  
  // MARK: Get user ID
  
  func getSessionID(username: String, password: String, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ userID: String?, _ errorString: String?) -> Void) {
    
    let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    
    request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest) { data, response, error in
      
      if let error = error {
        print(error)
        completionHandlerForSession(false, nil, nil, "Login Failed (Session ID).")
      } else {
        
        guard let results = try? JSONSerialization.jsonObject(with: data!.subdata(in: Range(uncheckedBounds: (lower: data!.startIndex.advanced(by: 5), upper: data!.endIndex))), options: .allowFragments) as! [String: AnyObject] else {
          print("Could not parse the data as JSON")
          return
        }
        
        print(results)
        
        if let accountJson = results["account"] as? [String: AnyObject] {
          let accountKey = accountJson["key"] as? String
          
          if let sessionJson = results["session"] as? [String: AnyObject] {
            let sessionID = sessionJson["id"] as? String
            completionHandlerForSession(true, sessionID, accountKey, nil)
          } else {
            print("Could not find \(FBOTMClient.Constants.JSONResponseKeys.SessionID) in \(response!)")
            completionHandlerForSession(false, nil, nil, "Login Failed (Session ID).")
          }
        } else {
          print("Could not find \(FBOTMClient.Constants.JSONResponseKeys.SessionID) in \(response!)")
          completionHandlerForSession(false, nil, nil, "Login Failed (Session ID).")
        }
       
        
      }
    }
    task.resume()
  }
  
  
  // MARK logged user data
  
  func getUserData(completionHandlerForUserData: @escaping (_ succes: Bool) -> Void) {
    DispatchQueue.global(qos: .background).async {
      
      let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(self.userID)%22%7D&order=\(Constants.DescCreatedAt)&limit=\(Constants.LimitNumber)"
      
      let url = URL(string: urlString)
      let request = NSMutableURLRequest(url: url!)
      
      request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
      request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
      
      let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
        if error != nil {
          print("error: \(error!)");
          completionHandlerForUserData(false);
          return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
          print("UdacityClient.swift 253: Your request returned a status code other than 2xx!")
          completionHandlerForUserData(false)
          return
        }
        
        let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
        
        guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
          print("UdacityClient.swift 261: Couldn't find any results")
          completionHandlerForUserData(false)
          return
        }
        
        self.currentUserPin = Pin.dataFromPins(results)
        
        
        //print("Found user data: \(self.currentUserPin[0].firstName)")
        
        if Pins.sharedInstance.pins.count > 0 {
          self.objectID = Pins.sharedInstance.pins.first!.objectID!
        }
        completionHandlerForUserData(true)
      }
      task.resume()
      
    }
  }
  
  
  //MARK: Get PIN data for the user that is logged in
  
  func getLoggedInUserPinData() {
    DispatchQueue.global(qos: .background).async {
      
      let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(self.userID)")!)
      
      let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
        if error != nil {
          print("error: \(error!)")
          return
        }
        
        let range = Range(uncheckedBounds: (5, data!.count))
        let newData = data?.subdata(in: range)
        
        let parsedResult = try! JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as AnyObject
        
        guard let user = parsedResult["user"] as? [String:AnyObject] else {
          print("Could not retrieve parsedResult")
          return
        }
        
        guard let firstName = user["first_name"] as? String else {
          print("Could not retrieve first name from parsedResult")
          return
        }
        
        guard let lastName = user["last_name"] as? String else {
          print("Could not retrieve last name from parsedResult")
          return
        }
        self.firstName = firstName
        self.lastName = lastName
      }
      task.resume()
      
    }
    
  }
  
  
  
  //MARK: Get PIN data for all users
 
  func getPins(completionHandlerForPins: @escaping ( _ succes: Bool, _ error: String? ) -> Void) {
    
    Pins.sharedInstance.pins.removeAll()
    
    let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=\(Constants.DescUpdatedAt)")!)
    
    request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    
    
    let task = session.dataTask(with: request as URLRequest) { data, response, error in
      
      guard (error == nil) else {
        print("There was an error with GETting student Locations")
        completionHandlerForPins(false, "An error occured")
        return
      }
      
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        print("Your request returned a status code other than 2xx!")
        completionHandlerForPins(false, "An error occured")
        return
      }
      
      let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
      
      
      guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
        print("Couldn't find any results")
        completionHandlerForPins(false, "Couldn't find any results")
        return
      }
      
      let parsedPins = Pin.dataFromPins(results)
      
      Pins.sharedInstance.pins.append(contentsOf: parsedPins)
      
      print("Number of retrieved PINs: \(Pins.sharedInstance.pins.count)")
      
      
      completionHandlerForPins(true, nil)
    }
    
    task.resume()
    
  }
  
  //MARK: Post pin that user has entered
  func postLocation(_ latitude: Double, _ longitude: Double, _ locationText: String, _ mediaURL: String, completionHandlerForPostPin: @escaping ( _ succes: Bool, _ error: String? ) -> Void) {
    let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
    
    request.httpMethod = "POST"
    request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = "{\"uniqueKey\": \"\(userID)\", \"firstName\": \"\(currentUserPin[0].firstName!)\", \"lastName\": \"\(currentUserPin[0].lastName!)\",\"mapString\": \"\(locationText)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
    
    let task = session.dataTask(with: request as URLRequest) { data, response, error in
      if error != nil { completionHandlerForPostPin(false, "An error occured when posting your location") }
      
      completionHandlerForPostPin(true, nil)
      
    }
    
    task.resume()
  }
  
  
  //MARK: Delete user session needed during logout
  
  func deleteSession(completionHandlerForLogout: @escaping ( _ succes: Bool, _ error: String? ) -> Void) {
    
    let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
    request.httpMethod = "DELETE"
    var xsrfCookie: HTTPCookie? = nil
    let sharedCookieStorage = HTTPCookieStorage.shared
    for cookie in sharedCookieStorage.cookies! {
      if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
      request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
    
    
    let task = session.dataTask(with: request as URLRequest) { data, response, error in
      
      if error != nil {
        completionHandlerForLogout(false, error as! String?)
        return
      }
      completionHandlerForLogout(true, nil)
    }
    task.resume()
  }
  
  func raiseError(_ message: String, _ title: String, _ actionTitle: String) -> UIAlertController {
    let invalidLinkAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    invalidLinkAlert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
    
    return invalidLinkAlert
  }
  
  func userHasPinAlready() -> Bool {
    return !FBOTMClient.sharedInstance().currentUserPin.isEmpty
  }
  
  
  
  
  // MARK: Shared Instance
  
  class func sharedInstance() -> FBOTMClient {
    struct Singleton {
      static var sharedInstance = FBOTMClient()
    }
    return Singleton.sharedInstance
  }
}
