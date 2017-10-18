//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/10/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

// MARK: - OTMClient: NSObject

class OTMClient: NSObject {
    // MARK: Singleton
    static let sharedInstance = OTMClient()
    
    // MARK: - Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication state
    var requestToken: String?
    var sessionID: String?
    
    // for posting
    var userID: String?
    var userFirstName: String?
    var userLastName: String?
    var objectID: String?
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Authentication methods
    /*
    func authenticate(completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getSessionID() {
            getStudentLocations()
        }
    }*/
    
    // MARK: getSessionID
    
    func getSessionID(with parameters: [String: String], completionHandlerForSessionID: @escaping (_ success: Bool, _ parsedData: [[String: AnyObject]]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        let email = parameters["email"]
        let password = parameters["password"]
        
        let request = NSMutableURLRequest(url: URL(string: OTMClient.SessionURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(password!)\"}}".data(using: String.Encoding.utf8)
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                guard let errorString = error!.userInfo[NSLocalizedDescriptionKey] as? String else {
                    completionHandlerForSessionID(false, nil, "There was an unknown error with your request.")
                    return
                }
                
                if errorString.starts(with: "There was an error with your request: ") {
                    completionHandlerForSessionID(false, nil, "The request timed out.")
                } else if errorString == "Your request returned a status code other than 2xx!" {
                    completionHandlerForSessionID(false, nil, "Account not found. Wrong email or password.")
                } else {
                    completionHandlerForSessionID(false, nil, errorString)
                }
                return
            }
           
            guard let data = data else {
                completionHandlerForSessionID(false, nil, "No data was returned by the request!")
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            // print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            let parsedResult: [String: AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForSessionID(false, nil, "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let _ = parsedResult["status"] as? Int {
                // self.loginFailed("Incorrect email or password")
                return
            }
            
            guard let account = parsedResult["account"] as? [String: AnyObject], let key = account["key"] as? String else {
                completionHandlerForSessionID(false, nil, "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            OTMClient.sharedInstance.userID = key
            
            guard let sessionID = parsedResult["session"] as? [String: AnyObject], let id = sessionID["id"] as? String else {
                completionHandlerForSessionID(false, nil, "Could not get the session ID.")
                return
            }
            
            OTMClient.sharedInstance.sessionID = id
            
            completionHandlerForSessionID(true, nil, nil)
            
        }
            
        return task
    }
    
    // MARK: getPublicUserData
    
    func getPublicUserData(completionHandlerForUserData: @escaping (_ success: Bool, _ userData: [String: AnyObject]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(self.userID!)")!)
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForUserData(false, nil, "Cannot download public user data.")
                return
            }
            
            guard let data = data else {
                completionHandlerForUserData(false, nil, "No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            let parsedResult: [String: AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForUserData(false, nil, "Could not parse the data as JSON: '\(String(describing: newData))'")
                return
            }
            
            guard let userData = parsedResult["user"] as? [String: AnyObject] else {
                completionHandlerForUserData(false, nil, "Could not get the user key.")
                return
            }
            
            completionHandlerForUserData(true, userData, nil)
            // print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        return task
    }
    
    // MARK: getStudentLocations
    
    func getStudentLocations(completionHandlerForStudentLocation: @escaping (_ sucess: Bool, _ results: [[String: AnyObject]]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue(OTMClient.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
       
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForStudentLocation(false, nil, "Cannot download student locations.")
                return
            }
            
            guard let data = data else {
                completionHandlerForStudentLocation(false, nil, "No data was returned by the request!")
                return
            }
            
            let parsedResult: [String: AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForStudentLocation(false, nil, "Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String: AnyObject]] else {
                completionHandlerForStudentLocation(false, nil, "Could not get the results key.")
                return
            }
            
            completionHandlerForStudentLocation(true, results, nil)
            
        }
        
        return task
    }
    
    // MARK: getAStudentLocation
    
    func getAStudentLocation(completionHandlerForStudentLocation: @escaping (_ sucess: Bool, _ result: [String: AnyObject]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        var component = URLComponents()
        component.scheme = OTMClient.OTMConstant.scheme
        component.host = OTMClient.OTMConstant.hostParse
        component.path = OTMClient.OTMConstant.pathParse
        component.queryItems = [URLQueryItem]()
        component.queryItems!.append( URLQueryItem(name: "where", value: "{\"uniqueKey\":\"\(OTMClient.sharedInstance.userID!)\"}") )
        print("\(component.url!)")
        
        let request = NSMutableURLRequest(url: component.url!)
        request.addValue(OTMClient.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForStudentLocation(false, nil, "Cannot download the student location.")
                return
            }
            
            guard let data = data else {
                completionHandlerForStudentLocation(false, nil, "No data was returned by the request!")
                return
            }
            
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            
            let parsedResult: [String: AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForStudentLocation(false, nil, "Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            guard let result = parsedResult["results"] as? [[String: AnyObject]], let _ = result[0]["uniqueKey"] as? String else {
                completionHandlerForStudentLocation(false, nil, "Could not find the student location.")
                return
            }
            
            OTMClient.sharedInstance.objectID = result[0]["objectId"] as? String
            
            completionHandlerForStudentLocation(true, result[0], nil)
            
        }
        
        return task
    }
    
    // MARK: postAStudentLocation
    
    func postAStudentLocation(with parameters: [String: String], completionHandlerForPostLocation: @escaping (_ sucess: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        var component = URLComponents()
        component.scheme = OTMClient.OTMConstant.scheme
        component.host = OTMClient.OTMConstant.hostParse
        
        print("\(String(describing: OTMClient.sharedInstance.objectID))")
        
        var httpMethod: String
        
        if let objectID = OTMClient.sharedInstance.objectID {
            component.path = OTMClient.OTMConstant.pathParse + "/\(objectID)"
            httpMethod = "PUT"
        } else {
            component.path = OTMClient.OTMConstant.pathParse
            httpMethod = "POST"
        }
        /*
        let request = NSMutableURLRequest()
        
        if let objectID = OTMClient.sharedInstance.objectID {
            print("overwriting...")
            print("https://parse.udacity.com/parse/classes/StudentLocation/\(objectID)")
            request.url = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectID)")!
            request.httpMethod = "PUT"
        } else {
            print("submitting...")
            print("https://parse.udacity.com/parse/classes/StudentLocation")
            request.url = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
            request.httpMethod = "POST"
        }*/
        print("\(component.url!)")
        print(httpMethod)
        
        let request = NSMutableURLRequest(url: component.url!)
        request.httpMethod = httpMethod
        request.addValue(OTMClient.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBodyForPostAndPut(with: parameters).data(using: String.Encoding.utf8)
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForPostLocation(false, "Cannot download the student location.")
                return
            }
            
            guard let data = data else {
                completionHandlerForPostLocation(false, "No data was returned by the request!")
                return
            }
            
            let parsedResult: [String: AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForPostLocation(false, "Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            print("\(parsedResult)")
            
            guard (parsedResult["updatedAt"] as? String) != nil else {
                completionHandlerForPostLocation(false, "Could not find the student location.")
                return
            }
            
            completionHandlerForPostLocation(true, nil)
            
        }
        
        return task
    }
    
    // MARK: - logOut
    
    func logOut(completionHandlerForLogOut: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: OTMClient.SessionURL)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForLogOut(false, "Logout failed. Try again.")
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data!.subdata(in: range)
            
            let parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForLogOut(false, "The data returned has a problem. Try again.")
                return
            }
            
            guard let session = parsedResult["session"] as? [String: AnyObject], (session["id"] as? String) != nil else {
                completionHandlerForLogOut(false, "The data returned has a problem. Try again.")
                return
            }
            
            self.reset()
            completionHandlerForLogOut(true, nil)
        }

        return task
    }
    
    func reset() {
        OTMClient.sharedInstance.requestToken = nil
        OTMClient.sharedInstance.sessionID = nil
        OTMClient.sharedInstance.userID = nil
        OTMClient.sharedInstance.userFirstName = nil
        OTMClient.sharedInstance.userLastName = nil
        OTMClient.sharedInstance.objectID = nil
    }
    
    // MARK:
    func httpBodyForPostAndPut(with parameters: [String: String]) -> String {
        var extendedParameters = parameters
        extendedParameters["uniqueKey"] = "\"\(OTMClient.sharedInstance.userID!)\""
        extendedParameters["firstName"] = "\"\(OTMClient.sharedInstance.userFirstName!)\""
        extendedParameters["lastName"] = "\"\(OTMClient.sharedInstance.userLastName!)\""
        
        var stringForHttpBody = "{"
        
        for parameter in extendedParameters {
            stringForHttpBody.append("\"\(parameter.key)\": \(parameter.value), ")
        }
        
        stringForHttpBody.removeLast(2)
        stringForHttpBody.append("}")

        return stringForHttpBody
    }
    
    // MARK: - dataTask
    func dataTask(with request: URLRequest, completionHandlerForDataTask: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForDataTask(nil, NSError(domain: "dataTask", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                print("\(error!)")
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            completionHandlerForDataTask(data, nil)
        }
        
        task.resume()
        return task
    }
}
