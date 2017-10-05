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
 
        // email = "jaeseung@gmail.com"
        // password = "6Uq-yNP-VUp-dUQ"
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard (error == nil) else {
                print("There is an error: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            let parsedResult: [String: AnyObject]!
                
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let _ = parsedResult["status"] as? Int {
                // self.loginFailed("Incorrect email or password")
                return
            }
            
            // self.loginFailed("Incorrect email or password")
        }
        
        task.resume()
        
        
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

