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
    var onTheMapClient: OTHClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        onTheMapClient = OTHClient.sharedInstance()
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
                self.loginFailed("Failure to connect. Check the network connection.")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 403 {
                    self.loginFailed("Account not found or invalid credentials.")
                }
                
                print("Your request returned a status code other than 2xx!")
                self.loginFailed("There is a problem. Try again.")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                self.loginFailed("There is a problem. Try again.")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            // print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            let parsedResult: [String: AnyObject]!
                
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                self.loginFailed("There is a problem. Try again.")
                return
            }
            
            if let _ = parsedResult["status"] as? Int {
                // self.loginFailed("Incorrect email or password")
                return
            }
            
            guard let account = parsedResult["account"] as? [String: AnyObject], let key = account["key"] as? String else {
                print("Could not get the account key.")
                self.loginFailed("There is a problem. Try again.")
                return
            }
            
            OTHClient.sharedInstance().userID = key
            
            guard let sessionID = parsedResult["session"] as? [String: AnyObject], let id = sessionID["id"] as? String else {
                print("Could not get the session ID.")
                self.loginFailed("There is a problem. Try again.")
                return
            }
            
            OTHClient.sharedInstance().sessionID = id
            print(id)
            
            // self.loginFailed("Login Succeeded.")
            
            // Geting pulbic user data
            
            let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(key)")!)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                guard (error == nil) else {
                    return
                }
                
                // let range = Range(5..<data!.count)
                // let newData = data?.subdata(in: range)
                // print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
                
                // Getting student locations
                
                self.onTheMapClient.getStudentLocations(completionHandlerForStudentLocation: { (success, results, errorString) in
                    
                    if success {
                        for result in results! {
                            let studentLocation = StudentInformation(dictionary: result)
                            self.studentsInformation.append(studentLocation)
                        }
                        print("\(self.studentsInformation.count)")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "LogedIn", sender: self)
                        }
                    } else {
                        self.loginFailed(errorString!)
                        return
                    }
                })
                
            })
            
            task.resume()
            
        }
        
        task.resume()
        
        
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
        }
    }
    
}

