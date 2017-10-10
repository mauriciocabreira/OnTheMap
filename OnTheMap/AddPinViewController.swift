//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 22/09/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
  
  // MARK: Properties
  @IBOutlet weak var navBar: UINavigationBar!
  @IBOutlet weak var findLocation: BorderedButton!
  @IBOutlet weak var locationText: UITextField!
  @IBOutlet weak var websiteText: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var geocoder = CLGeocoder()
  
  
  var location: String = ""
  var website: String = ""
  var latitude: Double = 0
  var longitude: Double = 0
  
  
  
  // MARK: Actions
  
  @IBAction func cancelButtonPressed(_ sender: Any) {
    
    let controller = self.navigationController!.viewControllers[0]
    let _ = self.navigationController?.popToViewController(controller, animated: true)
  }
  
  @IBAction func findOnTheMapButtonPressed(_ sender: Any) {
    
    
    // DEBUG
    if FBOTMClient.Constants.testing_offline {
      
      let confirmAddPinViewController = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmAddPinViewController") as! ConfirmAddPinViewController
      
      confirmAddPinViewController.latitude = 28.1461248
      confirmAddPinViewController.longitude = -82.75676799999999
      confirmAddPinViewController.location = "miami"
      confirmAddPinViewController.website = "www.runs.site"
      
      navigationController!.pushViewController(confirmAddPinViewController, animated: true)
    } else {
      
      
      if !locationText.text!.isEmpty {
        if websiteIsValid(websiteText.text!)
        {
          isLoading(true)
          
          DispatchQueue.main.async {
            
            self.geocoder.geocodeAddressString(self.locationText.text!) { (placemark, error) in
              if error != nil {
                self.presentError("Location Is Not Valid")
                self.isLoading(false)
                return
              }
              guard let placemark = placemark?[0] else {
                self.presentError("Location Is Not Valid")
                self.isLoading(false)
                return
              }
              guard let website = self.websiteText.text else {
                self.presentError("Website Is Not Valid")
                self.isLoading(false)
                return
              }
              
              guard let location = self.locationText.text else {
                self.presentError("Location Is Not Valid")
                self.isLoading(false)
                return
              }
              let latitude = placemark.location!.coordinate.latitude
              let longitude = placemark.location!.coordinate.longitude
              
              //I got the coordinates, now need to show it on the map
              let confirmAddPinViewController = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmAddPinViewController") as! ConfirmAddPinViewController
              confirmAddPinViewController.latitude = latitude
              confirmAddPinViewController.longitude = longitude
              confirmAddPinViewController.location = location
              confirmAddPinViewController.website = website
              
              self.isLoading(false)
              self.navigationController!.pushViewController(confirmAddPinViewController, animated: true)
              
            }
          }
        } else {
          presentError("Website cannot be empty and must start with \"http://\" ou \"https://\"")
        }
      } else {
        
        presentError("Please add a location.")
      }
    }
  }
  
  
  
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicator.hidesWhenStopped = true
    isLoading(false)
    locationText.delegate = self
    websiteText.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  // MARK: Auxiliary functions
   
  func isLoading(_ loading : Bool) {
    if loading {
      activityIndicator.startAnimating()
      findLocation.isEnabled = false
      locationText.isEnabled = false
      websiteText.isEnabled = false
      
    } else {
      activityIndicator.stopAnimating()
      findLocation.isEnabled = true
      locationText.isEnabled = true
      websiteText.isEnabled = true
      
    }
  }
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  
  func presentError(_ message: String, _ title: String = "Error", _ actionTitle: String = "OK") {
    present(FBOTMClient.sharedInstance().raiseError(message, title, actionTitle), animated: true, completion: nil)
  }
  
  func websiteIsValid(_ website: String) -> Bool {
    return (website.hasPrefix("https://") || website.hasPrefix("http://"))
  }
  
  
}






