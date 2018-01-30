//
//  RCHttp.swift
//
//  Created by Baluta Cristian on 08/08/2014.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

class RCHttp {
	
    var baseURL: URL! = nil
	private var task: URLSessionTask?
    private var user: String?
    private var password: String?
	
	convenience init (baseURL: String) {
		self.init()
		self.baseURL = URL(string: baseURL)
	}
    
    func authenticate (user: String, password: String) {
        self.user = user
        self.password = password
    }
	
    
    func get (at path: String, success: @escaping (Any) -> Void, failure: @escaping ([String: Any]) -> Void) {
        
        guard baseURL != nil else {
            print("URL was not set")
            failure([:])
            return
        }
        let fullPath = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!
        let url = URL(string: fullPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Authenticate
        if let user = self.user, let password = self.password {
            let loginData = "\(user):\(password)".data(using: String.Encoding.utf8)!
            let base64LoginData = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpStatus = response as? HTTPURLResponse, let data = data, error == nil else {
                print("GET \(url) -> \(error!)")
                failure([:])
                return
            }
            print("status code = \(httpStatus.statusCode)")
//            print(String(data: data, encoding: String.Encoding.utf8))
            if let d = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
                success(d)
            } else {
                print("Not a valid json for url \(url)")
                failure([:])
            }
//            print(data)
//            if let httpStatus = response as? HTTPURLResponse {
//                // check status code returned by the http server
//                print("status code = \(httpStatus.statusCode)")
//                // process result
//
//            }
        }
        task.resume()
    }
	
	//pragma mark post data sync and async

    func post (at path: String, parameters: [String: Any], success: @escaping (NSDictionary) -> Void, failure: @escaping (NSDictionary) -> Void) {
	
		var postStr = ""
		for (key, vale) in parameters {
			postStr = "\(postStr)\(key)=\(vale)&"
		}
		
		let postData = postStr.data(using: String.Encoding.ascii, allowLossyConversion: true)!
		let postLength = String (postData.count)
		
		let request = NSMutableURLRequest()
		request.url = baseURL
		request.httpMethod = "POST"
		request.setValue(postLength, forHTTPHeaderField: "Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.httpBody = postData
		
		let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
		task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
			
			// notice that I can omit the types of data, response and error
			
//			RCLogO( NSString(data:data, encoding: 0));

			if error == nil {
				var json: NSDictionary = ["text": "Json parse error"]
				if let d = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) {
					json = d as! NSDictionary
				}
				success(json)
			}
			else {
				failure(["text": "Download error"])
			}
		})
		task?.resume()
	}
	
	func upload (data: Data, filename: String, completion: @escaping (NSDictionary) -> Void, error: @escaping (NSDictionary) -> Void) {
		
		let request = NSMutableURLRequest()
		request.url = baseURL
		request.httpMethod = "POST"
//		request.setValue(postLength, forHTTPHeaderField:"Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
//		request.HTTPBody = postData
		
		let session = URLSession( configuration: URLSessionConfiguration.ephemeral)
		task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data_, response_, error_) -> Void in
			var json :NSDictionary? = nil;
			
			if (error_ != nil) {
				let e: NSErrorPointer? = nil
				var response_dict: Any?
				do {
					response_dict = try JSONSerialization.jsonObject(with: data_!, options: JSONSerialization.ReadingOptions.allowFragments)
				} catch _ as NSError {
//					e??.memory = error
					response_dict = nil
				} catch {
					fatalError()
				};
				//				println(response_dict);
				if (e! == nil) {
					json = ["text": "Json parse error"]
				}
				else {
					json = response_dict as? NSDictionary
				}
				completion(json!);
			}
			error(["text": "Download error"])
		})
		task?.resume()
	}
	
	func cancel () {
		task?.cancel()
	}
	
	func downloadStarted () {
#if os(iOS)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
#endif
	}
	
	func downloadEnded () {
#if os(iOS)
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
#endif
	}
}
