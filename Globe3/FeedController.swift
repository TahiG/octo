//
//  FeedController.swift
//  Globe3
//
//  Created by Charles Masson on 17/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import FolioReaderKit

class FeedController : /*UIViewController*/ControllerAvecMenu, UINavigationControllerDelegate {
    
    var countImages = 0
    var counterFeedImages = 0
    var counter = 0
    var arrImages = NSMutableArray()
    var arrTexts = NSMutableArray()
    
    var showedIV = 0
    
    var moveStartY : CGFloat!
    var moveEndY : CGFloat!
    var moveStartX : CGFloat!
    var moveEndX : CGFloat!
    
    var ivLogoTitle : UIImageView!
    
    var textOnLeft = true
    var viewIsLoadingFirstTime = false
    
    var wentUpFirst = false
    var lastIdInCurrentlyReading = ""
    
    var nowReadingLoaded = false
    
    var hv : HelpView!
    
    var bonusCategories = NSMutableArray()
    var bonusCategoriesTexts = NSMutableArray()
    
    var bBackToTop : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewIsLoadingFirstTime = true
        
        ivLogoTitle = LogoImageView(image: UIImage(named: "logo-old"))
        ivLogoTitle.frame.origin.y = 28
        ivLogoTitle.frame.size.height = 50
        ivLogoTitle.contentMode = UIViewContentMode.ScaleAspectFit
        ivLogoTitle.center.x = self.view.center.x
        
        let w = UIApplication.sharedApplication().keyWindow
        w?.addSubview(ivLogoTitle)
        
        let ud = NSUserDefaults.standardUserDefaults()
        if let firstTime = ud.objectForKey("FIRSTTIME_FEED") as? Bool {
            if firstTime {
                makeHV(ud)
            }
        } else {
            makeHV(ud)
        }

        
        self.ivLogoTitle.hidden = false
        delayIVLogo()
        

        queryLastEBookCurrentlyReading()
    }
    
    
    
    func makeHV(ud : NSUserDefaults) {
        hv = HelpView(text: "Welcome to globe. Here you can discover new titles.\n\nNo price tags, no subscriptions, just great books. \n\n Enjoy!", arrow: true, origin: CGRectGetMaxY(ivLogoTitle.frame) + 5)
        hv.center.x = self.view.center.x
        UIApplication.sharedApplication().keyWindow!.addSubview(hv)
        hv.setBold(NSMakeRange(11, 5))
        ud.setBool(false, forKey: "FIRSTTIME_FEED")
        ud.synchronize()
    }
    
    func queryLastEBookCurrentlyReading() {
        self.queryFeedImages()
        return
        
/*
 // update: 01-APR-2017
 // The following code can be commented out because it causes a crash on new users with no books in their last currently read.
 //
 // The currently reading has a list of (36) books.  It has no feature to support last read, and always assumes
 // the first book in this list is the book the user last read.
 //
 **/

        let fontName = UIFont(name: "Interstate-Bold", size: 20)
        let u = PFUser.currentUser()
        if let arr = u?.objectForKey("currentlyreading") as? NSArray {
            let c = arr.count
            if c != 0 {
                let lastId = arr[0] as! String
                lastIdInCurrentlyReading = lastId
                let q = PFQuery(className: "Book")
                q.getObjectInBackgroundWithId(lastId, block: {
                    (o: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        self.queryFeedImages()
                    }
                    if o != nil {
                        if let dat = o!.objectForKey("cover") as? PFFile {
                            dat.getDataInBackgroundWithBlock({
                                (imageData: NSData?, error: NSError?) -> Void in

                                if (error != nil) {
                                    print (error?.localizedDescription as Any)
                                    self.queryFeedImages()
                                }
                                else {

                                    self.nowReadingLoaded = true
                                    let panGest = UIPanGestureRecognizer(target: self, action: #selector(FeedController.ivPanned(_:)))
                                    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(FeedController.goToMyCollectionSwipe(_:)))
                                    swipeRight.direction = UISwipeGestureRecognizerDirection.Right
                                    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(FeedController.goToLibrarySwipe(_:)))
                                    swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
                                    let tapIV = UITapGestureRecognizer(target: self, action: #selector(FeedController.goToLibraryAndScroll(_:)))
                                    let iv = FeedImageView(image: UIImage(data: imageData!), id: self.counter)
                                    iv.userInteractionEnabled = true
                                    iv.frame.origin.x = 0
                                    iv.tag = self.counterFeedImages
                                    if self.counter == 0 {
                                        iv.frame.origin.y = CGFloat(64)
                                    } else {
                                        iv.frame.origin.y = CGFloat(44) + CGFloat(self.counter) * (PERC_FeedImageHeight - 40)//100 for the transition
                                    }
                                    iv.frame.size.width = screenWidth
                                    iv.frame.size.height = PERC_FeedImageHeight
                                    iv.gestureRecognizers = [panGest, swipeRight, swipeLeft, tapIV]
                                    iv.contentMode = UIViewContentMode.ScaleAspectFill
                                    self.cutImage(iv, c: self.counter)
                                    self.view.addSubview(iv)
                                    self.view.bringSubviewToFront(self.vMenu)
                                    self.arrImages.addObject(iv)
                                    self.counter = 1

                                    var txts = ["YOU'RE", "READING"]
                                    let nbLines = txts.count
                                    let grayColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 0.6)
                                    let txtColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
                                    let vTxts = UIView()
                                    var maxWidth : CGFloat = 0
                                    for i in 0  ..< nbLines {
                                        let vCont = UIView()
                                        let lab = UILabel()
                                        lab.text = txts[i]// as? String
                                        lab.textColor = txtColor
                                        lab.font = fontName
                                        lab.sizeToFit()
                                        vCont.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(i) * (PERC_DarkTealHeight + PERC_RedHeight)), size: CGSize(width: lab.frame.size.width + 2 * PERC_DarkRedWidth, height: PERC_DarkTealHeight))
                                        vCont.backgroundColor = grayColor
                                        vCont.addSubview(lab)
                                        lab.center = CGPoint(x: vCont.frame.size.width / 2, y: vCont.frame.size.height / 2 + 1.5)
                                        vTxts.addSubview(vCont)
                                        if vCont.frame.size.width > maxWidth {
                                            maxWidth = vCont.frame.size.width
                                        }
                                    }
                                    vTxts.sizeToFit()
                                    vTxts.frame.size.height = 3 * PERC_DarkTealHeight + 2 * PERC_RedHeight
                                    if self.textOnLeft {
                                        vTxts.frame.origin.x = 0.0
                                        self.textOnLeft = false
                                    } else {
                                        vTxts.frame.origin.x = screenWidth - maxWidth
                                        for v in vTxts.subviews {
                                            if !(v is UILabel) {
                                                v.frame.origin.y = vTxts.frame.size.width - v.frame.size.width
                                            }
                                        }
                                        self.textOnLeft = true
                                    }
                                    vTxts.center.y = iv.center.y
                                    self.arrTexts.addObject(vTxts)
                                    self.view.addSubview(vTxts)
                                    self.view.bringSubviewToFront(self.vMenu)
                                    
                                    self.queryFeedImages()

                                }

                            })
                        } else {
                            self.queryFeedImages()
                        }
                    } else {
                        self.queryFeedImages()
                    }
                })
            } else {
                self.queryFeedImages()
            }
        } else {
            self.queryFeedImages()
        }
    }
    
    func queryFeedImages() {
        self.counterFeedImages = 1
       // self.counter = 1
        let queryC = PFQuery(className: "Counter")
        queryC.whereKey("name", equalTo: "feedimages")
        
        queryC.getFirstObjectInBackgroundWithBlock { (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                self.countImages = object?.objectForKey("counter") as! Int
                //let queryI = PFQuery(className: "FeedImage")
                let queryI = PFQuery(className: "CuratedCollection")
                self.queryImages(queryI)
            } else {
                print("counter \(error)")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print("must launch edit is \(mustLaunchEditProfile)")
        if mustLaunchEditProfile {
            let ud = NSUserDefaults.standardUserDefaults()
            if let mlep : Bool? = ud.boolForKey("mustLaunchEditProfile") {
                if (mlep != nil) {
                    if mlep! {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let myCollec : MyCollectionController = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
                        self.navigationController?.pushViewController(myCollec, animated: false)
                    } else {
                        mustLaunchEditProfile = false
                    }
                }
            }
            
        } else {
            if !viewIsLoadingFirstTime {
                for v in self.view.subviews {
                    v.removeFromSuperview()
                }
                counterFeedImages = 0
                countImages = 0
                counter = 0
                arrImages = NSMutableArray()
                arrTexts = NSMutableArray()
                
                showedIV = 0
                textOnLeft = true
                buildMenu()
                queryLastEBookCurrentlyReading()
                
            }
        }
    }
    
    func delayIVLogo() {
        Functions.delay(0.1) {
            self.ivLogoTitle = LogoImageView(image: UIImage(named: "logo-old"))
            self.ivLogoTitle.frame.origin.y = 28
            self.ivLogoTitle.frame.size.height = 50
            self.ivLogoTitle.contentMode = UIViewContentMode.ScaleAspectFit
            self.ivLogoTitle.center.x = self.view.center.x
            let w = UIApplication.sharedApplication().keyWindow
            w?.addSubview(self.ivLogoTitle)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        vMenuIndicator.frame.origin.y = PERC_LightBrownHeight - PERC_BeigeHeight
        if ivLogoTitle == nil {
            ivLogoTitle = LogoImageView(image: UIImage(named: "logo-old"))
            ivLogoTitle.frame.origin.y = 28
            ivLogoTitle.frame.size.height = 50
            ivLogoTitle.contentMode = UIViewContentMode.ScaleAspectFit
            ivLogoTitle.center.x = self.view.center.x
            let w = UIApplication.sharedApplication().keyWindow
            w?.addSubview(ivLogoTitle)
        }
        self.ivLogoTitle.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        for v in UIApplication.sharedApplication().keyWindow!.subviews {
            if v.isKindOfClass(LogoImageView) {
                v.removeFromSuperview()
            }
        }
        ivLogoTitle = nil
        viewIsLoadingFirstTime = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        viewIsLoadingFirstTime = false
    }
    
    func queryImages(query : PFQuery){
        let fontName = UIFont(name: "Interstate-Bold", size: 20)
        //query.whereKey("i", equalTo: self.counterFeedImages)
        query.whereKey("positionInFeed", equalTo: self.counterFeedImages)
        query.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                let dat = object?.objectForKey("image") as! PFFile
                dat.getDataInBackgroundWithBlock({
                    (imageData: NSData?, error: NSError?) -> Void in

                    if (error != nil) {
                        print (error?.localizedDescription as Any)
                    }
                    else {

                        let panGest = UIPanGestureRecognizer(target: self, action: #selector(self.ivPanned))
                        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.goToMyCollectionSwipe))
                        swipeRight.direction = .Right
                        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.goToLibrarySwipe))
                        swipeLeft.direction = .Left
                        let tapIV = UITapGestureRecognizer(target: self, action: #selector(self.goToLibraryAndScroll))
                        var  iv = FeedImageView(image: UIImage(named: ""), id: self.counter)
                        if imageData != nil
                        {
                            iv = FeedImageView(image: UIImage(data: imageData!), id: self.counter)

                        }
                        iv.userInteractionEnabled = true
                        iv.frame.origin.x = 0
                        iv.tag = self.counterFeedImages
                        iv.frame.origin.y = self.counter == 0 ? CGFloat(64) : CGFloat(44) + CGFloat(self.counter) * (PERC_FeedImageHeight - 40)
                        iv.frame.size.width = screenWidth
                        iv.frame.size.height = PERC_FeedImageHeight
                        iv.gestureRecognizers = [panGest, swipeRight, swipeLeft, tapIV]
                        iv.contentMode = UIViewContentMode.ScaleAspectFill
                        self.cutImage(iv, c: self.counter)
                        self.view.addSubview(iv)
                        self.view.bringSubviewToFront(self.vMenu)
                        self.arrImages.addObject(iv)
                        self.counter += 1
                        self.counterFeedImages += 1

                        self.bonusCategories.addObject(object?.objectForKey("nameInLibrary") as! String)
                        self.bonusCategoriesTexts.addObject(object?.objectForKey("textForLibrary") as! String)

                        //let txts = object?.objectForKey("title") as! NSArray
                        let txts = object?.objectForKey("textForFeed") as! NSArray
                        let nbLines = txts.count
                        let grayColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 0.6)
                        let txtColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
                        let vTxts = UIView()
                        var maxWidth : CGFloat = 0
                        for i in 0  ..< nbLines {
                            let vCont = UIView()
                            let lab = UILabel()
                            lab.text = txts[i] as? String
                            lab.textColor = txtColor
                            lab.font = fontName
                            lab.sizeToFit()
                            vCont.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(i) * (PERC_DarkTealHeight + PERC_RedHeight)), size: CGSize(width: lab.frame.size.width + 2 * PERC_DarkRedWidth, height: PERC_DarkTealHeight))
                            vCont.backgroundColor = grayColor
                            vCont.addSubview(lab)
                            lab.center = CGPoint(x: vCont.frame.size.width / 2, y: vCont.frame.size.height / 2 + 1.5)
                            vTxts.addSubview(vCont)
                            if vCont.frame.size.width > maxWidth {
                                maxWidth = vCont.frame.size.width
                            }
                        }
                        vTxts.sizeToFit()
                        vTxts.frame.size.height = 3 * PERC_DarkTealHeight + 2 * PERC_RedHeight
                        if self.textOnLeft {
                            vTxts.frame.origin.x = 0.0
                            self.textOnLeft = false
                        } else {
                            vTxts.frame.origin.x = screenWidth - maxWidth
                            for v in vTxts.subviews {
                                if !(v is UILabel) {
                                    v.frame.origin.x = maxWidth - v.frame.size.width
                                }
                            }
                            self.textOnLeft = true
                        }
                        vTxts.center.y = iv.center.y
                        self.arrTexts.addObject(vTxts)
                        self.view.addSubview(vTxts)
                        
                        self.view.bringSubviewToFront(self.vMenu)
                        
                        self.queryImages(query)

                    }
                })
            } else {
                let backFont = UIFont(name: "MuseoSans-700", size: 15)
                self.bBackToTop = UIButton(frame: CGRect(x: 0.0, y: PERC_FeedImageHeight, width: screenWidth, height: screenHeight - PERC_FeedImageHeight))
                self.bBackToTop.backgroundColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1.0)
                self.bBackToTop.titleLabel!.textAlignment = NSTextAlignment.Center
                self.bBackToTop.titleLabel!.textColor = UIColor.whiteColor()
                self.bBackToTop.setTitle("Back to Top", forState: UIControlState.Normal)
                self.bBackToTop.addTarget(self, action: #selector(FeedController.backToTop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                self.bBackToTop.titleLabel?.font = backFont
                self.view.insertSubview(self.bBackToTop, atIndex: 0)
            }
        }
    }
    
    func cutImage(iv : UIImageView, c : Int){
        let path = CGPathCreateMutable()
        if self.counter == 0 {
            CGPathMoveToPoint(path, nil, 0.0, 0.0)
            CGPathAddLineToPoint(path, nil, screenWidth, 0.0)
            CGPathAddLineToPoint(path, nil, screenWidth, PERC_FeedImageHeight)
            CGPathAddLineToPoint(path, nil, halfScreenWidth, PERC_FeedImageHeight - 20.0)
            CGPathAddLineToPoint(path, nil, 0.0, PERC_FeedImageHeight)
            CGPathAddLineToPoint(path, nil, 0.0, 20.0)
        } else {
            CGPathMoveToPoint(path, nil, 0.0, 20.0)
            CGPathAddLineToPoint(path, nil, halfScreenWidth, 0.0)
            CGPathAddLineToPoint(path, nil, screenWidth, 20.0)
            CGPathAddLineToPoint(path, nil, screenWidth, PERC_FeedImageHeight)
            CGPathAddLineToPoint(path, nil, halfScreenWidth, PERC_FeedImageHeight - 20.0)
            CGPathAddLineToPoint(path, nil, 0.0, PERC_FeedImageHeight)
            CGPathAddLineToPoint(path, nil, 0.0, 20.0)
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayer.position = CGPoint(x: 0.0, y: 0.0)
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: PERC_FeedImageHeight)
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        
        iv.layer.mask = shapeLayer
    }
    
    @IBAction func goToLibraryAndScroll(sender : UITapGestureRecognizer){
        if hv != nil {
            if hv.hidden == false {
                hv.disappear()
            } else {
                goToPage(sender)
            }
        } else {
            goToPage(sender)
        }
    }
    
    func goToPage(sender : UITapGestureRecognizer) {
        if menuShowed {
            showMenu()
        } else {
            let t = sender.view!.tag
            if t == 0 {
                if nowReadingLoaded {

                    var book: Book = Book()
                    book.bookId = lastIdInCurrentlyReading
                    book.cover = (sender.view! as! UIImageView).image

                    FolioHelper.preload(book, completion: { (bookPath, error) in
                        if (error != nil) {
                            print (error?.localizedDescription as Any)
                        }
                        else {
                            if let bPath = bookPath {
                                print ("Book path = \(bookPath)")
                                self.openFolioReaderWithPath(bPath)
                            }
                        }
                    })

                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : LibraryController = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : CuratedCollectionController = storyboard.instantiateViewControllerWithIdentifier("curatedcollection") as! CuratedCollectionController
                //vc.scrollTo = "bonus\(t - 1)"
                let id = t - 1
                vc.bonusCatId = id
                vc.bonusCatName = bonusCategories[id] as! String
                vc.bonusCatDescription = bonusCategoriesTexts[id] as! String
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func openFolioReaderWithPath(bookPath:String) {
        //NEW CODE
        let config = FolioReaderConfig()
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: config, shouldRemoveEpub: false, animated: true)
    }

    func openTestEPub() {
        let file = "Brave_New_World_Aldous_Huxley"
        let config = FolioReaderConfig()
        let bookPath = NSBundle.mainBundle().pathForResource(file, ofType: "epub")
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
    }

    func launchReadingWithBanner(sender : UITapGestureRecognizer) {
        // OLD CODE
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ReadingWithBannerController = storyboard.instantiateViewControllerWithIdentifier("readingwithbanner") as! ReadingWithBannerController
        vc.bookId = lastIdInCurrentlyReading
        vc.cover = (sender.view! as! UIImageView).image
    }

    func backToTop(sender : UIButton){
        hvDisappear()
        self.showedIV = 0
        for i in 0  ..< self.arrImages.count {
            let t = i
            let iv = self.arrImages[t] as! UIImageView
            let vTxt = self.arrTexts[t] as! UIView
            if t == 0 {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {
                        iv.frame.origin.y = CGFloat(44)
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {
                        iv.frame.origin.y = CGFloat(44) + CGFloat(t) * (PERC_FeedImageHeight - 40)
                    }, completion: nil)
            }
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    vTxt.center.y = self.view.center.y + CGFloat(t) * PERC_FeedImageHeight
                }, completion: nil)
            
            self.view.bringSubviewToFront(iv)
            self.view.bringSubviewToFront(vTxt)
        }
    }
    
    func resetEachTextView() {
        let n = arrImages.count
        for i in 0  ..< n {
            (arrTexts[i] as! UIView).center.y = (arrImages[i] as! UIView).center.y
        }
    }
    
    func ivPanned(g: UIPanGestureRecognizer){
        //Specific  transition, see FastCompany app
        if g.state == UIGestureRecognizerState.Began {
            hvDisappear()
            moveStartY = g.view!.center.y
            moveStartX = g.locationInView(g.view!).x //If the panning is more a swipe left and right than a panning up and down, let'sgo to my collection or library
        } else if g.state == UIGestureRecognizerState.Changed {
            //Moving the view according to the pan gesture
            var center = g.view!.center
            let tr = g.translationInView(g.view!)
            let velocity = g.velocityInView(self.view)
            let fiv = g.view as! FeedImageView
            let idSelected = fiv.id
            if velocity.y < 0 {
                //Go up
                //if self.showedIV + 1 != arrImages.count {
                center = CGPoint(x: center.x, y: (center.y + ((showedIV == arrImages.count - 1) ? tr.y / 2.5 : tr.y))) //update july 2016 : if first or last, bounces effect
                    g.view!.center = center
                    g.setTranslation(CGPointZero, inView: g.view)
                    
                    if idSelected < arrImages.count - 1 {
                        let ivNext = arrImages[idSelected + 1] as! UIImageView
                        ivNext.center.y = center.y + (PERC_FeedImageHeight - 40)//Next one follows
                        let vTextNext = arrTexts[showedIV + 1] as! UIView
                        vTextNext.center.y = ivNext.center.y
                        if idSelected < arrImages.count - 2 {
                            let ivAfter = arrImages[idSelected + 2] as! UIImageView
                            ivAfter.center.y = center.y + (PERC_FeedImageHeight - 40) * 2//One after as well
                        }
                    }
                    if idSelected > 0 {
                        let ivPrevious = arrImages[idSelected - 1] as! UIImageView
                        ivPrevious.center.y = center.y - PERC_FeedImageHeight + 40
                        if idSelected < 1 {
                            let ivBefore = arrImages[idSelected - 2] as! UIImageView
                            ivBefore.center.y = center.y - (PERC_FeedImageHeight + 40) * 2
                        }
                    }
                if showedIV == arrImages.count - 1 {
                    bBackToTop.frame.origin.y = CGRectGetMaxY(g.view!.frame) - 40
                }
                //}
            } else {
                //Go down
                //if self.showedIV != 0 {
                center = CGPoint(x: center.x, y: (center.y + ((showedIV == 0) ? tr.y / 2.5 : tr.y))) //update july 2016 : if first or last, bounces effect
                    g.view!.center = center
                    g.setTranslation(CGPointZero, inView: g.view)
                    
                    let vTxt = arrTexts[self.showedIV] as! UIView
                    vTxt.center.y = arrImages[showedIV].center.y
                    if idSelected > 0 {
                        let ivPrevious = arrImages[idSelected - 1] as! UIImageView
                        ivPrevious.center.y = center.y - PERC_FeedImageHeight + 25
                        if idSelected < 1 {
                            let ivBefore = arrImages[idSelected - 2] as! UIImageView
                            ivBefore.center.y = center.y - (PERC_FeedImageHeight + 25) * 2
                        }
                    }
                    if idSelected < arrImages.count - 1 {
                        let ivNext = arrImages[idSelected + 1] as! UIImageView
                        ivNext.center.y = center.y + (PERC_FeedImageHeight - 40)//Next one follows
                        if idSelected < arrImages.count - 2 {
                            let ivAfter = arrImages[idSelected + 2] as! UIImageView
                            ivAfter.center.y = center.y + (PERC_FeedImageHeight - 40) * 2//One after as well
                        }
                    }
                //}
            }
        } else if g.state == UIGestureRecognizerState.Ended {
            let velocity = g.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            let slideFactor = 0.035 * slideMultiplier
            moveEndY = g.view!.center.y
            moveEndX = g.locationInView(g.view!).x
            let ivCurrent = self.arrImages[self.showedIV] as! UIImageView // current one
            let vTextCurrent = arrTexts[self.showedIV] as! UIView
            
            if velocity.y < 0 {
                if self.showedIV + 1 != arrImages.count {
                    //We went up, we gotta check if there is another view after this one
                    if showedIV < arrImages.count - 1 {
                        let iv = self.arrImages[self.showedIV + 1] as! UIImageView // next one
                        let vTextNext = arrTexts[self.showedIV + 1] as! UIView
                        moveEndY = g.view!.center.y
                        //We wanna check if the user really swiped the view or not
                        if (moveStartY - moveEndY) > 0.45 * screenWidth {
                            //We animate according to the velocity of the swipe gesture
                            UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                                animations: {
                                    g.view!.frame.origin.y = 84 - PERC_FeedImageHeight
                                    iv.frame.origin.y = 44
                                    vTextNext.center.y = iv.center.y
                                    if self.showedIV < self.arrImages.count - 2 {
                                        let iv2 = self.arrImages[self.showedIV + 2] as! UIImageView
                                        iv2.frame.origin.y = PERC_FeedImageHeight + 44 - 40
                                    }
                                }, completion: { _ in
                                    self.showedIV += 1
                                    return
                            })
                        } else {
                            //Panning was not enough but maybe it was because the user was trying to swipe left or right :
                            checkIfPanningWasASwipeLeftOrRight()
                            //The user did not really swipe the view, we go back to the first position
                            UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                //g.view!.frame.origin.y = 44
                                ivCurrent.frame.origin.y = 44
                                iv.frame.origin.y = 44 + PERC_FeedImageHeight - 40
                                vTextNext.center.y = iv.center.y
                                }, completion: nil)
                        }
                    }
                } else {
                    checkIfPanningWasASwipeLeftOrRight()
                    //No view after this one, we go back to the previous position
                    UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        ivCurrent.frame.origin.y = 44
                        vTextCurrent.center.y = ivCurrent.center.y
                        self.bBackToTop.frame.origin.y = PERC_FeedImageHeight
                        }, completion: nil)
                }
            } else {
                if self.showedIV != 0 {
                    //We went down, we check if there s a view before this one
                    let vTxt = arrTexts[self.showedIV] as! UIView
                    if showedIV > 0 {
                        let iv = self.arrImages[self.showedIV - 1] as! UIImageView
                        
                        moveEndY = g.view!.center.y
                        if (moveEndY - moveStartY) > 0.45 * screenWidth {
                            //The first image has a different origin (sorry for the mess) its origin is 64 and not 44
                            if showedIV == 1 {
                                UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    g.view!.frame.origin.y = 64 + PERC_FeedImageHeight - 40
                                    vTxt.center.y = g.view!.center.y
                                    iv.frame.origin.y = 64
                                    }, completion: { _ in
                                        self.showedIV -= 1
                                        return
                                })
                            } else {
                                UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                    g.view!.frame.origin.y = 44 + PERC_FeedImageHeight - 40
                                    vTxt.center.y = g.view!.center.y
                                    iv.frame.origin.y = 44
                                    }, completion: { _ in
                                        self.showedIV -= 1
                                        return
                                })
                            }
                        } else {
                            checkIfPanningWasASwipeLeftOrRight()
                            UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                g.view!.frame.origin.y = 44
                                vTxt.center.y = g.view!.center.y
                                iv.frame.origin.y = -PERC_FeedImageHeight + 25 + 44
                                if self.showedIV < self.arrImages.count - 1 {
                                    let iv2 = self.arrImages[self.showedIV + 1] as! UIImageView
                                    iv2.frame.origin.y = PERC_FeedImageHeight + 44 - 40
                                }
                                }, completion: nil)
                        }
                    }
                } else {
                    checkIfPanningWasASwipeLeftOrRight()
                    //No view before this one, we go back to previous position
                    UIView.animateWithDuration(nonZeroSlideFactor(slideFactor), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        ivCurrent.frame.origin.y = 64
                        vTextCurrent.center.y = ivCurrent.center.y
                        if self.showedIV < self.arrImages.count - 1 {
                            let iv2 = self.arrImages[self.showedIV + 1] as! UIImageView
                            iv2.frame.origin.y = PERC_FeedImageHeight + 64 - 40
                        }
                        }, completion: nil)
                }
            }
            resetEachTextView()
        }
    }
    
    func nonZeroSlideFactor(slideFactor : CGFloat) -> Double {
        if slideFactor > 1.5 {
            return 0.45
        } else if(slideFactor < 0.1) {
            return 0.3
        } else {
            return Double(slideFactor)
        }
    }
    
    func hvDisappear() {
        if hv != nil {
            hv.disappear()
        }
    }
    
    func checkIfPanningWasASwipeLeftOrRight() {
        if moveStartX - moveEndX > 0.6 * screenWidth {
            //Swipe left -> Library
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : LibraryController = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if moveEndX - moveStartX > 0.6 * screenWidth {
            //Swipe right -> my collection
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myCollec : MyCollectionController = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
            let trans = CATransition()
            trans.duration = 0.5
            trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            trans.type = kCATransitionMoveIn
            trans.subtype = kCATransitionFromLeft
            self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
            self.navigationController?.pushViewController(myCollec, animated: false)
        }
    }
    
    func goToLibrarySwipe(sender : UIGestureRecognizer){
        if self.menuShowed {
            self.showMenu()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : LibraryController = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func goToMyCollectionSwipe(sender : UIGestureRecognizer){
        if self.menuShowed {
            self.showMenu()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myCollec : MyCollectionController = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromLeft
        self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
        self.navigationController?.pushViewController(myCollec, animated: false)
        
    }
}
