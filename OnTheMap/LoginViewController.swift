//
//  ViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/4/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var studentsInformation = [StudentInformation]()
    var publicUserData = [String: String]()
    var onTheMapClient: OTMClient!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        onTheMapClient = OTMClient.sharedInstance()
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = view.center
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        
        // Remove these two lines later
        emailTextField.text = "jaeseung@gmail.com"
        passwordTextField.text = "6Uq-yNP-VUp-dUQ"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! OnTheMapTabBarController
        
        destinationController.studentsInformation = studentsInformation
    }


    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text, email != "" else {
            loginFailed("Please enter your email address.")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            loginFailed("Please enter your password.")
            return
        }
        
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
 
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        
        let _ = onTheMapClient.getSessionID(with: ["email": email, "password": password]) { (success, results, errorString) in
            if success {
                // Geting pulbic user data
                
                let _ = self.onTheMapClient.getPublicUserData(completionHandlerForUserData: { (success, userData, errorString) in
                    
                    if success {
                        
                        guard let firstName = userData!["first_name"] as? String else {
                            self.loginFailed("Cannot get yout first name!")
                            return
                        }
                        
                        self.publicUserData["firstName"] = firstName
                        
                        guard let lastName = userData!["last_name"] as? String else {
                            self.loginFailed("Cannot get yout last name!")
                            return
                        }
                        
                        self.publicUserData["lastName"] = lastName
                        
                        print("\(String(describing: self.publicUserData["lastName"]))")
                        
                        let _ = self.onTheMapClient.getStudentLocations(completionHandlerForStudentLocation: { (success, results, errorString) in
                            
                            if success {
                                for result in results! {
                                    let studentLocation = StudentInformation(dictionary: result)
                                    self.studentsInformation.append(studentLocation)
                                }
                                print("\(self.studentsInformation.count)")
                                DispatchQueue.main.async {
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    self.activityIndicator.stopAnimating()
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
                })
            } else {
                self.loginFailed(errorString!)
                return
            }
        }
        
    }
    
    func loginFailed(_ message: String) {
        // Alert View Controller when login failed
        // Should differentiate between a failure to connect and incorrect credentials
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                NSLog("Login Failed")
            }))
            self.present(alert, animated: true, completion: nil)
            
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
