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
	
	var url: String?
	var task: URLSessionTask?
	
	convenience init (baseURL: String, endpoint: String?) {
		self.init()
		let separator = endpoint != nil ? "/" : ""
		let end = endpoint != nil ? endpoint : ""
		url = String("\(baseURL)\(separator)\(end!)")
	}
    
    func authenticate (user: String, password: String) {
        
    }
	
	
	//pragma mark post data sync and async

	func post (dictionary: Dictionary<String, AnyObject>, completion: @escaping (NSDictionary) -> Void, errorHandler: @escaping (NSDictionary) -> Void) {
	
		var postStr = ""
		for (key, vale) in dictionary {
			postStr = "\(postStr)\(key)=\(vale)&"
		}
		
		let postData = postStr.data(using: String.Encoding.ascii, allowLossyConversion: true)!
		let postLength = String (postData.count)
		
		let request = NSMutableURLRequest()
		request.url = URL(string: url!)
		request.httpMethod = "POST"
		request.setValue(postLength, forHTTPHeaderField: "Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.httpBody = postData
		
		let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
		task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
			
			// notice that I can omit the types of data, response and error
			
//			RCLogO( NSString(data:data, encoding: 0));

			if (error == nil) {
				var json: NSDictionary = ["text":"Json parse error"]
				if let d = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) {
					json = d as! NSDictionary
				}
				completion(json)
			}
			else {
				errorHandler(["text":"Download error"])
			}
		})
		task?.resume()
	}
	
	func upload (data: Data, filename: String, completion: @escaping (NSDictionary) -> Void, error: @escaping (NSDictionary) -> Void) {
		
		let request :NSMutableURLRequest = NSMutableURLRequest()
		request.url = URL(string: url!)
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
			error(["text": "Dwnlad error"])
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
