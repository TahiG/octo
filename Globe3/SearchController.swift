//
//  SearchController.swift
//  Globe3
//
//  Created by Charles Masson on 28/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse

class SearchController : UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet var vHeader : UIView!
    @IBOutlet var ivSearch : UIImageView!
    @IBOutlet var ivCancel : UIImageView!
    @IBOutlet var bCancel : UIButton!
    @IBOutlet var tfSearch : UITextField!
    @IBOutlet var vBelowSearchField : UIView!
    @IBOutlet var bMyCollec : UIButton!
    @IBOutlet var bLibrary : UIButton!
    @IBOutlet var scResults : UIScrollView!
    
    var searchInMyCollec = false
    var dic = Dictionary<String, UIImage>()
    
    var queryBookName : PFQuery!
    var queryBookNameMyCollec : PFQuery!
    var querySuggestions : PFQuery!
    
    let blueBackGround = UIColor(red: 245/255, green: 246/255, blue: 253/255, alpha: 1.0)
    let redBackGround = UIColor(red: 255/255, green: 235/255, blue: 232/255, alpha: 1.0)
    let heightResult = 2 * PERC_BlueHeight + PERC_SearchCoverHeight
    let bookNameFont = UIFont(name: "MuseoSans-700", size: 17.5)
    let authorNameFont = UIFont(name: "MuseoSans-700", size: 12.5)
    let fontColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1.0)
    var blue = true
    
    var searchSuggestions = NSMutableArray()
    var searchSuggestionsObjects = NSMutableArray()
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Search"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SearchController.back(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        
        queryBookName = PFQuery(className:"Book")
        queryBookNameMyCollec = PFQuery(className: "Book")
        querySuggestions = PFQuery(className: "Book")
        
        vHeader.frame.origin.x = 0.0
        vHeader.frame.origin.y = 64.0
        vHeader.frame.size.height = PERC_SearchHeight + PERC_ButtonBelowSearchHeight + 3 * PERC_YellowHeight
        vHeader.frame.size.width = screenWidth
        
        vBelowSearchField.frame.size.width = PERC_SearchWidth
        vBelowSearchField.frame.size.height = PERC_SearchHeight
        vBelowSearchField.frame.origin.x = PERC_SearchMargin
        vBelowSearchField.frame.origin.y = PERC_YellowHeight
        vBelowSearchField.layer.cornerRadius = PERC_SearchHeight / 2
        vBelowSearchField.layer.borderColor = UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1).CGColor
        vBelowSearchField.layer.borderWidth = 1.0
        
        ivSearch.frame.size.width = 17
        ivSearch.frame.size.height = 17
        ivSearch.frame.origin.x = 18 / 2
        ivSearch.frame.origin.y = 18 / 2
        
        //bSearch.frame = ivSearch.frame
        
        ivCancel.frame = ivSearch.frame
        ivCancel.frame.origin.x = screenWidth - ivSearch.frame.size.width - 2 * PERC_SearchMargin - 18 / 2
        
        bCancel.frame = ivCancel.frame
        
        tfSearch.frame.origin.x = CGRectGetMaxX(ivSearch.frame) + PERC_BlackWidth
        tfSearch.frame.origin.y = 0.0
        tfSearch.frame.size.height = vBelowSearchField.frame.size.height
        tfSearch.frame.size.width = CGRectGetMinX(ivCancel.frame) - CGRectGetMaxX(ivSearch.frame) - 2 * PERC_BlackWidth
        tfSearch.returnKeyType = UIReturnKeyType.Search
        tfSearch.delegate = self
        
        bMyCollec.frame.origin.y = CGRectGetMaxY(vBelowSearchField.frame) + PERC_YellowHeight
        bMyCollec.frame.origin.x = PERC_SearchMargin
        bMyCollec.frame.size.height = PERC_ButtonBelowSearchHeight
        bMyCollec.frame.size.width = PERC_SearchWidth / 2
        
        
        let leftCornersPath = UIBezierPath(roundedRect: bMyCollec.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.BottomLeft], cornerRadii: CGSize(width: 25.0 / 2.0, height: 25.0 / 2.0))
        let leftCornersLayer = CAShapeLayer()
        
        leftCornersLayer.frame = bMyCollec.bounds
        leftCornersLayer.path = leftCornersPath.CGPath
        bMyCollec.layer.mask = leftCornersLayer
        
        let frameLayer = CAShapeLayer()
        frameLayer.frame = bMyCollec.bounds
        frameLayer.path = leftCornersPath.CGPath
        frameLayer.strokeColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0).CGColor
        frameLayer.fillColor = nil
        bMyCollec.layer.addSublayer(frameLayer)
        
        
        bLibrary.frame = bMyCollec.frame
        bLibrary.frame.origin.x = halfScreenWidth
        
        let rightCornersPath = UIBezierPath(roundedRect: bLibrary.bounds, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.BottomRight], cornerRadii: CGSize(width: 25.0 / 2.0, height: 25.0 / 2.0))
        let rightCornersLayer = CAShapeLayer()
        
        rightCornersLayer.frame = bLibrary.bounds
        rightCornersLayer.path = rightCornersPath.CGPath
        bLibrary.layer.mask = rightCornersLayer
        
        let vBlackLine = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(vHeader.frame), width: screenWidth, height: 1.0))
        vBlackLine.backgroundColor = UIColor.blackColor()
        self.view.addSubview(vBlackLine)
        
        scResults.frame.origin.x = 0.0
        scResults.frame.origin.y = CGRectGetMaxY(vBlackLine.frame) - 64
        scResults.frame.size.width = screenWidth
        scResults.frame.size.height = screenHeight - vBlackLine.frame.size.height - 64
        scResults.backgroundColor = UIColor(red: 239/255, green: 237/255, blue: 237/255, alpha: 1.0)
        scResults.delegate = self
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func search() {
        //Constants
        let searchedText = tfSearch.text!
        //Query
        queryBookName.whereKey("cname", containsString: searchedText.lowercaseString)
        queryBookName.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) books.")
                var counter = 0
                if let objects = objects {
                    for object in objects {
                        /*dispatch_async(dispatch_get_main_queue(), {
                            self.buildViewFromPFObject(object, c: counter)
                        })*/
                        self.buildViewFromPFObject(object, c: counter)
                        counter += 1
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func searchMyCollec() {
        let u = PFUser.currentUser()
        if u != nil {
            var counter = 0
            if let arrWish = u?.objectForKey("wishlist") as? NSArray {
                for id in arrWish {
                    let q = PFQuery(className: "Book")
                    q.whereKey("objectId", equalTo: id)
                    q.whereKey("cname", containsString: tfSearch.text!.lowercaseString)
                    q.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
                            print("Successfully retrieved \(objects!.count) books.")
                            //var counter = 0
                            if let objects = objects {
                                for object in objects {
                                    /*dispatch_async(dispatch_get_main_queue(), {
                                    self.buildViewFromPFObject(object, c: counter)
                                    })*/
                                    self.buildViewFromPFObject(object, c: counter)
                                    counter += 1
                                }
                            }
                        } else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                    }
                    /*queryBookNameMyCollec.whereKey("objectId", equalTo: id as! String)
                    do {
                        let o = try queryBookNameMyCollec.getFirstObject()
                        buildViewFromPFObject(o, c: counter)
                        counter++
                    } catch {
                        print("Error getting first obj")
                    }*/
                    /*let o = queryBookNameMyCollec.getFirstObject()
                    if o != nil {
                        buildViewFromPFObject(o, c: counter)
                        counter++
                    }*/
                }
                searchForCurrentlyReading(u!, counter: counter)
            } else {
                searchForCurrentlyReading(u!, counter: counter)
            }
        }
    }
    
    func searchForCurrentlyReading(u : PFUser, counter : Int) {
        if let arrCurr = u.objectForKey("currentlyreading") as? NSArray {
            var c = counter
            for id in arrCurr {
                let q = PFQuery(className: "Book")
                q.whereKey("objectId", equalTo: id)
                q.whereKey("cname", containsString: tfSearch.text!.lowercaseString)
                q.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) books.")
                        //var counter = 0
                        if let objects = objects {
                            for object in objects {
                                /*dispatch_async(dispatch_get_main_queue(), {
                                self.buildViewFromPFObject(object, c: counter)
                                })*/
                                self.buildViewFromPFObject(object, c: c)
                                c += 1
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
                /*queryBookNameMyCollec.whereKey("objectId", equalTo: id as! String)
                do {
                    let o = try queryBookNameMyCollec.getFirstObject()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.buildViewFromPFObject(o, c: counter)
                    })
                    //buildViewFromPFObject(o, c: counter)
                    counter++
                } catch {
                    print("Error getting first obj")
                }*/
                /*let o = queryBookNameMyCollec.getFirstObject()
                if o != nil {
                    buildViewFromPFObject(o, c: counter)
                    counter++
                }*/
            }
        }
    }
    
    func buildViewFromPFObject(o : PFObject?, c : Int) {
        let bID = o!.objectId!
        //We create a view for each book
        let vResult = UIView(frame: CGRect(x: 0.0, y: CGFloat(c) * heightResult, width: screenWidth, height: heightResult))
        let ivCover = UIImageView(frame: CGRect(x: PERC_BlackWidth, y: PERC_BlueHeight, width: PERC_SearchCoverWidth, height: PERC_SearchCoverHeight))
        let lName = UILabel(frame: CGRect(x: CGRectGetMaxX(ivCover.frame) + PERC_BlackWidth, y: PERC_BlueHeight, width: 1.0, height: 1.0))
        lName.font = bookNameFont
        lName.text = "name"
        lName.textColor = fontColor
        lName.sizeToFit()
        let lAuthor = UILabel(frame: CGRect(x: CGRectGetMaxX(ivCover.frame) + PERC_BlackWidth, y: CGRectGetMaxY(lName.frame), width: 1.0, height: 1.0))
        lAuthor.font = authorNameFont
        lAuthor.text = "author"
        lAuthor.textColor = fontColor
        lAuthor.sizeToFit()
        let lDate = UILabel(frame: CGRect(x: CGRectGetMaxX(ivCover.frame) + PERC_BlackWidth, y: CGRectGetMaxY(lAuthor.frame) + 5, width: 1.0, height: 1.0))
        lDate.font = authorNameFont
        lDate.text = ""
        lDate.textColor = fontColor
        lDate.sizeToFit()
        
        vResult.addSubview(ivCover)
        vResult.addSubview(lName)
        vResult.addSubview(lAuthor)
        vResult.addSubview(lDate)
        //We need the cover
        if let uProfilePict = o!.objectForKey("cover") as? PFFile {
            uProfilePict.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    let img = UIImage(data: data!)
                    ivCover.image = img
                    self.dic[bID] = img
                } else {
                    print(error)
                }
            })
        }
        //The name of the book
        if let bName = o!.objectForKey("name") as? String {
            lName.text = bName
            lName.sizeToFit()
        } else {
            print("didnt retieve name of the book")
        }
        //The author of the book
        if let bAuthor = o!.objectForKey("author") as? String {
            lAuthor.text = bAuthor
            lAuthor.sizeToFit()
        } else {
            print("didnt retieve author of the book")
        }
        //The date of the book
        if let bDate = o!.objectForKey("releasedate") as? String {
            lDate.text = bDate
            lDate.sizeToFit()
        } else {
            print("didnt retieve date of the book")
        }
        //The id to go to book description
        let b = UIButton(frame: vResult.frame)
        b.frame.origin.x = 0
        b.frame.origin.y = 0
        b.setTitle(bID, forState: UIControlState.Normal)
        b.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        b.addTarget(self, action: #selector(SearchController.resultClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        vResult.addSubview(b)
        vResult.backgroundColor = blue ? blueBackGround : redBackGround
        blue = !blue
        self.scResults.addSubview(vResult)
        self.scResults.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(vResult.frame))
    }
    
    @IBAction func userIsTyping(sender : UITextField) {
        querySuggestions.cancel()
        querySuggestions.clearCachedResult()
        queryBookName.cancel()
        queryBookName.clearCachedResult()
        for v in scResults.subviews {
            v.removeFromSuperview()
        }
        if !searchInMyCollec {
            search()
        } else {
            searchMyCollec()
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(tf: UITextField) -> Bool {
        self.view.endEditing(true)
        if tf == self.tfSearch {
            if searchInMyCollec {
                queryBookNameMyCollec.cancel()
                queryBookNameMyCollec.clearCachedResult()
                for v in scResults.subviews {
                    v.removeFromSuperview()
                }
                searchMyCollec()
            } else {
                queryBookName.cancel()
                queryBookName.clearCachedResult()
                for v in scResults.subviews {
                    v.removeFromSuperview()
                }

                search()
            }
        }
        return true
    }
    
    @IBAction func resultClicked(sender : UIButton) {
        let id = sender.titleLabel!.text
        //var vcs = self.navigationController!.viewControllers
        //var newVCs = NSMutableArray()
        let bookDesc : BookDescriptionController = storyboard!.instantiateViewControllerWithIdentifier("bookdescription") as! BookDescriptionController
        bookDesc.bookId = id
        bookDesc.bookCover = dic[id!]
        self.navigationController?.pushViewController(bookDesc, animated: true)
        /*newVCs.addObject(vcs[0])
        newVCs.addObject(bookDesc)
        self.navigationController?.setViewControllers(newVCs as [AnyObject], animated: false)*/
    }
    
    @IBAction func myCollecClicked(sender : UIButton) {
        if !searchInMyCollec {
            searchInMyCollec = true
            
            bMyCollec.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0)
            bMyCollec.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            bLibrary.backgroundColor = UIColor.whiteColor()
            bLibrary.setTitleColor(UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0), forState: UIControlState.Normal)
            
            let leftCornersPath = UIBezierPath(roundedRect: bMyCollec.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.BottomLeft], cornerRadii: CGSize(width: 25.0 / 2.0, height: 25.0 / 2.0))
            let leftCornersLayer = CAShapeLayer()
            
            leftCornersLayer.frame = bMyCollec.bounds
            leftCornersLayer.path = leftCornersPath.CGPath
            bMyCollec.layer.mask = leftCornersLayer
            
            let rightCornersPath = UIBezierPath(roundedRect: bLibrary.bounds, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.BottomRight], cornerRadii: CGSize(width: 25.0 / 2.0, height: 25.0 / 2.0))
            let rightCornersLayer = CAShapeLayer()
            
            rightCornersLayer.frame = bLibrary.bounds
            rightCornersLayer.path = rightCornersPath.CGPath
            bLibrary.layer.mask = rightCornersLayer
            
            let frameLayer = CAShapeLayer()
            frameLayer.frame = bLibrary.bounds
            frameLayer.path = rightCornersPath.CGPath
            frameLayer.strokeColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0).CGColor
            frameLayer.fillColor = nil
            bLibrary.layer.addSublayer(frameLayer)
            
            if tfSearch.text != "" {
                queryBookNameMyCollec.cancel()
                queryBookNameMyCollec.clearCachedResult()
                queryBookName.cancel()
                queryBookName.clearCachedResult()
                for v in scResults.subviews {
                    v.removeFromSuperview()
                }
                searchMyCollec()
            }
        }
    }
    
    @IBAction func libClicked(sender : UIButton) {
        if searchInMyCollec {
            searchInMyCollec = false
            
            bLibrary.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0)
            bLibrary.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            bMyCollec.backgroundColor = UIColor.whiteColor()
            bMyCollec.setTitleColor(UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0), forState: UIControlState.Normal)
            
            let leftCornersPath = UIBezierPath(roundedRect: bMyCollec.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.BottomLeft], cornerRadii: CGSize(width: 25.0 / 2.0, height: 25.0 / 2.0))
            let leftCornersLayer = CAShapeLayer()
            
            leftCornersLayer.frame = bMyCollec.bounds
            leftCornersLayer.path = leftCornersPath.CGPath
            bMyCollec.layer.mask = leftCornersLayer
            
            let frameLayer = CAShapeLayer()
            frameLayer.frame = bMyCollec.bounds
            frameLayer.path = leftCornersPath.CGPath
            frameLayer.strokeColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1.0).CGColor
            frameLayer.fillColor = nil
            bMyCollec.layer.addSublayer(frameLayer)
            
            
            let rightCornersPath = UIBezierPath(roundedRect: bLibrary.bounds, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.BottomRight], cornerRadii: CGSize(width: 25.0 / 2.0, height: 25.0 / 2.0))
            let rightCornersLayer = CAShapeLayer()
            
            rightCornersLayer.frame = bLibrary.bounds
            rightCornersLayer.path = rightCornersPath.CGPath
            bLibrary.layer.mask = rightCornersLayer
            
            if tfSearch.text != "" {
                queryBookName.cancel()
                queryBookName.clearCachedResult()
                queryBookNameMyCollec.cancel()
                queryBookNameMyCollec.clearCachedResult()
                for v in scResults.subviews {
                    v.removeFromSuperview()
                }
                search()
            }
            
        }
    }
    
    @IBAction func cancelClicked(sender : UIButton) {
        self.tfSearch.text = ""
    }
    
    @IBAction func searchClicked(sender : UIButton) {
        if searchInMyCollec {
            searchMyCollec()
        } else {
            search()
        }
        
    }
    
    @IBAction func back(sender : UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
