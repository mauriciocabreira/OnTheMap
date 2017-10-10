//
//  MapMapViewController.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 08/09/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  
  
  // MARK: Properties
  @IBOutlet weak var refreshButton: UIBarButtonItem!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var mapView: MKMapView!
  
  var pinsAnnotations: [MKPointAnnotation] = []
  
  
  // MARK: Actions
  
  @IBAction func logoutPressed(_ sender: Any) {
    FBOTMClient.sharedInstance().deleteSession { (succes, error) in
      guard succes else {
        self.activityIndicator.stopAnimating();
        self.presentError("An error occured when deleting the session")
        
        return
      }
      
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
        self.activityIndicator.stopAnimating()
      }
    }
  }
  
  
  @IBAction func addPinButtonPressed(_ sender: Any) {
    
     if FBOTMClient.sharedInstance().userHasPinAlready() {
      
      let firstName = FBOTMClient.sharedInstance().firstName
      let lastName = FBOTMClient.sharedInstance().lastName
      
      let invalidLinkAlert = UIAlertController(title: "", message: "User \"\(firstName) \(lastName)\" already have a location. Would you like to update it?", preferredStyle: .alert)
      let overwriteAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default) { UIAlertAction in
        let addPinViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        self.navigationController!.pushViewController(addPinViewController, animated: true)
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
      
      invalidLinkAlert.addAction(overwriteAction)
      invalidLinkAlert.addAction(cancelAction)
      
      self.present(invalidLinkAlert, animated: true, completion: nil)
    } else {
      let addPinViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
      self.navigationController!.pushViewController(addPinViewController, animated: true)
      
    }
    
  }
  
  
  @IBAction func refreshPressed(_ sender: Any) {
    updateMap()
  }
  
  
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    activityIndicator.hidesWhenStopped = true
    updateMap()
    
  }
  
  private func updateMap() {
    
    isLoading(true)
    mapView.removeAnnotations(pinsAnnotations)
    pinsAnnotations.removeAll()
    
    //Testing offline mode
    if FBOTMClient.Constants.testing_offline {
      setupAnnotations { (success) in
        
      }
    } else {
      
      FBOTMClient.sharedInstance().getUserData { (success) in
        if success {
          FBOTMClient.sharedInstance().getLoggedInUserPinData()
        }
        else {
          self.presentError("An error occured when getting pin data")
        }
        
        self.setupMap { (success, errorString) in
          if errorString != nil {
            self.presentError("An error occured when presenting pin data")
          }
        }
      }
    }
    isLoading(false)
  }
  
  
  
  
  // Here we create a view with a "right callout accessory view". You might choose to look into other
  // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
  // method in TableViewDataSource.
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinTintColor = .green
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }
    return pinView
  }
  
  
  
  // This delegate method is implemented to respond to taps. It opens the system browser
  // to the URL specified in the annotationViews subtitle property.
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
      let app = UIApplication.shared
      if let toOpen = view.annotation?.subtitle! {
        app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
      }
    }
  }
  
  func setupMap(completionHandlerForSetupMap: @escaping (_ succes: Bool, _ errorString: String?) -> Void ) {
    
    FBOTMClient.sharedInstance().getPins { (success, errorString) in
      DispatchQueue.main.async {
        
        if success {
          self.setupAnnotations { (success) in
            completionHandlerForSetupMap(true, nil)
          }
          
        } else {
          print(errorString!)
          completionHandlerForSetupMap(false, errorString)
          return
        }
        
      }
    }
    
  }
  
  
  
  func setupAnnotations(completionHandlerForSetupAnnotations: @escaping (_ succes: Bool) -> Void ) {
    
    for pin in Pins.sharedInstance.pins {
      
      let latitude = CLLocationDegrees(pin.latitude!)
      let longitude = CLLocationDegrees(pin.longitude!)
      let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = "\(pin.firstName!) \(pin.lastName!)"
      annotation.subtitle = pin.mediaURL!
      
      pinsAnnotations.append(annotation)
    }
    mapView.addAnnotations(pinsAnnotations)
    
    print("Number of Pins: \(pinsAnnotations.count)")
    
    
    completionHandlerForSetupAnnotations(true)
  }
  
  func isLoading(_ loading : Bool) {
    if loading {
      activityIndicator.startAnimating()
      refreshButton.isEnabled = false
      
      
    } else {
      activityIndicator.stopAnimating()
      refreshButton.isEnabled = true
      
    }
  }
  
  
  
  func presentError(_ message: String, _ title: String = "Error", _ actionTitle: String = "OK") {
    present(FBOTMClient.sharedInstance().raiseError(message, title, actionTitle), animated: true, completion: nil)
  }
  
}















