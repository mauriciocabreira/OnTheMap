//
//  ConfirmAddPinViewController.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 06/10/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 22/09/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import UIKit
import MapKit

class ConfirmAddPinViewController: UIViewController, UINavigationControllerDelegate {
  
  // MARK: Properties
  var location: String = ""
  var website: String = ""
  var latitude: Double = 0
  var longitude: Double = 0
  
  
  @IBOutlet weak var mapView: MKMapView!
  // MARK: Actions
  
  
  @IBAction func addPinButtonPressed(_ sender: Any) {
    
    FBOTMClient.sharedInstance().postLocation(latitude, longitude, location, website) { (success, errorString) in
      if errorString != nil {
        self.presentError("An error has occurred")
        print("error: \(errorString!)")
      }
      
    }
    
    let controller = self.navigationController!.viewControllers[0]
    let _ = self.navigationController?.popToViewController(controller, animated: true)
    
  }
  
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.main.async {
      
      let coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude)
      
      let span = MKCoordinateSpanMake(0.04, 0.04)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      
      self.mapView.addAnnotation(annotation)
      self.mapView.setRegion(region, animated: true)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.isNavigationBarHidden = false
    
    tabBarController?.tabBar.isHidden = false
  }
  
  
  
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func presentError(_ message: String, _ title: String = "Error", _ actionTitle: String = "OK") {
    self.present(FBOTMClient.sharedInstance().raiseError(message, title, actionTitle), animated: true, completion: nil)
  }
  
}

