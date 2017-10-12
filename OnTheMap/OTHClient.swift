//
//  OTHClient.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/10/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

// MARK: - OTHClient: NSObject

class OTHClient: NSObject {
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication state
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTHClient {
        struct Singleton {
            static var sharedInstance = OTHClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Authentication methods
    /*
    func authenticate(completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getSessionID() {
            getStudentLocations()
        }
    }*/
    
    // MARK: getPublicUserData
    /*
    func getPublicUserData(completionHandlerForUserData: @escaping (_ success: Bool, _ results: [[String: AnyObject]]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        let task
        return
    }*/
    
    // MARK: getStudentLocations
    
    func getStudentLocations(completionHandlerForStudentLocation: @escaping (_ sucess: Bool, _ results: [[String: AnyObject]]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue(OTHClient.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTHClient.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
       
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
    
    // MARK: - dataTask
    func dataTask(with request: URLRequest, completionHandlerForDataTask: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
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
    
    // MARK: - logOut
    
    func logOut(completionHandlerForLogOut: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
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
                completionHandlerForLogOut(false, nil, "Logout failed. Try again.")
                return
            }
            
            guard let data = data else {
                completionHandlerForLogOut(false, nil, "Logout failed. Try again.")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            let parsedResult: [String: AnyObject]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
            } catch {
                completionHandlerForLogOut(false, nil, "The data returned has a problem. Try again.")
                return
            }
            
            guard let session = parsedResult["session"] as? [String: AnyObject] else {
                completionHandlerForLogOut(false, nil, "The data returned has a problem. Try again.")
                return
            }
            
            guard let id = session["id"] as? String else {
                completionHandlerForLogOut(false, nil, "The data returned has a problem. Try again.")
                return
            }
            
            completionHandlerForLogOut(true, id, nil)
        }

        return task
    }
    
    func reset() {
        OTHClient.sharedInstance().sessionID = nil
        OTHClient.sharedInstance().userID = nil
    }
    
}
