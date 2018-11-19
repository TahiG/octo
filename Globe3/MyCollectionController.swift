//
//  MasterViewController.swift
//  Globe
//
//  Created by Charles Masson on 04/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit

class MyCollectionController: ControllerAvecMenu, UIScrollViewDelegate, ImageBackDelegate {
    
    @IBOutlet var ivPicture : UIImageView!
    @IBOutlet var lName : UILabel!
    @IBOutlet var lTown : UILabel!
    @IBOutlet var bEdit : UIButton!
    @IBOutlet var lCurr : UILabel!
    @IBOutlet var vCurrentlyReading : UIView!
    @IBOutlet var lWish : UILabel!
    @IBOutlet var vWishList : UIView!
    @IBOutlet var vTitleCurrentlyReading : UIView!
    @IBOutlet var vTitleWishList : UIView!
    @IBOutlet var sandwichButton : UIBarButtonItem!
    @IBOutlet var searchButton : UIBarButtonItem!
    
    @IBOutlet var scMain : UIScrollView!
    
    var isImageSet = false
    
    var nbCurrently = 4//Currently reading
    var nbWish = 5//Wish list
    
    let defVal = NSUserDefaults.standardUserDefaults()
    
    var ivsReading = NSMutableArray(capacity: 6)
    var ivsWish = NSMutableArray(capacity: 6)
    var ivReading1 : UIImageView!
    var ivReading2 : UIImageView!
    var ivReading3 : UIImageView!
    var ivReading4 : UIImageView!
    var ivReading5 : UIImageView!
    var ivReading6 : UIImageView!
    var ivWish1 : UIImageView!
    var ivWish2 : UIImageView!
    var ivWish3 : UIImageView!
    var ivWish4 : UIImageView!
    var ivWish5 : UIImageView!
    var ivWish6 : UIImageView!
    
    
    var firstName : String!
    var name : String!
    var age : String!
    var ageId : Int!
    var location : String!
    var profilePicture : UIImage!
    var gender : String!
    var mail : String!
    
    var aiPicture : UIActivityIndicatorView!
    
    var wishListBoxId = 0
    var wishListBoxes = NSMutableArray()
    
    var currBoxId = 0
    var currBoxes = NSMutableArray()
    
    var hv : HelpView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aiPicture = UIActivityIndicatorView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 30, height: 30)))
        let user = PFUser.currentUser()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(backToFeedSwipe))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        scMain.frame.size = CGSize(width: screenWidth, height: screenHeight)
        scMain.frame.origin = CGPoint(x: 0, y: 0)
        scMain.delegate = self
        
        ivPicture.frame.size = CGSize(width: PERC_CoteProfilePicture, height: PERC_CoteProfilePicture)
        ivPicture.layer.cornerRadius = PERC_CoteProfilePicture / 2
        ivPicture.frame.origin.x = PERC_BlackWidth
        ivPicture.frame.origin.y = PERC_BlueHeight
        ivPicture.clipsToBounds = true
        ivPicture.contentMode = UIViewContentMode.ScaleAspectFill
        ivPicture.layer.borderColor = UIColor(red: 91/255, green: 89/255, blue: 89/255, alpha: 1.0).CGColor
        ivPicture.layer.borderWidth = 1
        ivPicture.addSubview(aiPicture)
        aiPicture.center = ivPicture.center
        ivPicture.image = UIImage(named: "nameicon")
        let labOriginX = CGRectGetMaxX(ivPicture.frame) + PERC_BlackWidth
        
        lName.sizeToFit()
        lName.frame.origin.x = labOriginX
        lName.frame.origin.y = PERC_BlueHeight
        
        lTown.sizeToFit()
        lTown.frame.origin.x = labOriginX
        lTown.frame.origin.y = CGRectGetMaxY(lName.frame)
        
        bEdit.sizeToFit()
        bEdit.frame.origin.x = labOriginX
        bEdit.frame.origin.y = CGRectGetMaxY(lTown.frame)

        vTitleWishList.frame.size.width = screenWidth - 2 * PERC_BlackWidth
        vTitleWishList.frame.size.height = PERC_TitlePurpleHeight
        vTitleWishList.frame.origin.x = PERC_BlackWidth
        vTitleWishList.frame.origin.y = CGRectGetMaxY(ivPicture.frame) + PERC_BlueHeight + 20

        lWish.sizeToFit()
        lWish.frame.size.width += 12
        lWish.frame.size.height = PERC_TitlePurpleHeight
        lWish.frame.origin.x = 0
        lWish.frame.origin.y = 0
        
        vWishList.frame.size.width = screenWidth - 2 * PERC_BlackWidth
        vWishList.frame.size.height = 3 * PERC_DarkRedWidth + 2 * PERC_CollectionCoverHeight
        vWishList.frame.origin.y = CGRectGetMaxY(vTitleWishList.frame) + 20
        vWishList.frame.origin.x = PERC_BlackWidth

        let blueColor:UIColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)

        let vVertical = UIView(frame: CGRect(x: PERC_DarkRedWidth * 3/2 + PERC_CollectionCoverWidth, y: PERC_DarkRedWidth, width: 1, height: 2 * PERC_CollectionCoverHeight + PERC_DarkRedWidth))
        vVertical.backgroundColor = blueColor
        let vVertical2 = UIView(frame: CGRect(x: PERC_DarkRedWidth * 5/2 + PERC_CollectionCoverWidth * 2, y: PERC_DarkRedWidth, width: 1, height: 2 * PERC_CollectionCoverHeight + PERC_DarkRedWidth))
        vVertical2.backgroundColor = blueColor
        let vHorizontal = UIView(frame: CGRect(x: PERC_DarkRedWidth, y: 3/2 * PERC_DarkRedWidth + PERC_CollectionCoverHeight, width: 3 * PERC_CollectionCoverWidth + 2 * PERC_DarkRedWidth, height: 1))
        vHorizontal.backgroundColor = blueColor
        
        vWishList.addSubview(vVertical)
        vWishList.addSubview(vVertical2)
        vWishList.addSubview(vHorizontal)
        wishListBoxes.addObject(vWishList)

        if let uWishList: AnyObject = user?.objectForKey("wishlist") as? NSArray {
            nbWish = uWishList.count
            let queryB = PFQuery(className: "Book")
            if uWishList.count != 0 {
                self.queryBookWish(queryB, num: 0, array: uWishList as! NSArray, createNewBox: false)
            }
        } else {
            nbCurrently = 0
        }
        
        scMain.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(vWishList.frame))
        scMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyCollectionController.svTapped(_:))))
        
        getCustomInfos()
        
        let ud = NSUserDefaults.standardUserDefaults()
        if let firstTime = ud.objectForKey("FIRSTTIME_MYCOLLECTION") as? Bool {
            if firstTime {
                makeHV(ud)
            }
        } else {
            makeHV(ud)
        }
    }
    
    func makeHV(ud : NSUserDefaults) {
        hv = HelpView(text: "Here you can view your private wishlist.\n\nTap edit to make changes to your profile.", arrow: true, origin: PERC_LibHeaderHeight + 69)
        hv.center.x = self.view.center.x
        UIApplication.sharedApplication().keyWindow!.addSubview(hv)
        hv.setBold(NSMakeRange(45, 4))
        ud.setBool(false, forKey: "FIRSTTIME_MYCOLLECTION")
        ud.synchronize()
    }
    
    func hvDisappear() {
        if hv != nil {
            hv.disappear()
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hvDisappear()
    }
    
    override func viewDidAppear(animated: Bool) {
        if mustLaunchEditProfile {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editProf : EditProfileController = storyboard.instantiateViewControllerWithIdentifier("editprofile") as! EditProfileController
            editProf.imgDelegate = self
            self.navigationController?.pushViewController(editProf, animated: false)
            mustLaunchEditProfile = false
        } else {
            isImageSet = false
            Functions.delay(4.0) { self.checkImage() }
            getCustomInfos()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        vMenuIndicator.frame.origin.y = PERC_LightBrownHeight + 3 + 2 * PERC_BeigeHeight
    }
    
    @IBAction func svTapped(sender : UITapGestureRecognizer) {
        if menuShowed {
            showMenu(UIBarButtonItem())
        }
    }
    
    func queryBookReading(query : PFQuery, num : Int, array : NSArray, createNewBox : Bool){
        query.whereKey("objectId", equalTo: array[num])
        query.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                print("in book currently reading")
                if object != nil {
                    let dat = object?.objectForKey("cover") as! PFFile
                    dat.getDataInBackgroundWithBlock({
                        (imageData: NSData?, error: NSError?) -> Void in

                        if (error != nil) {
                            print (error?.localizedDescription as Any)
                        }
                        else {

                            let mod = num % 6
                            
                            if createNewBox {
                                self.currBoxId += 1
                                let vCurrentlyReading = UIView()
                                vCurrentlyReading.frame.size.width = screenWidth - 2 * PERC_BlackWidth
                                vCurrentlyReading.frame.size.height = 3 * PERC_DarkRedWidth + 2 * PERC_CollectionCoverHeight
                                vCurrentlyReading.frame.origin.y = CGRectGetMaxY(self.currBoxes[self.currBoxId - 1].frame) + PERC_DarkRedHeight
                                vCurrentlyReading.frame.origin.x = PERC_BlackWidth
                                
                                let vVerticalBlue = UIView(frame: CGRect(x: PERC_DarkRedWidth * 3/2 + PERC_CollectionCoverWidth, y: PERC_DarkRedWidth, width: 1, height: 2 * PERC_CollectionCoverHeight + PERC_DarkRedWidth))
                                vVerticalBlue.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)
                                let vVerticalBlue2 = UIView(frame: CGRect(x: PERC_DarkRedWidth * 5/2 + PERC_CollectionCoverWidth * 2, y: PERC_DarkRedWidth, width: 1, height: 2 * PERC_CollectionCoverHeight + PERC_DarkRedWidth))
                                vVerticalBlue2.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)
                                let vHorizontalBlue = UIView(frame: CGRect(x: PERC_DarkRedWidth, y: 3/2 * PERC_DarkRedWidth + PERC_CollectionCoverHeight, width: 3 * PERC_CollectionCoverWidth + 2 * PERC_DarkRedWidth, height: 1))
                                vHorizontalBlue.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)
                                
                                vCurrentlyReading.addSubview(vVerticalBlue)
                                vCurrentlyReading.addSubview(vVerticalBlue2)
                                vCurrentlyReading.addSubview(vHorizontalBlue)
                                
                                self.currBoxes.addObject(vCurrentlyReading)
                                self.scMain.addSubview(vCurrentlyReading)
                                self.scMain.contentSize.height += vCurrentlyReading.frame.size.height + PERC_DarkRedHeight
                                self.vTitleWishList.frame.origin.y = CGRectGetMaxY(vCurrentlyReading.frame) + PERC_BlueHeight
                                for i in 0  ..< self.wishListBoxes.count {
                                    //wishListBoxes[i].frame.origin.y = 12//CGRectGetMaxY(vCurrentlyReading.frame)
                                    (self.wishListBoxes[i] as! UIView).frame.origin.y = CGRectGetMaxY(self.vTitleWishList.frame) + CGFloat(i) * (PERC_DarkRedHeight + vCurrentlyReading.frame.size.height)
                                }
                            }

                            let iv = UIImageView(image: UIImage(data: imageData!))
                            iv.frame.origin = (mod < 3) ? CGPoint(x: PERC_DarkRedWidth + CGFloat(mod) * (PERC_DarkRedWidth + PERC_CollectionCoverWidth), y: PERC_DarkRedWidth) : CGPoint(x: PERC_DarkRedWidth + CGFloat(mod - 3) * (PERC_DarkRedWidth + PERC_CollectionCoverWidth), y: 2 * PERC_DarkRedWidth + PERC_CollectionCoverHeight)
                            
                            iv.frame.size.width = PERC_CollectionCoverWidth
                            iv.frame.size.height = PERC_CollectionCoverHeight
                            iv.contentMode = UIViewContentMode.ScaleAspectFit
                            iv.userInteractionEnabled = true
                            let b = UIButton(frame: iv.frame)
                            b.frame.origin = CGPointZero
                            b.setTitle(object!.objectId!, forState: UIControlState.Normal)
                            b.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                            b.addTarget(self, action: #selector(MyCollectionController.goToReading(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                            iv.addSubview(b)
                            //Delete element
                            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MyCollectionController.deleteBookFromCurrentlyReading(_:)))
                            b.addGestureRecognizer(longPress)
                            self.currBoxes[self.currBoxId].addSubview(iv)
                            
                            self.queryBookReading(query, num: num + 1, array: array, createNewBox: mod == 5)
                        }
                    })
                } else {
                    
                }
                
                
            } else { print(error) }
        }
    }
    
    func queryBookWish(query : PFQuery, num : Int, array : NSArray, createNewBox : Bool){
        query.whereKey("objectId", equalTo: array[num])
        query.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                print("in book wish")
                if object != nil {
                    let dat = object?.objectForKey("cover") as! PFFile
                    dat.getDataInBackgroundWithBlock({
                        (imageData: NSData?, error: NSError?) -> Void in

                        if (error != nil) {
                            print (error?.localizedDescription as Any)
                        }
                        else {

                            let mod = num % 6

                            if createNewBox {
                                self.wishListBoxId += 1
                                let vWishList = UIView()
                                vWishList.frame.size.width = screenWidth - 2 * PERC_BlackWidth
                                vWishList.frame.size.height = 3 * PERC_DarkRedWidth + 2 * PERC_CollectionCoverHeight
                                vWishList.frame.origin.y = CGRectGetMaxY(self.wishListBoxes[self.wishListBoxId - 1].frame) + PERC_DarkRedHeight
                                vWishList.frame.origin.x = PERC_BlackWidth
                                vWishList.backgroundColor = UIColor(red: 1, green: 235 / 255, blue: 232 / 255, alpha: 1)

                                let vVertical = UIView(frame: CGRect(x: PERC_DarkRedWidth * 3/2 + PERC_CollectionCoverWidth, y: PERC_DarkRedWidth, width: 1, height: 2 * PERC_CollectionCoverHeight + PERC_DarkRedWidth))
                                vVertical.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0/255, alpha: 1)
                                let vVertical2 = UIView(frame: CGRect(x: PERC_DarkRedWidth * 5/2 + PERC_CollectionCoverWidth * 2, y: PERC_DarkRedWidth, width: 1, height: 2 * PERC_CollectionCoverHeight + PERC_DarkRedWidth))
                                vVertical2.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0/255, alpha: 1)
                                let vHorizontal = UIView(frame: CGRect(x: PERC_DarkRedWidth, y: 3/2 * PERC_DarkRedWidth + PERC_CollectionCoverHeight, width: 3 * PERC_CollectionCoverWidth + 2 * PERC_DarkRedWidth, height: 1))
                                vHorizontal.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0/255, alpha: 1)

                                vWishList.addSubview(vVertical)
                                vWishList.addSubview(vVertical2)
                                vWishList.addSubview(vHorizontal)
                                self.scMain.addSubview(vWishList)
                                self.scMain.contentSize.height = CGRectGetMaxY(vWishList.frame)
                                self.wishListBoxes.addObject(vWishList)
                            }

                            let iv = UIImageView(image: UIImage(data: imageData!))
                            iv.frame.origin = (mod < 3) ? CGPoint(x: PERC_DarkRedWidth + CGFloat(mod) * (PERC_DarkRedWidth + PERC_CollectionCoverWidth), y: PERC_DarkRedWidth) : CGPoint(x: PERC_DarkRedWidth + CGFloat(mod - 3) * (PERC_DarkRedWidth + PERC_CollectionCoverWidth), y: 2 * PERC_DarkRedWidth + PERC_CollectionCoverHeight)

                            iv.frame.size.width = PERC_CollectionCoverWidth
                            iv.frame.size.height = PERC_CollectionCoverHeight
                            iv.contentMode = UIViewContentMode.ScaleAspectFit
                            iv.userInteractionEnabled = true
                            let b = UIButton(frame: iv.frame)
                            b.frame.origin = CGPointZero
                            b.setTitle(object!.objectId, forState: UIControlState.Normal)
                            b.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                            b.addTarget(self, action: #selector(MyCollectionController.goToBookDescription(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                            iv.addSubview(b)
                            //Delete element
                            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MyCollectionController.deleteBookFromWishList(_:)))
                            b.addGestureRecognizer(longPress)
                            self.wishListBoxes[self.wishListBoxId].addSubview(iv)
                            
                            self.queryBookWish(query, num: num + 1, array: array, createNewBox: mod == 5)
                        }

                        
                    })
                } else {
                    
                }
                
                
            } else { print(error) }
        }
    }
    
    @IBAction func goToBookDescription(sender : UIButton) {
        if hv != nil {
            if hv.hidden == false {
                hvDisappear()
            } else {
                goBookDesc(sender)
            }
        } else {
            goBookDesc(sender)
        }
    }
    
    func goBookDesc(sender : UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : BookDescriptionController = storyboard.instantiateViewControllerWithIdentifier("bookdescription") as! BookDescriptionController
        
        let iv = sender.superview as! UIImageView
        if iv.image != nil {
            vc.bookCover = iv.image!
        }
        vc.bookId = sender.titleLabel?.text
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func goToReading(sender : UIButton) {
        //UPDATE FERBRUARY we go to book description, not reading pages
        if hv != nil {
            if hv.hidden == false {
                hvDisappear()
            } else {
                goReading(sender)
            }
        } else {
            goReading(sender)
        }
    }
    
    func goReading(sender : UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : BookDescriptionController = storyboard.instantiateViewControllerWithIdentifier("bookdescription") as! BookDescriptionController
        let iv = sender.superview as! UIImageView
        if iv.image != nil {
            vc.bookCover = iv.image!
        }
        vc.bookId = sender.titleLabel?.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteBookFromWishList(sender : UILongPressGestureRecognizer) {
        //if sender.state == .Ended {
        let u = PFUser.currentUser()
        if u != nil {
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this book?", preferredStyle: UIAlertControllerStyle.Alert)
            let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { _ in
                //Deletion
                let uWish = u?.objectForKey("wishlist") as? NSMutableArray
                if uWish != nil {
                    let s = ((sender.view as! UIButton).titleLabel?.text)!
                    uWish?.removeObject(s)
                    u?.setObject(uWish!, forKey: "wishlist")
                    u?.saveInBackgroundWithBlock{(success, error) -> Void in
                        if error == nil {
                            if success { //All good
                                sender.view?.superview!.removeFromSuperview()
                            }
                        } else {
                            self.alertConnectionIssue()
                        }
                    }
                } else {
                    self.alertConnectionIssue()
                }
            })
            
            let no = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            alertConnectionIssue()
        }
        //}
    }
    
    @IBAction func deleteBookFromCurrentlyReading(sender : UILongPressGestureRecognizer) {
        let u = PFUser.currentUser()
        if u != nil {
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this book?", preferredStyle: UIAlertControllerStyle.Alert)
            let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { _ in
                //Deletion
                let uWish = u?.objectForKey("currentlyreading") as? NSMutableArray
                if uWish != nil {
                    let s = ((sender.view as! UIButton).titleLabel?.text)!
                    uWish?.removeObject(s)
                    u?.setObject(uWish!, forKey: "currentlyreading")
                    u?.saveInBackgroundWithBlock{(success, error) -> Void in
                        if error == nil {
                            if success { //All good
                                sender.view?.superview!.removeFromSuperview()
                            }
                        } else {
                            self.alertConnectionIssue()
                        }
                    }
                } else {
                    self.alertConnectionIssue()
                }
            })
            
            let no = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            alertConnectionIssue()
        }
    }
    
    func alertConnectionIssue() {
        let alert = UIAlertController(title: "Connection", message: "Connection error. Please check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkImage() {
        let user = PFUser.currentUser()
        if let uProfilePict = user?.objectForKey("profilePicture") as? PFFile {
            uProfilePict.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if !self.isImageSet {
                        self.profilePicture = UIImage(data: data!)
                        self.ivPicture.image = self.profilePicture
                        self.isImageSet = true
                        //self.scMain.addSubview(self.ivPicture)
                    }
                } else {
                    print(error)
                }
            })
        } else {
            self.aiPicture.removeFromSuperview()
        }
    }
    
    func getCustomInfos() {
        let user = PFUser.currentUser()
        //First, check if user already entered his infos
        if let didEnterCustomInfos = user?.objectForKey("didEnterCustomInfos") as? Bool {
            if didEnterCustomInfos {
                //Retrieve the infos
                if let uFirstName = user?.objectForKey("firstname") as? String {
                    self.firstName = uFirstName
                } else { self.firstName = "" }
                //Name
                if let uName = user?.objectForKey("lastname") as? String {
                    self.name = uName
                    self.lName.text = "\(self.firstName) \(uName)"
                    self.lName.sizeToFit()
                } else { self.name = "" }
                //Age
                if let uAge = user?.objectForKey("age") as? Int {
                    self.age = Functions.getAgeCarouselText(uAge)
                    self.ageId = uAge
                } else { self.age = "" }
                //Gender
                if let uGender = user?.objectForKey("gender") as? String {
                    self.gender = uGender
                } else { self.gender = "" }
                //Mail
                if let uMail = user?.objectForKey("email") as? String {
                    self.lTown.text = uMail
                    self.lTown.sizeToFit()
                }
                //Photo
                if let uProfilePict = user?.objectForKey("profilePicture") as? PFFile {
                    uProfilePict.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            self.profilePicture = UIImage(data: data!)
                            self.ivPicture.image = self.profilePicture
                            self.scMain.addSubview(self.ivPicture)
                            self.isImageSet = true
                        } else { print(error) }
                    })
                }
            }
        } else {
            //No infos anywhere...
            let user = PFUser.currentUser()
            if let fn = user?.objectForKey("firstname") as? String {
                firstName = fn
                if let ln = user?.objectForKey("lastname") as? String {
                    name = ln
                    lName.text = "\(firstName) \(name)"
                    lName.sizeToFit()
                }
            } else if let uUserame = user?.objectForKey("username") as? String {
                firstName = uUserame
                lName.text = "\(self.firstName)"
                lName.sizeToFit()
            } else {
                self.firstName = ""
            }
            //Mail
            if let uMail = user?.objectForKey("email") as? String {
                self.mail = uMail
            } else {
                self.mail = ""
            }
        }
    }
    
    func facebookSignIn() {
        /// } else if(PFFacebookUtils.isLinkedWithUser(user!)) {
        
        //Else we get info from facebook account
        let paramsFBProfile = [ "fields" : "id, name, email, first_name, last_name"]
        let req = FBSDKGraphRequest(graphPath: "me", parameters: paramsFBProfile)
        let conn = FBSDKGraphRequestConnection()
        //Connecting to user's public profile
        conn.addRequest(req, completionHandler:  { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if(error != nil){
                print(error)
            } else {
                
                let id = result.objectForKey("id") as! String
                let email = result.objectForKey("email") as! String
                let name = result.objectForKey("last_name") as! String
                let firstName = result.objectForKey("first_name") as! String
                
                //let locDic: AnyObject? = result.objectForKey("location")
                //let loc = locDic!.objectForKey("name") as! String
                let fbPictUrl : String = "https://graph.facebook.com/" + id + "/picture?type=large"
                if(email != "") {
                    let user = PFUser.currentUser()
                    //user!.setObject("\(firstName) \(name)", forKey: "username")
                    //user!.setObject(email, forKey: "email")
                    user!.email = email
                    user!.saveInBackground()//no need to see any error
                }
                
                self.lName.text = "\(firstName) \(name)"
                self.lName.sizeToFit()
                //self.lTown.text = loc
                //self.lTown.sizeToFit()
                
                self.firstName = firstName
                self.name = name
                
                if let url = NSURL(string: fbPictUrl) {
                    if let data = NSData(contentsOfURL: url) {
                        let image = UIImage(data: data)
                        self.profilePicture = image
                        self.ivPicture.image = image
                        self.ivPicture.layer.cornerRadius = PERC_CoteProfilePicture / 2
                        self.ivPicture.clipsToBounds = true
                        self.isImageSet = true
                    }
                }
                
            }
        })
        conn.start()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editprofile" {
            let ed = segue.destinationViewController as! EditProfileController
            
            ed.imgDelegate = self
            //ed.profilePicture = self.profilePicture
            if self.firstName != nil {
                ed.firstName = firstName
            }
            if self.name != nil {
                ed.name = name
            }
            if self.location != nil {
                ed.location = location
            }
            if self.age != nil {
                ed.age = age
                ed.ageSelected = ageId
            }
            if self.gender != nil {
                ed.gender = gender
            }
            if self.mail != nil {
                ed.mail = mail
            }
        }
    }
    
    @IBAction func clickEdit(sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editProf : EditProfileController = storyboard.instantiateViewControllerWithIdentifier("editprofile") as! EditProfileController
        
        editProf.imgDelegate = self
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromTop
        self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
        editProf.firstName = firstName
        editProf.profilePicture = profilePicture
        editProf.name = name
        editProf.location = location
        editProf.age = age
        editProf.gender = gender
        editProf.mail = mail
        self.navigationController?.pushViewController(editProf, animated: false)
        //self.performSegueWithIdentifier("editprofile", sender: self)
    }
    
    @IBAction func showMenu(sender : UIBarButtonItem){
        self.view.bringSubviewToFront(vMenu)
        if menuShowed {
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = -PERC_MenuWidth
                }, completion: nil)
            menuShowed = false
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = 0.0
                }, completion: nil)
            menuShowed = true
        }
    }
    
    @IBAction func scTapped(sender : UITapGestureRecognizer) {
        if menuShowed {
            showMenu(UIBarButtonItem())
        }
    }
    
    func sendImageBack(image: UIImage) {
        ivPicture.image = image
    }
    
    func sendLocation(loc : String) {
        location = loc
    }
    
    func sendAge(age : String) {
        self.age = age
    }
    
    func sendGender(gender : String) {
        self.gender = gender
    }
    
    override func goToLibrary(sender : UIButton){
        var vcs = self.navigationController!.viewControllers
        let newVCs = NSMutableArray()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lib : LibraryController = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
        newVCs.addObject(vcs[0])
        newVCs.addObject(lib)
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y -= (PERC_BeigeHeight + 1) * 2
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu(UIBarButtonItem())
                }
                self.navigationController?.setViewControllers(newVCs as NSArray as! [UIViewController], animated: true)
        })
    }
    
    func backToFeedSwipe(sender : UIGestureRecognizer){
        if self.menuShowed {
            self.showMenu(UIBarButtonItem())
        }
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromRight
        self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    override func goToAbout(sender: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y += (PERC_BeigeHeight + 1)
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : AboutController = storyboard.instantiateViewControllerWithIdentifier("aboutcontroller") as! AboutController
                self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    override func popToFeed(sender : UIButton){
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y -= (PERC_BeigeHeight + 1) * 3
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu(UIBarButtonItem())
                }
                let trans = CATransition()
                trans.duration = 0.5
                trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                trans.type = kCATransitionMoveIn
                trans.subtype = kCATransitionFromRight
                self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
                self.navigationController?.popToRootViewControllerAnimated(false)
        })
    }
}
