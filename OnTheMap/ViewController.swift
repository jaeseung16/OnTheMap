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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // passwordTextField.isSecureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        loginFailed("Incorrect email or password.")
        
    }
    
    func loginFailed(_ message: String) {
        // Alert View Controller when login failed
        // Should differentiate between a failure to connect and incorrect credentials
        
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("Login Failed")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

