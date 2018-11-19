//
//  Book.swift
//  Globe
//
//  Created by Amarjit on 12/12/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import Foundation
import UIKit
import FolioReaderKit
import UIKit
import ZipArchive
import Parse
import GoogleMobileAds
import MessageUI
import Social

// Book model
public struct Book {
    var bookId: String!
    var bookDir : String!//Directory of epub file
    var bookTitle : String! //Set in ebookfromparse method
    var bookAuthor : String! //Set in ebookfromparse method
    var coverSuffix : String!
    var cover : UIImage! //To go to covercontroller

    public mutating func isBookInDocs() -> Bool {
        let ud = NSUserDefaults.standardUserDefaults()
        return (ud.objectForKey("BOOK_IN_DOCS" + self.bookId) != nil) ? ud.boolForKey("BOOK_IN_DOCS\(self.bookId)") : false
    }

    //Getting the ebook from parse and (below,) parsing ebook content
    public mutating func ebookFromParse(completion:(bookPath:String?, error:NSError?) -> Void)
    {
        // Loading
        print("Loading eBook with ID:\(self.bookId) from parse")

        // Getting ebook data
        let queryBook = PFQuery(className: "Book")
        queryBook.whereKey("objectId", equalTo: self.bookId)
        queryBook.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {

                let epubDocumentPath = object?.objectForKey("epub")!.name

                if let epubPath = epubDocumentPath
                {
                    let ec2BasePath = "https://s3-eu-west-1.amazonaws.com/globeparseserver/"
                    let fullPath = ec2BasePath + epubPath
                    let urlStr : NSString = fullPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    let searchURL : NSURL = NSURL(string: urlStr as String)!

                    print ("Attempting to load URL: \(searchURL)")

                    self.loadFileFromURL(searchURL, completion: { (path, error) in
                        if (error != nil) {
                            print(error?.localizedDescription as Any)
                            completion(bookPath: nil, error: error)
                        }
                        else {
                            if (path != nil)
                            {
                                let ud = NSUserDefaults.standardUserDefaults()
                                ud.setBool(true, forKey: "BOOK_IN_DOCS\(self.bookId)")
                                ud.synchronize()

                                completion(bookPath: path, error: nil)
                            }
                            else {
                                let err: NSError = NSError(domain: "Could not find path to book", code: 0, userInfo: nil)
                                completion(bookPath: nil, error: err)
                            }
                        }
                    })
                }
                else {
                    print ("No epub document path found")
                }

            } else { print(error?.localizedDescription as Any) }
        }
    }


    private mutating func loadFileFromURL(url: NSURL, completion:(path:String?, error:NSError!) -> Void)
    {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(bookId + "-book.epub")
        if let dataFromURL = NSData(contentsOfURL: url)
        {
            if dataFromURL.writeToURL(destinationUrl!, atomically: true) {
                print ("Saved to \(destinationUrl!)")
                completion(path: destinationUrl!.path!, error:nil)
            } else {
                let error = NSError(domain:"Error saving file", code:10199, userInfo:nil)
                completion(path: nil, error:error)
            }
        }
        else {
            let error = NSError(domain:"Error saving file", code:10120, userInfo:nil)
            completion(path: nil, error:error)
        }
    }

}
