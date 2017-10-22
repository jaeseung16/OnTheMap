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
    // MARK: Properties
    // Singleton
    static let sharedInstance = OTMClient()

    var session = URLSession.shared
    
    // For authentication state
    var requestToken: String?
    var sessionID: String?
    
    // For posting
    var userID: String?
    var userFirstName: String?
    var userLastName: String?
    var objectID: String?
    
    // MARK: - Methods
    override init() {
        super.init()
    }
    
    // MARK: - Authentication methods
    func logIn(with parameters: [String: String], completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let _ = getSessionID(with: parameters) { (success, errorString) in
            if success {
                let _ = self.getPublicUserData() { (success, errorString) in
                    if success {
                        completionHandlerForAuth(true, nil)
                    } else {
                        completionHandlerForAuth(false, errorString)
                    }
                }
            } else {
                completionHandlerForAuth(false, errorString)
            }
        }
    }

    func getSessionID(with parameters: [String: String], completionHandlerForSessionID: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = requestForSessionID(with: parameters)
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                guard let errorString = error!.userInfo[NSLocalizedDescriptionKey] as? String else {
                    completionHandlerForSessionID(false, "There was an unknown error with your request.")
                    return
                }
                
                // Distinguish an error due to time-out from one caused by wrong credentials.
                if errorString.starts(with: "There was an error with your request: ") {
                    completionHandlerForSessionID(false, "The request timed out.")
                } else if errorString == "Your request returned a status code other than 2xx!" {
                    completionHandlerForSessionID(false, "Account not found. Wrong email or password.")
                } else {
                    completionHandlerForSessionID(false, errorString)
                }
                return
            }
           
            guard let data = data else {
                completionHandlerForSessionID(false, "No data was returned by the request.")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            guard let parsedResult = self.parseJSON(newData) else {
                completionHandlerForSessionID(false, "Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let account = parsedResult["account"] as? [String: AnyObject], let key = account["key"] as? String else {
                completionHandlerForSessionID(false, "Could not get the user ID.")
                return
            }
            
            guard let sessionID = parsedResult["session"] as? [String: AnyObject], let id = sessionID["id"] as? String else {
                completionHandlerForSessionID(false, "Could not get the session ID.")
                return
            }
            
            // Save userID and sessionID for later uses.
            self.userID = key
            self.sessionID = id
            completionHandlerForSessionID(true, nil)
        }
            
        return task
    }
    
    func getPublicUserData(completionHandlerForUserData: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: URL(string: OTMClient.UserDataURL + "\(self.userID!)")!)
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForUserData(false, "Cannot download public user data.")
                return
            }
            
            guard let data = data else {
                completionHandlerForUserData(false, "No data was returned by the request.")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            guard let parsedResult = self.parseJSON(newData) else {
                completionHandlerForUserData(false, "Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let userData = parsedResult["user"] as? [String: AnyObject] else {
                completionHandlerForUserData(false, "Could not get the user key.")
                return
            }
            
            guard let firstName = userData["first_name"] as? String else {
                completionHandlerForUserData(false, "Could not get the first_name key.")
                return
            }
            
            guard let lastName = userData["last_name"] as? String else {
                completionHandlerForUserData(false, "Could not get the last_name key.")
                return
            }
            
            // Save the name of a user for the method postAStudentLocation(with:completionHandlerForPostLocation:)
            self.userFirstName = firstName
            self.userLastName = lastName
            completionHandlerForUserData(true, nil)
        }
        
        return task
    }
    
    func getStudentLocations(completionHandlerForStudentLocation: @escaping (_ sucess: Bool, _ results: [[String: AnyObject]]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = requestForStudentLocation(with: ["limit": "\(OTMConstant.numberOfLocations)", "order": "-updatedAt"])
        
        let task = dataTask(with: request) { (data, error) in
            guard (error == nil) else {
                completionHandlerForStudentLocation(false, nil, "Cannot download student locations.")
                return
            }
            
            guard let data = data else {
                completionHandlerForStudentLocation(false, nil, "No data was returned by the request.")
                return
            }
            
            guard let parsedResult = self.parseJSON(data) else {
                completionHandlerForStudentLocation(false, nil, "Could not parse the data as JSON: '\(data)'")
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
    
    func getAStudentLocation(completionHandlerForAStudentLocation: @escaping (_ sucess: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = requestForStudentLocation(with: ["where": "{\"uniqueKey\":\"\(self.userID!)\"}", "order": "-updatedAt"])
        
        let task = dataTask(with: request) { (data, error) in
            guard (error == nil) else {
                completionHandlerForAStudentLocation(false, "Cannot download the student location.")
                return
            }
            
            guard let data = data else {
                completionHandlerForAStudentLocation(false, "No data was returned by the request.")
                return
            }
            
            guard let parsedResult = self.parseJSON(data) else {
                completionHandlerForAStudentLocation(false, "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let result = parsedResult["results"] as? [[String: AnyObject]], let objectID = result[0]["objectId"] as? String else {
                completionHandlerForAStudentLocation(false, "Could not find the student location.")
                return
            }
            
            // Save the objectID for the method postAStudentLocation(with:completionHandlerForPostLocation:)
            self.objectID = objectID
            completionHandlerForAStudentLocation(true, nil)
        }
        
        return task
    }
    
    func postAStudentLocation(with parameters: [String: String], completionHandlerForPostLocation: @escaping (_ sucess: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = requestForPutAndPost(with: parameters)
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForPostLocation(false, "Cannot download the student location.")
                return
            }
            
            guard let data = data else {
                completionHandlerForPostLocation(false, "No data was returned by the request.")
                return
            }
            
            guard let parsedResult = self.parseJSON(data) else {
                completionHandlerForPostLocation(false, "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard (parsedResult["updatedAt"] as? String) != nil else {
                completionHandlerForPostLocation(false, "There is a problem. Try again.")
                return
            }
            
            completionHandlerForPostLocation(true, nil)
        }
        
        return task
    }
    
    func logOut(completionHandlerForLogOut: @escaping (_ success: Bool, _ errorString: String?) -> Void) -> URLSessionDataTask {
        let request = requestForLogOut()
        
        let task = dataTask(with: request as URLRequest) { (data, error) in
            guard (error == nil) else {
                completionHandlerForLogOut(false, "Logout failed. Try again.")
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data!.subdata(in: range)
            
            guard let parsedResult = self.parseJSON(newData) else {
                completionHandlerForLogOut(false, "There is a problem. Try again.")
                return
            }
            
            guard let session = parsedResult["session"] as? [String: AnyObject], (session["id"] as? String) != nil else {
                completionHandlerForLogOut(false, "There is a problem. Try again.")
                return
            }
            
            self.reset()
            completionHandlerForLogOut(true, nil)
        }

        return task
    }
    
    // MARK: - Custom Methods
    // Reset variables after logging out
    func reset() {
        OTMClient.sharedInstance.requestToken = nil
        OTMClient.sharedInstance.sessionID = nil
        OTMClient.sharedInstance.userID = nil
        OTMClient.sharedInstance.userFirstName = nil
        OTMClient.sharedInstance.userLastName = nil
        OTMClient.sharedInstance.objectID = nil
    }
    
    // Construct a request for a session ID
    func requestForSessionID(with parameters: [String: String]) -> URLRequest {
        let email = parameters["email"]
        let password = parameters["password"]
        
        let request = NSMutableURLRequest(url: URL(string: OTMClient.SessionURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(password!)\"}}".data(using: String.Encoding.utf8)
        
        return request as URLRequest
    }
    
    // Construct a request for Student Location(s)
    func requestForStudentLocation(with queryItems: [String: String]) -> URLRequest {
        var component = URLComponents()
        component.scheme = OTMClient.OTMConstant.scheme
        component.host = OTMClient.OTMConstant.hostParse
        component.path = OTMClient.OTMConstant.pathParse
        component.queryItems = [URLQueryItem]()
        
        for item in queryItems {
            component.queryItems!.append( URLQueryItem(name: "\(item.key)", value: "\(item.value)" ))
        }
        
        let request = NSMutableURLRequest(url: component.url!)
        request.addValue(OTMClient.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return request as URLRequest
    }
    
    // Construct a request for POST or PUT a Student Location
    func requestForPutAndPost(with parameters: [String: String]) -> URLRequest {
        var component = URLComponents()
        component.scheme = OTMClient.OTMConstant.scheme
        component.host = OTMClient.OTMConstant.hostParse
        component.path = OTMClient.OTMConstant.pathParse
        
        var httpMethod: String
        
        if let objectID = OTMClient.sharedInstance.objectID {
            component.path = component.path + "/\(objectID)"
            httpMethod = "PUT"
        } else {
            httpMethod = "POST"
        }
        
        let request = NSMutableURLRequest(url: component.url!)
        request.httpMethod = httpMethod
        request.addValue(OTMClient.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBodyForPostAndPut(with: parameters)
        
        return request as URLRequest
    }
    
    func requestForLogOut() -> URLRequest {
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
        
        return request as URLRequest
    }
    
    // Construct HTTP Body for POST or PUT a Student Location
    func httpBodyForPostAndPut(with parameters: [String: String]) -> Data? {
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

        return stringForHttpBody.data(using: String.Encoding.utf8)
    }
    
    // Common DataTask
    func dataTask(with request: URLRequest, completionHandlerForDataTask: @escaping (_ data: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForDataTask(nil, NSError(domain: "dataTask", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
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
    
    // Parse JSON data into a dictionary
    func parseJSON(_ data: Data) -> [String: AnyObject]? {
        let parsedResult: [String: AnyObject]!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            return nil
        }
        
        return parsedResult
    }
}
