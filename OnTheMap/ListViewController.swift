//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 08/09/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
  
  
  // MARK: Properties
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var refreshButton: UIBarButtonItem!
  @IBOutlet weak var pinListView: UITableView!
  
 
  // MARK: Actions
  
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
      
      present(invalidLinkAlert, animated: true, completion: nil)
    } else {
      let addPinViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
      self.navigationController!.pushViewController(addPinViewController, animated: true)
      
    }
  }
  
  @IBAction func refreshPressed(_ sender: Any) {
    updateList()
    
  }
  
  @IBAction func logoutPressed(_ sender: Any) {
    
    
    FBOTMClient.sharedInstance().deleteSession { (success, error) in
      guard success else {
        self.isLoading(false)
        self.presentError("Error occurred when deleting session: \(String(describing: error))")
        return
      }
      
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
        self.isLoading(false)
      }
    }
  }
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicator.hidesWhenStopped = true
    isLoading(false)
    
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateList()
  }
  
  
  
  // MARK: Table View Data Source
  
  func updateList() {
    isLoading(true)
    
    
    //Testing offline mode is OFF, proceed normally
    if FBOTMClient.Constants.testing_offline {
      pinListView.reloadData()
      
    } else {
      
      FBOTMClient.sharedInstance().getUserData { (success) in
        if success {
          FBOTMClient.sharedInstance().getLoggedInUserPinData()
        }
        else {
          self.presentError("An error occured when getting pin data")
        }
        
        FBOTMClient.sharedInstance().getPins { (success, errorString) in
          DispatchQueue.main.async {
       
            if success {
              self.pinListView.reloadData()
              
            } else {
              self.presentError("Error: \(errorString!)")
            }
          }
        }
      }
    }
    isLoading(false)
  }
  
  
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return Pins.sharedInstance.pins.count
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
    let pin = Pins.sharedInstance.pins[(indexPath as NSIndexPath).row]
    
    
    cell.mapListTableImageLabel?.text = pin.firstName! + " " + pin.lastName!
    cell.mapListTableWebsite?.text = pin.mediaURL
    
    return cell
    
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let url = URL(string: Pins.sharedInstance.pins[(indexPath as NSIndexPath).row].mediaURL!) else {
      
      let alertController = UIAlertController(title: "Default AlertController", message: "Website not set", preferredStyle: .alert)
      
      let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
        print("Website not set");
      }
      alertController.addAction(cancelAction)
      present(alertController, animated: true, completion:nil)
      return
    }
    
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
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













