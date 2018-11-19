//
//  BookDescriptionController.swift
//  Globe3
//
//  Created by Charles Masson on 03/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import FolioReaderKit

class BookDescriptionController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var ivBook : UIImageView!
    @IBOutlet var lTitle : UILabel!
    @IBOutlet var bRead : UIButton!
    @IBOutlet var bAdd : UIButton!
    @IBOutlet var lAuthor : UILabel!
    @IBOutlet var lDescription : UILabel!
    @IBOutlet var scDetails : UIScrollView!
    @IBOutlet var lPublisherTitle : UILabel!
    @IBOutlet var lPublisher : UILabel!
    @IBOutlet var lReleaseTitle : UILabel!
    @IBOutlet var lRelease : UILabel!
    @IBOutlet var lISBNTitle : UILabel!
    @IBOutlet var lISBN : UILabel!
    @IBOutlet var vMoreContainer : UIView!
    @IBOutlet var lMore : UILabel!
    @IBOutlet var scMore : UIScrollView!
    @IBOutlet var lAlsoLike : UILabel!
    @IBOutlet var scAlsoLike : UIScrollView!
    @IBOutlet var vAddToWishList : UIView!
    @IBOutlet var bAddToWishList : UIButton!
    
    var activityIndicator : UIActivityIndicatorView!
    var bookId : String!
    var bookCover : UIImage!
    
    var originY : CGFloat!
    
    var detailsUp = false
    
    var panUp : UIPanGestureRecognizer!
    var touch : UITapGestureRecognizer!
    var touchIV : UITapGestureRecognizer!
    var swipeSCUp : UISwipeGestureRecognizer!
    
    var defaultGR = []
    
    var bookTitle : String!
    var bookAuthor : String!
    
    var addToWishListBoxVisible = false
    
    var hv : HelpView!
    
    override func viewDidLoad() {
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(BookDescriptionController.barButtonToSearch(_:)))
        searchButton.tintColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem = searchButton
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        scDetails.frame.origin.x = 0.0
        scDetails.frame.origin.y = 0
        scDetails.frame.size.width = screenWidth
        scDetails.frame.size.height = screenHeight// - 64 - PERC_PurpleHeight - PERC_BlackWidth
        scDetails.delegate = self
        buildDetailsViews(AlmostFullWidth)
        
        let ud = NSUserDefaults.standardUserDefaults()
        if let firstTime = ud.objectForKey("FIRSTTIME_DESCRIPTION") as? Bool {
            if firstTime {
                makeHV(ud)
            }
        } else {
            makeHV(ud)
        }
        
        getDetails()//(from Parse)
        checkIfBookIsInWishlist()
    }
    
    func makeHV(ud : NSUserDefaults) {
        hv = HelpView(text: "Add a book to your private wishlist or open to start reading.")
        hv.center = self.view.center
        UIApplication.sharedApplication().keyWindow!.addSubview(hv)
        ud.setBool(false, forKey: "FIRSTTIME_DESCRIPTION")
        ud.synchronize()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        hvDisappear()
    }
    
    
    @IBAction func readClicked(sender : UIButton) {
        var book: Book = Book()
        book.bookId = self.bookId
        ///book.cover = (sender.view! as! UIImageView).image // doesn't work

        self.addActivityIndicator()
        FolioHelper.preload(book) { (bookPath, error) in
            self.removeActivityIndicator()
            if (error != nil) {
                print (error?.localizedDescription as Any)
            }
            else{
                if let path = bookPath {
                    print ("Attempting to open eBook at path: \(bookPath)")
                    dispatch_async(dispatch_get_main_queue(), {
                        let config = FolioReaderConfig()
                        FolioReader.presentReader(parentViewController: self, withEpubPath: path, andConfig: config, shouldRemoveEpub: true, animated: true)
                    })
                }
                else {
                    print ("Error: Unable to open ebook")
                }
            }
        }


        // OLD CODE - NOT USED
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc : ReadingWithBannerController = storyboard.instantiateViewControllerWithIdentifier("readingwithbanner") as! ReadingWithBannerController
         vc.bookId = self.bookId
         vc.bookTitle = bookTitle
         vc.bookAuthor = bookAuthor
         self.navigationController?.pushViewController(vc, animated: true)
         */
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hvDisappear()
    }
    
    func getDetails(){
        let query = PFQuery(className:"Book")
        query.whereKey("objectId", equalTo: self.bookId)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if let uProfilePict = object.objectForKey("cover") as? PFFile {
                            uProfilePict.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let img = UIImage(data: data!)
                                        self.ivBook.image = img
                                    })
                                } else {
                                    print(error)
                                }
                            })
                        }
                        if let tit = object.objectForKey("name") as? String {
                            self.lTitle.text = " \(tit.uppercaseString)"
                            self.bookTitle = tit
                        } else {
                            self.lTitle.text = "..."
                        }
                        if let aut = object.objectForKey("author") as? String {
                            self.lAuthor.text = "by \(aut.uppercaseString)"
                            self.lMore.text = "More \(aut) Books"
                            self.buildScrollViewSameAuthor(aut)
                            self.bookAuthor = aut
                        } else {
                            self.lAuthor.text = "..."
                        }
                        if let des = object.objectForKey("description") as? String {
                            self.lDescription.text = des
                        } else {
                            self.lDescription.text = "Well this is embarrassing... I'm sure there was a synopsis around here somewhere!"
                        }
                        if let pub = object.objectForKey("publisher") as? String {
                            self.lPublisher.text = pub
                        } else {
                            self.lPublisher.text = ""
                            self.lPublisher.hidden = true
                            self.lPublisherTitle.hidden = true
                        }
                        if let rel = object.objectForKey("releasedate") as? String {
                            self.lRelease.text = rel
                        } else {
                            self.lRelease.text = ""
                            self.lRelease.hidden = true
                            self.lReleaseTitle.hidden = true
                        }
                        if let isbn = object.objectForKey("ISBN") as? String {
                            self.lISBN.text = isbn
                        } else {
                            self.lISBN.text = ""
                            self.lISBN.hidden = true
                            self.lISBNTitle.hidden = true
                        }
                        self.buildDetailsViews(screenWidth - 2 * PERC_BlackWidth)
                        if let arrSimilar = object.objectForKey("similar") as? NSArray {
                            self.buildScrollViewSimilar(arrSimilar)
                        } else {
                            print("no similar books found")
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func buildDetailsViews(ivWidth : CGFloat){
        lTitle.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_BlueHeight)
        lTitle.sizeToFit()
        lTitle.frame.size.width = AlmostFullWidth
        lTitle.frame.size.height += 10
        lAuthor.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_RedHeight + CGRectGetMaxY(lTitle.frame))
        lAuthor.sizeToFit()
        lAuthor.frame.size.width += 10
        lAuthor.frame.size.height += 7
        
        ivBook.frame.size.width = AlmostFullWidth
        ivBook.frame.size.height = AlmostFullWidth * 1.5//* 1.5526
        ivBook.frame.origin.y = PERC_DarkRedHeight + CGRectGetMaxY(lAuthor.frame)//PERC_BlueHeight + 64
        ivBook.frame.origin.x = PERC_BlackWidth
        if bookCover != nil {
            ivBook.image = bookCover
        }
        //defaultGR = scDetails.gestureRecognizers!
        scDetails.scrollEnabled = true
        //scDetails.delegate = self
        
        bAdd.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_DarkRedHeight + CGRectGetMaxY(ivBook.frame))
        bAdd.sizeToFit()
        bAdd.frame.size.width += 22
        bAdd.layer.borderColor = bRead.backgroundColor?.CGColor
        bAdd.addTarget(self, action: #selector(BookDescriptionController.addToWishList(_:)), forControlEvents: .TouchUpInside)
        bRead.sizeToFit()
        bRead.frame.size.width += 22
        bRead.frame.origin = CGPoint(x: screenWidth - PERC_BlackWidth - bRead.frame.size.width, y: bAdd.frame.origin.y)
        
        
        lDescription.frame.origin.y = PERC_DarkRedHeight + CGRectGetMaxY(bRead.frame)
        lDescription.frame.origin.x = PERC_BlackWidth
        lDescription.sizeToFit()
        lDescription.frame.size.width = AlmostFullWidth
        
        lPublisherTitle.frame.origin.y = CGRectGetMaxY(lDescription.frame) + PERC_BlueHeight + PERC_YellowHeight
        lPublisherTitle.frame.origin.x = PERC_BlackWidth
        lPublisherTitle.sizeToFit()
        
        lPublisher.frame.origin.y = lPublisherTitle.frame.origin.y
        lPublisher.frame.origin.x = CGRectGetMaxX(lPublisherTitle.frame)
        lPublisher.frame.size.width = AlmostFullWidth - lPublisherTitle.frame.size.width
        lPublisher.sizeToFit()
        
        lReleaseTitle.frame.origin.y = CGRectGetMaxY(lPublisher.frame)// + PERC_BlueHeight
        lReleaseTitle.frame.origin.x = PERC_BlackWidth
        lReleaseTitle.sizeToFit()
        
        lRelease.frame.origin.y = lReleaseTitle.frame.origin.y
        lRelease.frame.origin.x = CGRectGetMaxX(lReleaseTitle.frame)
        lRelease.frame.size.width = AlmostFullWidth - lReleaseTitle.frame.size.width
        lRelease.sizeToFit()
        
        lISBNTitle.frame.origin.y = CGRectGetMaxY(lRelease.frame)// + PERC_BlueHeight
        lISBNTitle.frame.origin.x = PERC_BlackWidth
        lISBNTitle.sizeToFit()
        
        lISBN.frame.origin.y = lISBNTitle.frame.origin.y
        lISBN.frame.origin.x = CGRectGetMaxX(lISBNTitle.frame)
        lISBN.frame.size.width = AlmostFullWidth - lISBNTitle.frame.size.width
        lISBN.sizeToFit()
        
        vMoreContainer.frame.origin.y = CGRectGetMaxY(lISBN.frame) + PERC_BlueHeight
        vMoreContainer.frame.origin.x = PERC_BlackWidth
        vMoreContainer.frame.size.width = AlmostFullWidth
        
        scMore.frame.origin.x = 0.0
        scMore.frame.origin.y = PERC_GreenHeight
        scMore.frame.size.height = PERC_LibCoverHeight
        scMore.frame.size.width = AlmostFullWidth
        
        lMore.frame.origin.x = PERC_DarkRedWidth
        lMore.sizeToFit()
        lMore.frame.origin.y = PERC_GreenHeight - PERC_YellowHeight - lMore.frame.size.height
        
        scAlsoLike.frame.origin.x = 0.0
        scAlsoLike.frame.origin.y = CGRectGetMaxY(scMore.frame) + PERC_GreenHeight
        scAlsoLike.frame.size.height = PERC_LibCoverHeight
        scAlsoLike.frame.size.width = AlmostFullWidth
        
        lAlsoLike.frame.origin.x = PERC_DarkRedWidth
        lAlsoLike.sizeToFit()
        lAlsoLike.frame.origin.y = CGRectGetMinY(scAlsoLike.frame) - PERC_YellowHeight - lAlsoLike.frame.size.height
        
        vMoreContainer.frame.size.height = CGRectGetMaxY(scAlsoLike.frame) + PERC_DarkRedWidth
        scDetails.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(vMoreContainer.frame) + PERC_BlackWidth)
    }
    
    func replaceViewsProperly(){
        lPublisherTitle.frame.origin.y = CGRectGetMaxY(lDescription.frame) + PERC_BlueHeight
        lPublisher.frame.origin.y = lPublisherTitle.frame.origin.y
        lReleaseTitle.frame.origin.y = CGRectGetMaxY(lPublisher.frame)// + PERC_BlueHeight
        lRelease.frame.origin.y = lReleaseTitle.frame.origin.y
        lISBNTitle.frame.origin.y = CGRectGetMaxY(lRelease.frame)// + PERC_BlueHeight
        lISBN.frame.origin.y = lISBNTitle.frame.origin.y
        vMoreContainer.frame.origin.y = CGRectGetMaxY(lISBN.frame) + PERC_BlueHeight
    }
    
    func sizeToFitTitle(){
        lTitle.sizeToFit()
        lTitle.frame.size.width += 10
        lTitle.frame.size.height += 10
    }
    
    func sizeToFitAuthor(){
        lAuthor.sizeToFit()
        lAuthor.frame.size.width += 5
        lAuthor.frame.size.height += 5
    }
    
    func buildScrollViewSameAuthor(a : String) {
        var counter = 0
        let query = PFQuery(className: "Book")
        query.whereKey("author", equalTo: a)
        query.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for o in objects {
                        if o.objectId != self.bookId { //We don't wanna show current book in 'same author' section
                            let dat = o.objectForKey("cover") as! PFFile
                            dat.getDataInBackgroundWithBlock({
                                (imageData: NSData?, error: NSError?) -> Void in

                                if (error != nil) {
                                    print (error?.localizedDescription as Any)
                                }
                                else {
                                    let iv = UIImageView(image: UIImage(data: imageData!))
                                    iv.frame.size.width = PERC_LibCoverWidth
                                    iv.frame.size.height = PERC_LibCoverHeight
                                    iv.frame.origin.y = 0
                                    iv.frame.origin.x = PERC_DarkRedWidth + CGFloat(counter) * (PERC_DarkRedWidth + PERC_LibCoverWidth)
                                    iv.userInteractionEnabled = true
                                    let b = UIButton(frame: CGRect(x: 0, y: 0, width: PERC_LibCoverWidth, height: PERC_LibCoverHeight))
                                    b.addTarget(self, action: #selector(BookDescriptionController.coverClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                                    b.setTitle(o.objectId, forState: UIControlState.Normal)
                                    b.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), forState: UIControlState.Normal)
                                    iv.addSubview(b)
                                    self.scMore.addSubview(iv)
                                    counter += 1
                                    self.scMore.contentSize = CGSize(width: PERC_DarkRedWidth + CGFloat(counter) * (PERC_DarkRedWidth + PERC_LibCoverWidth), height: PERC_LibCoverHeight)
                                }
                            })
                        }
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func buildScrollViewSimilar(a : NSArray) {
        var counter = 0
        for o in a {
            let id = o as! String
            let query = PFQuery(className: "Book")
            query.whereKey("objectId", equalTo: id)
            query.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    let dat = object?.objectForKey("cover") as! PFFile
                    dat.getDataInBackgroundWithBlock({
                        (imageData: NSData?, error: NSError?) -> Void in

                        if (error != nil) {
                            print (error?.localizedDescription as Any)
                        }
                        else {

                            let iv = UIImageView(image: UIImage(data: imageData!))
                            iv.frame.size.width = PERC_LibCoverWidth
                            iv.frame.size.height = PERC_LibCoverHeight
                            iv.frame.origin.y = 0
                            iv.frame.origin.x = PERC_DarkRedWidth + CGFloat(counter) * (PERC_DarkRedWidth + PERC_LibCoverWidth)
                            iv.userInteractionEnabled = true
                            let b = UIButton(frame: CGRect(x: 0, y: 0, width: PERC_LibCoverWidth, height: PERC_LibCoverHeight))
                            b.addTarget(self, action: #selector(BookDescriptionController.coverClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                            b.setTitle(object!.objectId, forState: UIControlState.Normal)
                            b.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), forState: UIControlState.Normal)
                            iv.addSubview(b)
                            self.scAlsoLike.addSubview(iv)
                            counter += 1
                            self.scAlsoLike.contentSize = CGSize(width: PERC_DarkRedWidth + CGFloat(counter) * (PERC_DarkRedWidth + PERC_LibCoverWidth), height: PERC_LibCoverHeight)
                        }
                    })
                    
                } else {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func coverClicked(sender : UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : BookDescriptionController = storyboard.instantiateViewControllerWithIdentifier("bookdescription") as! BookDescriptionController
        
        let iv = sender.superview as! UIImageView
        if iv.image != nil {
            vc.bookCover = iv.image!
        }
        vc.bookId = sender.titleLabel?.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func checkIfBookIsInWishlist() {
        let u = PFUser.currentUser()
        if u != nil {
            if let wish = u?.objectForKey("wishlist") as? NSMutableArray {
                for s in wish {
                    if self.bookId == s as! String {
                        self.changeMinusWishlist()
                    }
                }
            }
        }
    }
    
    @IBAction func addToWishList(sender : UIButton) {
        addActivityIndicator()
        
        let u = PFUser.currentUser()
        if u != nil {
            if let wish = u?.objectForKey("wishlist") as? NSMutableArray {
                var isAlreadyIn = false
                for s in wish {
                    if self.bookId == s as! String {
                        isAlreadyIn = true
                    }
                }
                if !isAlreadyIn {
                    wish.addObject(self.bookId)
                    u?.setObject(wish, forKey: "wishlist")
                    u?.saveInBackgroundWithBlock{(success, error) -> Void in
                        if error == nil {
                            if success { //All good
                                print("added to wishlist")
                                self.changeMinusWishlist()
                                self.removeActivityIndicator()
                            }
                        } else {
                            self.removeActivityIndicator()
                            let alert = UIAlertController(title: "Wish List", message: "Sorry, an error occured. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                            alert.addAction(ok)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    self.removeActivityIndicator()
                    changeMinusWishlist()
                }
            } else {
                let wish = NSMutableArray()
                wish.addObject(self.bookId)
                u?.setObject(wish, forKey: "wishlist")
                u?.saveInBackgroundWithBlock{(success, error) -> Void in
                    if error == nil {
                        if success {
                            print("added to wishlist")
                            self.removeActivityIndicator()
                        } else {
                            self.removeActivityIndicator()
                            let alert = UIAlertController(title: "Wish List", message: "Sorry, an error occured. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                            alert.addAction(ok)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    } else {
                        self.removeActivityIndicator()
                        let alert = UIAlertController(title: "Wish List", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(ok)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            self.removeActivityIndicator()
            let alert = UIAlertController(title: "Wish List", message: "Sorry, you were disconnected", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func removeFromWishList(sender : UIButton) {
        addActivityIndicator()
        let u = PFUser.currentUser()
        if u != nil {
            if let wish = u?.objectForKey("wishlist") as? NSMutableArray {
                for s in wish {
                    if self.bookId == s as! String {
                        wish.removeObject(s)
                        u?.setObject(wish, forKey: "wishlist")
                        u?.saveInBackground()
                        print("removed")
                        self.removeActivityIndicator()
                        self.changePlusWishlist()
                        
                    }
                }
            } else {
                self.removeActivityIndicator()
                alert("Wish List", message: "Sorry, an error occured")
            }
        } else {
            removeActivityIndicator()
            alert("Wish List", message: "Sorry, you were disconnected")
        }
    }
    
    func changeMinusWishlist() {
        bAdd.setTitle("- WISHLIST", forState: .Normal)
        bAdd.backgroundColor = UIColor(red: 1, green: 60 / 255, blue: 0, alpha: 1)
        bAdd.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        bAdd.removeTarget(self, action: #selector(BookDescriptionController.addToWishList(_:)), forControlEvents: .TouchUpInside)
        bAdd.addTarget(self, action: #selector(BookDescriptionController.removeFromWishList(_:)), forControlEvents: .TouchUpInside)
    }
    
    func changePlusWishlist() {
        bAdd.setTitle("+ WISHLIST", forState: .Normal)
        bAdd.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        bAdd.setTitleColor(UIColor(red: 1, green: 60 / 255, blue: 0, alpha: 1), forState: .Normal)
        bAdd.removeTarget(self, action: #selector(BookDescriptionController.removeFromWishList(_:)), forControlEvents: .TouchUpInside)
        bAdd.addTarget(self, action: #selector(BookDescriptionController.addToWishList(_:)), forControlEvents: .TouchUpInside)
    }
    
    @IBAction func barButtonToSearch(sender : UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : SearchController = storyboard.instantiateViewControllerWithIdentifier("search") as! SearchController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        if activityIndicator != nil {
            activityIndicator.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    func hvDisappear() {
        if hv != nil {
            hv.disappear()
        }
    }
    
    func alert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
