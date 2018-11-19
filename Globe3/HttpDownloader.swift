//
//  HttpDownloader.swift
//  Globe
//
//  Created by Amarjit on 01/03/2017.
//  Copyright © 2017 Charles Masson. All rights reserved.
//

import Foundation

class HttpDownloader {

    class func loadFileSync(url: NSURL, completion:(path:NSURL?, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)

        if NSFileManager().fileExistsAtPath(destinationUrl!.path!) {
            print("file already exists [\(destinationUrl!.path!)]")
            completion(path: destinationUrl!, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl!, atomically: true) {
                print ("Saved to \(destinationUrl!)")
                completion(path: destinationUrl!, error:nil)
            } else {
                let error = NSError(domain:"Error saving file", code:10099, userInfo:nil)
                completion(path: nil, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path:nil, error:error)
        }
    }

    class func loadFileAsync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl!.path!) {
            print("file already exists [\(destinationUrl!.path!)]")
            completion(path: destinationUrl!.path!, error:nil)
        } else {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"


            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if (error == nil) {
                    if let response = response as? NSHTTPURLResponse {
                        print("response=\(response)")
                        if response.statusCode == 200 {
                            if data!.writeToURL(destinationUrl!, atomically: true) {
                                print("file saved [\(destinationUrl!.path!)]")
                                completion(path: destinationUrl!.path!, error:error)
                            } else {
                                let error = NSError(domain:"Error saving file", code:1100, userInfo:nil)
                                completion(path: destinationUrl!.path!, error:error)
                            }
                        }
                    }
                }
                else {
                    print("Failure: \(error!.localizedDescription)");
                    completion(path: destinationUrl!.path!, error:error)
                }
            })
            task.resume()
        }
    }
}
