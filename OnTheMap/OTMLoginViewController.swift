//
//  ViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/4/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit

class OTMLoginViewController: UIViewController {

    // MARK: Properties
    
    // MARK: IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Shared Instances
    let otmLocations = OTMLocations.sharedInstance
    let otmClient = OTMClient.sharedInstance
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = view.center
    }
    
    // MARK: IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, email != "" else {
            loginFailed("Please enter your email address.")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            loginFailed("Please enter your password.")
            return
        }
        
        self.indicatorStatus(true)
        
        let _ = otmClient.logIn(with: ["email": email, "password": password]) { (success, errorString) in
            DispatchQueue.main.async {
                self.indicatorStatus(false)
                self.emailTextField.text = "Email"
                self.passwordTextField.text = "password"
            }
            
            if success {
                self.otmLocations.load(completionHandlerForLoad: { (success, errorString) in
                    if success {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "LogedIn", sender: self)
                        }
                    } else {
                        self.loginFailed(errorString!)
                    }
                })
            } else {
                self.loginFailed(errorString!)
            }
        }
    }
    
    // MARK: Custom Methods
    func loginFailed(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
                NSLog("Login Failed")
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    func indicatorStatus(_ on: Bool) {
        self.emailTextField.isEnabled = !on
        self.passwordTextField.isEnabled = !on

        if on {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension OTMLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
