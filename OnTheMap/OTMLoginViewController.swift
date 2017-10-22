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
    
    // TODO: Remove these two lines later
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = "jaeseung@gmail.com"
        passwordTextField.text = "6Uq-yNP-VUp-dUQ"
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
            if success {
                self.otmLocations.load(completionHandlerForLoad: { (success, errorString) in
                    if success {
                        DispatchQueue.main.async {
                            self.indicatorStatus(false)
                            self.performSegue(withIdentifier: "LogedIn", sender: self)
                        }
                    } else {
                        self.loginFailed(errorString!)
                        return
                    }
                })
            } else {
                self.loginFailed(errorString!)
                return
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
            
            self.present(alert, animated: true, completion: nil)
            self.indicatorStatus(false)
        }
    }
    
    func indicatorStatus(_ on: Bool) {
        self.emailTextField.isEnabled = !on
        self.passwordTextField.isEnabled = !on

        UIApplication.shared.isNetworkActivityIndicatorVisible = on
        
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
}
