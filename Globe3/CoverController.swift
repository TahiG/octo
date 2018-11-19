//
//  CoverController.swift
//  Globe
//
//  Created by Charles Masson on 29/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse

class CoverController : UIViewController {
    
    @IBOutlet var iv : UIImageView!
    
    var img : UIImage!
    var bookId : String!
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Search"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CoverController.back(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        iv.frame.origin = CGPoint(x: PERC_BlackWidth, y: 64 + PERC_BlueHeight)
        if img != nil {
            showImage()
        } else {
            if bookId != nil {
                imageFromParse()
            } else {
                let alert = UIAlertController(title: "Cover", message: "The cover could not be loaded.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showImage() {
        let width = screenWidth - 2 * PERC_BlackWidth
        let imgWidth = img.size.width
        let imgHeight = img.size.height
        let ratio = imgHeight / imgWidth
        iv.frame.size = CGSize(width: width, height: width * ratio)
        iv.image = img
        iv.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    func imageFromParse() {
        let query = PFQuery(className: "Book")
        query.whereKey("objectId", equalTo: bookId)
        query.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                let dat = object?.objectForKey("cover") as! PFFile
                dat.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in
                    if (error != nil) {
                        print (error?.localizedDescription as Any)
                    }
                    else {
                        self.img = UIImage(data: imageData!)
                        self.showImage()
                    }
                })
                
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func back(sender : UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(false)
    }
}
