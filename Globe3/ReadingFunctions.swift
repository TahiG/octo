//
//  ReadingFunctions.swift
//  Globe
//
//  Created by Charles Masson on 29/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import Foundation
import Parse

class ReadingFunctions {
    
    
    class func saveCurrentPage(bookID : String, savepage page : Int) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(page, forKey: "CURRENTPAGEINCHAPTER_IN\(bookID)")
        ud.synchronize()
    }
    
    class func saveCurrentChapter(bookID : String, savechapter chapter : Int) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(chapter, forKey: "CURRENTCHAPTER_IN\(bookID)")
        ud.synchronize()
    }
    
    class func saveInCurrentlyReading(bookID : String) {
        let u = PFUser.currentUser()
        if u != nil {
            if let curr = u?.objectForKey("currentlyreading") as? NSMutableArray {
                var isAlreadyIn = false
                for s in curr {
                    if bookID == s as! String {
                        isAlreadyIn = true
                    }
                }
                if !isAlreadyIn {
                    curr.insertObject(bookID, atIndex: 0)
                    //curr.addObject(bookID)
                    u?.setObject(curr, forKey: "currentlyreading")
                    u?.saveInBackgroundWithBlock{(success, error) -> Void in
                        if error == nil {
                            if success { //All good
                                print("added to currently reading")
                            }
                        } else {
                            print(error)
                        }
                    }
                } else {
                    curr.removeObject(bookID)
                    curr.insertObject(bookID, atIndex: 0)
                    //curr.addObject(bookID)
                    u?.setObject(curr, forKey: "currentlyreading")
                    u?.saveInBackground()
                    
                }
            } else {
                let curr = NSMutableArray()
                curr.addObject(bookID)
                u?.setObject(curr, forKey: "currentlyreading")
                u?.saveInBackgroundWithBlock{(success, error) -> Void in
                    if error == nil {
                        if success {
                            print("added to currently reading")
                        }
                    } else {
                        print(error)
                    }
                }
            }
        }
    }
    
    class func updatePreferDark(userPrefersDark dark : Bool) {
        let ud = NSUserDefaults.standardUserDefaults()//Update the preferences
        ud.setBool(dark, forKey: "PREFERRED_BLACKBACKGROUND")
        ud.synchronize()
    }
    
    /*class func bookNameFromBookId(id : String) -> NSArray {
        let q = PFQuery(className: "Book")
        q.whereKey("objectId", equalTo: id)
        var r : String!
        q.getFirstObjectInBackgroundWithBlock({ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                if let s = object?.objectForKey("name") as? String {
                    r = s
                }
            }
        })
        return ""
    }*/
}