//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Mauricio Cabreira 7/9/2017.
//  Copyright (c) 2017 Mauricio. All rights reserved.
//



import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  // MARK: Properties
  
  @IBOutlet weak var debugTextLabel: UILabel!
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var loginButton: BorderedButton!
  
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  
  
  var session: URLSession!
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureBackground()
    loadingIndicator.hidesWhenStopped = true
    setUIEnabled(true)
    self.passwordTextField.delegate = self
    self.usernameTextField.delegate = self
    
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadingIndicator.stopAnimating()
    
  }
  
  
  
  // MARK: Actions
  
  @IBAction func loginPressed(_ sender: Any) {
    
    debugTextLabel.text = ""
    
    
    //Testing offline mode
    usernameTextField.text = "mauriciocabreira@gmail.com"
    passwordTextField.text = "meal3las"
    
    if FBOTMClient.Constants.testing_offline {
      
      //create fake pin data
      let parsedResults = hardCodedLocationData()
      let parsedPins = Pin.dataFromPins(parsedResults)
      Pins.sharedInstance.pins.append(contentsOf: parsedPins)
      
      //Login
      self.completeLogin()
      
    } else {
      
      if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
        self.presentError("Username or password can´t be empty.")
        
        //debugTextLabel.text = "Username or Password Empty."
      } else {
        
        if Reachability.isConnectedToNetwork() {
          setUIEnabled(false)
          
          
          
          FBOTMClient.sharedInstance().authenticateWithViewController(usernameTextField.text!, passwordTextField.text!, self) { (success, errorString) in
            performUIUpdatesOnMain {
              if success {
                self.completeLogin()
              } else {
                self.presentError("Username or password can´t be empty.")
                
                //self.displayError(errorString)
              }
            }
          }
        } else {
          self.presentError("Internet connection not available.")
          
        }
      }
      
    }
  }
  
  @IBAction func signupButton(_ sender: Any) {
    
    if let url = URL(string: FBOTMClient.Constants.SignUpPage) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  
  // MARK: Login
  func completeLogin() {
    performUIUpdatesOnMain {
      self.debugTextLabel.text = ""
      self.setUIEnabled(true)
      let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapsTabBarController") as! UITabBarController
      self.present(controller, animated: true, completion: nil)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
  
 
  func setUIEnabled(_ enabled: Bool) {
    loginButton.isEnabled = enabled
    debugTextLabel.isEnabled = enabled
    
    
    // adjust login button alpha
    if enabled {
      loginButton.alpha = 1.0
      loadingIndicator.stopAnimating()
    } else {
      loginButton.alpha = 0.5
      loadingIndicator.startAnimating()
    }
  }
  
  func displayError(_ errorString: String?) {
    if let errorString = errorString {
      debugTextLabel.text = errorString
      self.setUIEnabled(true)
      
    }
  }
  
  func configureBackground() {
    let backgroundGradient = CAGradientLayer()
    let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
    backgroundGradient.colors = [colorTop, colorBottom]
    backgroundGradient.locations = [0.0, 1.0]
    backgroundGradient.frame = view.frame
    view.layer.insertSublayer(backgroundGradient, at: 0)
  }
  
  func presentError(_ message: String, _ title: String = "Error", _ actionTitle: String = "OK") {
    self.present(FBOTMClient.sharedInstance().raiseError(message, title, actionTitle), animated: true, completion: nil)
  }
  
  //MARK: TEST DATA
  
  func hardCodedLocationData() -> [[String : AnyObject]] {
    return  [
      [
        "createdAt" : "2015-02-24T22:27:14.456Z" as AnyObject,
        "firstName" : "mau" as AnyObject,
        "lastName" : "mau" as AnyObject,
        "latitude" : 28.1461248 as AnyObject,
        "longitude" : -82.75676799999999 as AnyObject,
        "mapString" : "Tarpon Springs, FL" as AnyObject,
        "mediaURL" : "www.linkedin.com/in/jessicauelmen/en" as AnyObject,
        "objectId" : "kj18GEaWD8" as AnyObject,
        "uniqueKey" : 872458750 as AnyObject,
        "updatedAt" : "2015-03-09T22:07:09.593Z"  as AnyObject
      ], [
        "createdAt" : "2015-02-24T22:35:30.639Z" as AnyObject,
        "firstName" : "gu" as AnyObject,
        "lastName" : "gu-gi" as AnyObject,
        "latitude" : 35.1740471 as AnyObject,
        "longitude" : -79.3922539 as AnyObject,
        "mapString" : "Southern Pines, NC" as AnyObject,
        "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en" as AnyObject,
        "objectId" : "8ZEuHF5uX8" as AnyObject,
        "uniqueKey" : 2256298598 as AnyObject,
        "updatedAt" : "2015-03-11T03:23:49.582Z" as AnyObject
      ]
    ]
  }
}


