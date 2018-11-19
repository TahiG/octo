//
//  LibraryController.swift
//  Globe3
//
//  Created by Charles Masson on 21/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse


class LibraryController : ControllerAvecMenu, UIScrollViewDelegate {
    
    @IBOutlet var scMain : UIScrollView!
    //@IBOutlet var ivHeader : UIImageView!
    
    let allCategories = ["Romance", "Mystery", "Biography", "Academic", "Poetry", "Adventure", "Self-Help", "Sci-Fi", "Classic", "Erotica", "Young Adult", "Business"]
    var bonusCategories = Dictionary<Int, String>()//: Dictionary<Int, String>!//= Dictionary<Int, String>()
    var bonusCategoriesReverse = Dictionary<String, Int>()//: Dictionary<String, Int>!//= Dictionary<String, Int>()
    //var bonusCategoriesTexts : NSArray!
    var dic = Dictionary<String, CGFloat>()
    
    var activityIndicator : UIActivityIndicatorView!
    var arrLike = NSMutableArray()
    var arrHate = NSMutableArray()
    var arrWhatever = NSMutableArray()
    
    var nextColorIsBlue = true
    let user = PFUser.currentUser()
    
    var viewCounter = 0//Count the two scroll view containers (15 of them)
    
    var counterFeaturedByCategory = Dictionary<String, Int>()//Count the books in each category
    var counterLatestByCategory = Dictionary<String, Int>()//Count the books in each category (a counter for each scroll view)
    
    var lastView : UIView! //Allow me to set the size of th main scroll view properly
    var hateCounter = 0 //Easier way to place hate container views
    var bonusCategory = 0 // Count the bonus categories in order to search them in PARSE
    
    var mainQueries = NSMutableArray()
    //Constants for the views
    let mainHeight = PERC_TitlePurpleHeight + PERC_GreenHeight * 2 + PERC_LibCoverHeight * 2 + PERC_YellowHeight + PERC_BlueHeight
    let containerHeight = 2 * PERC_GreenHeight + 2 * PERC_LibCoverHeight + PERC_DarkRedWidth
    let scrollContentWidth = 7 * PERC_LibCoverWidth + 8 * PERC_DarkRedWidth
    let titleFont = UIFont(name: "Interstate-Regular", size: 17)
    let moreFont = UIFont(name: "Interstate-Regular", size: 15)
    let lFont = UIFont(name: "MuseoSans-700", size: 12)
    let colVContainer = UIColor(red: 245/255, green: 246/255, blue: 253/255, alpha: 1.0)
    let colVRedContainer = UIColor(red: 255/255, green: 235/255, blue: 232/255, alpha: 1.0)
    let colClassicBlue = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1.0)
    let colClassicRed = UIColor(red: 255/255, green: 60/255, blue: 0/255, alpha: 1.0)
    
    let colClassicBlueUnavailable = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 0.6)
    let colClassicRedUnavailable = UIColor(red: 255/255, green: 60/255, blue: 0/255, alpha: 0.6)
    //If clicked on image in the feed :
    var scrollTo = ""
    
    var hv : HelpView!
    
    override func viewDidLoad() {
        //buildMenu()
        super.viewDidLoad()
        navigationItem.title = "Library"
        
        let tapSC = UITapGestureRecognizer(target: self, action: #selector(scTapped))
        scMain.addGestureRecognizer(tapSC)
        
        vMenu.hidden = true
        Functions.delay(0.5){
            self.vMenu.hidden = false
        }
        bonusCategories[100] = "THE NOVELLA AWARDS 2015"
        bonusCategories[101] = "BILL GATE'S FAVOURITES..."
        bonusCategories[102] = "NEW. YOUNG. AUTHORS."
        bonusCategoriesReverse["THE NOVELLA AWARDS 2015"] = 100
        bonusCategoriesReverse["BILL GATE'S FAVOURITES..."] = 101
        bonusCategoriesReverse["NEW. YOUNG. AUTHORS."] = 102
        
        addActivityIndicator()
        
        //Init counterByCategory
        for s in allCategories {
            counterLatestByCategory[s] = 0
            counterFeaturedByCategory[s] = 0
        }
        for i in 0  ..< 3  {
            counterLatestByCategory["bonuscategory\(i)"] = 0
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backToFeedSwipe))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        if let didEnterPreferences = user?.objectForKey("didEnterPreferences") as? Bool {
            if didEnterPreferences {
                //Retrieve the infos
                if let booklike = user?.objectForKey("booklike") as? NSMutableArray {
                    arrLike = booklike
                }
                if let bookhate = user?.objectForKey("bookhate") as? NSMutableArray {
                    arrHate = bookhate
                }
                for st in allCategories {
                    if !arrLike.containsObject(st) && !arrHate.containsObject(st) {
                        arrWhatever.addObject(st)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.buildViews()
                    
                    if !self.scrollTo.isEmpty {
                        //UIView.animateWithDuration(0.4, animations: {
                        self.scMain.contentOffset = CGPoint(x: 0, y: self.dic[self.scrollTo]! - 64)
                        //})
                    }
                })
            } else {
                let alert = UIAlertController(title: "Library", message: "You cannot see the library content before you enter your preferences", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Library", message: "You cannot see the library content before you enter your preferences", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        let ud = NSUserDefaults.standardUserDefaults()
        /*ud.setBool(true, forKey: "FIRSTTIME_LIBRARY")
        ud.synchronize()*/
        if let firstTime = ud.objectForKey("FIRSTTIME_LIBRARY") as? Bool {
            if firstTime {
                makeHV(ud)
            }
        } else {
            makeHV(ud)
        }
        
        scMain.delegate = self
    }
    
    func makeHV(ud : NSUserDefaults) {
        hv = HelpView(text: "Discover and rediscover all the classics in our library.\n\nMore genres coming soon.", arrow: true, origin: PERC_LibHeaderHeight + 69)
        hv.center.x = self.view.center.x
        UIApplication.sharedApplication().keyWindow!.addSubview(hv)
        hv.setBold(NSMakeRange(0, 24))
        ud.setBool(false, forKey: "FIRSTTIME_LIBRARY")
        ud.synchronize()
    }
    
    override func viewWillAppear(animated: Bool) {
        vMenuIndicator.frame.origin.y = PERC_LightBrownHeight + 1
    }
    
    override func viewWillDisappear(animated: Bool) {
        for q in mainQueries {
            (q as! PFQuery).cancel()
        }
    }
    
    func searchClicked(){
        
    }
    
    func buildViews() {
        let ivHeader = UIImageView(/*image: UIImage(named: "libheader")*/)
        setImageHeader(ivHeader)
        ivHeader.frame.origin.x = 0.0
        ivHeader.frame.origin.y = 0.0
        ivHeader.frame.size.width = screenWidth
        ivHeader.frame.size.height = PERC_LibHeaderHeight
        ivHeader.contentMode = UIViewContentMode.ScaleAspectFill
        ivHeader.clipsToBounds = true
        scMain.addSubview(ivHeader)
        
        scMain.frame.origin.x = 0.0
        scMain.frame.origin.y = 0.0
        scMain.frame.size.width = screenWidth
        scMain.frame.size.height = screenHeight// - 64
        scMain.scrollEnabled = true
        scMain.showsVerticalScrollIndicator = false
        
        var originY = CGRectGetMaxY(ivHeader.frame)
        
        
        for cat in self.arrLike {
            originY = buildCategoryView(cat as! String, originY: originY)
        }
        
        for cat in arrWhatever {
            originY = buildCategoryView(cat as! String, originY: originY)
        }
        
        for cat in arrHate {
            originY = buildCategoryView(cat as! String, originY: originY)
        }
        
        scMain.contentSize = CGSize(width: screenWidth, height: originY + 10.0)
        
        //OLD VERSION WHEN ALL CATEGORIES HAD TWO SCROLL VIEWS BELOW THE TITLE
        /*var bottom : CGFloat!
        //Builds the views containing the scroll views
        for like in self.arrLike {
            bottom = buildDoubleScrollView((like as? String)!, isHate : false, hateYBase : 0)
        }
        
        for bof in arrWhatever {
            bottom = buildDoubleScrollView((bof as? String)!, isHate : false, hateYBase : 0)
        }*/
        
        //The novella awards 2015
        /*bottom = buildSingleScrollView("THE NOVELLA AWARDS 2015", text: "This year the award is judged by Alison Moore, award-winning author of The Lighthouse and He Wants, and Nicholas Royle; editor at Salt Publishing. Read the official 2015 winner The Harlequin by Nina Allen as well as runners up of the annual awards.", originY: bottom)
        
        //Bill gates favurites
        bottom = buildSingleScrollView("BILL GATE'S FAVOURITES...", text: "Bill Gates has a schedule that’s planned down to the minute but the entrepreneur and billionaire humanitarian still manages about a book a week. Take a look at Gate’s recommended reading list, essential for those attempting to follow in his footsteps.", originY: bottom)
        
        //New young authrs
        bottom = buildSingleScrollView("NEW. YOUNG. AUTHORS.", text: "Great young talent is like a pearl of opportunity in the literary world. It brings fresh ideas to the page, complete with unique generational insight. Our selection of New Young Authors is a symbol of the future of writing and storytelling.", originY: bottom)*/
        
        /*for hate in arrHate {
            bottom = buildDoubleScrollView((hate as? String)!, isHate: true, hateYBase: bottom)
            //hateCounter++
        }*/
        
        //scMain.contentSize = CGSize(width: screenWidth, height: bottom + 10.0)
        
        removeActivityIndicator()
    }
    
    func buildCategoryView(cat: String, originY: CGFloat) -> CGFloat {
        let vLab = UIView(frame: CGRect(x: PERC_BlackWidth, y: PERC_BlueHeight + originY, width: AlmostFullWidth, height: PERC_TitlePurpleHeight))
        let lTitle = UILabel()
        lTitle.text = cat
        lTitle.font = titleFont
        lTitle.sizeToFit()
        lTitle.frame.size.height = PERC_TitlePurpleHeight
        lTitle.frame.origin = CGPoint(x: 10, y: 0)
        lTitle.textColor = UIColor.whiteColor()
        vLab.addSubview(lTitle)
        if cat == "Classic" {
            let bMore = UIButton()
            bMore.setTitle("SEE ALL", forState: .Normal)
            bMore.sizeToFit()
            bMore.titleLabel!.font = moreFont
            bMore.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            bMore.center.y = vLab.frame.size.height / 2
            bMore.frame.origin.x = AlmostFullWidth - bMore.frame.size.width - 10
            bMore.addTarget(self, action: #selector(classicMoreClicked), forControlEvents: .TouchUpInside)
            vLab.addSubview(bMore)
        }
        scMain.addSubview(vLab)
        let vContainer = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(vLab.frame), width: AlmostFullWidth, height: containerHeight))
        let scFeatured = UIScrollView()
        scFeatured.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scFeatured.frame = CGRect(x: 0, y: PERC_GreenHeight, width: AlmostFullWidth, height: PERC_LibCoverHeight)
        scFeatured.tag = getTagFromCat(cat)
        searchBooks(cat, sv: scFeatured, latest: false)//GETTING THE BOOKS HERE
        vContainer.addSubview(scFeatured)
        let scLatest = UIScrollView()
        scLatest.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scLatest.frame = CGRect(x: 0, y: PERC_GreenHeight + CGRectGetMaxY(scFeatured.frame), width: AlmostFullWidth, height: PERC_LibCoverHeight)
        scLatest.tag = getTagFromCat(cat)
        searchBooks(cat, sv: scLatest, latest: true)//GETTING THE BOOKS HERE
        vContainer.addSubview(scLatest)
        scMain.addSubview(vContainer)
        
        if nextColorIsBlue {
            //nextColorIsBlue = false UPDATE July 2016 : red is too much like a warning
            vContainer.backgroundColor = colVContainer
            vLab.backgroundColor = colClassicBlue
        } else {
            nextColorIsBlue = true
            vContainer.backgroundColor = colVRedContainer
            vLab.backgroundColor = colClassicRed
        }
        
        return CGRectGetMaxY(vContainer.frame)
    }
    
    func moreClicked(sender: UIButton) {
        
    }
    
    func setImageHeader(iv : UIImageView) {
        let q = PFQuery(className: "Images")
        q.whereKey("imageId", equalTo: "libraryheader")
        q.getFirstObjectInBackgroundWithBlock{(o: PFObject?, error: NSError?) -> Void in
            if error == nil {
                if o != nil {
                    if let i = o!.objectForKey("image") as? PFFile {
                        i.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    let img = UIImage(data: data!)
                                    iv.image = img
                                    print("img set")
                                })
                            } else {
                                print(error)
                            }
                        })
                    }
                }
            } else { print(error) }
        }
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
    
    //Ferbruary Classic 'more' button leads to another controller
    func classicMoreClicked(sender : UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : DetailedCategoryController = storyboard.instantiateViewControllerWithIdentifier("detailedcategory") as! DetailedCategoryController
        
        vc.catTitle = "Classic"
        vc.subCategories = ["Everlasting Love", "Timeless Tales", "Undercover Classics", "More"]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //This method build the views containing two scroll views and return the bottom of the container
    func buildDoubleScrollView(cat : String, isHate : Bool, hateYBase : CGFloat) -> CGFloat {
        let vLab = UIView()
        vLab.frame.origin.x = PERC_BlackWidth
        if isHate {
            vLab.frame.origin.y = hateYBase + PERC_BlueHeight + CGFloat(hateCounter) * (mainHeight)
        } else {
            vLab.frame.origin.y = PERC_BlueHeight + PERC_LibHeaderHeight + CGFloat(viewCounter) * (mainHeight)
        }
        vLab.frame.size.width = AlmostFullWidth
        vLab.frame.size.height = PERC_TitlePurpleHeight
        let lTitle = UILabel()
        lTitle.text = getCatTitle(cat)
        lTitle.font = titleFont
        lTitle.sizeToFit()
        lTitle.frame.size.height = PERC_TitlePurpleHeight
        lTitle.frame.origin.x = 10.0
        lTitle.frame.origin.y = 0.0
        vLab.addSubview(lTitle)
        scMain.addSubview(vLab)
        let vContainer = UIView()
        vContainer.frame.origin.x = PERC_BlackWidth
        if isHate {
            vContainer.frame.origin.y = hateYBase + PERC_BlueHeight + PERC_TitlePurpleHeight + CGFloat(hateCounter) * (mainHeight)
        } else {
            vContainer.frame.origin.y = CGRectGetMaxY(vLab.frame)//PERC_BlueHeight + 64 + PERC_TitlePurpleHeight + CGFloat(viewCounter) * (mainHeight)
        }
        vContainer.frame.size.width = AlmostFullWidth
        vContainer.frame.size.height = containerHeight
        /*let lFeatured = UILabel()
        lFeatured.text = "Featured"
        lFeatured.font = lFont
        lFeatured.sizeToFit()
        lFeatured.frame.origin.x = PERC_DarkRedWidth
        lFeatured.frame.origin.y = PERC_GreenHeight - lFeatured.frame.size.height - PERC_RedHeight
        vContainer.addSubview(lFeatured)*/
        let scFeatured = UIScrollView()
        scFeatured.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scFeatured.frame.origin.y = PERC_GreenHeight
        scFeatured.frame.origin.x = 0.0
        scFeatured.frame.size.height = PERC_LibCoverHeight
        scFeatured.frame.size.width = AlmostFullWidth
        scFeatured.tag = getTagFromCat(cat)
        searchBooks(cat, sv: scFeatured, latest: false)//GETTING THE BOOKS HERE
        vContainer.addSubview(scFeatured)
        /*let lLatest = UILabel()
        lLatest.text = "Latest"
        lLatest.font = lFont
        lLatest.sizeToFit()
        lLatest.frame.origin.x = PERC_DarkRedWidth
        lLatest.frame.origin.y = CGRectGetMaxY(scFeatured.frame) + PERC_GreenHeight - lFeatured.frame.size.height - PERC_RedHeight
        vContainer.addSubview(lLatest)*/
        let scLatest = UIScrollView()
        scLatest.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scLatest.frame.origin.y = PERC_GreenHeight + CGRectGetMaxY(scFeatured.frame)
        scLatest.frame.origin.x = 0.0
        scLatest.frame.size.height = PERC_LibCoverHeight
        scLatest.frame.size.width = AlmostFullWidth
        scLatest.tag = getTagFromCat(cat)
        searchBooks(cat, sv: scLatest, latest: true)//GETTING THE BOOKS HERE
        vContainer.addSubview(scLatest)
        scMain.addSubview(vContainer)
        
        if nextColorIsBlue {
            nextColorIsBlue = false
            vContainer.backgroundColor = colVContainer
            vLab.backgroundColor = colClassicBlue
            /*lFeatured.textColor = colClassicBlue
            lLatest.textColor = colClassicBlue*/
        } else {
            nextColorIsBlue = true
            vContainer.backgroundColor = colVRedContainer
            vLab.backgroundColor = colClassicRed
            /*lFeatured.textColor = colClassicRed
            lLatest.textColor = colClassicRed*/
        }
        lTitle.textColor = UIColor.whiteColor()
        scFeatured.scrollEnabled = true
        scFeatured.userInteractionEnabled = true
        scLatest.scrollEnabled = true
        scLatest.userInteractionEnabled = true
        //This way, when user clicks on an image i the feed, we can scroll to it
        dic[cat] = vLab.frame.origin.y
        viewCounter += 1
        
        if viewCounter == 15 {
            lastView = vContainer
        }
        
        return CGRectGetMaxY(vContainer.frame)
    }
    //This method build the views containing one scroll view and return the bottom of the container
    func buildSingleScrollView(title : String, text : String, originY : CGFloat) -> CGFloat {
        let vLabYou = UIView()
        vLabYou.frame.origin.x = PERC_BlackWidth
        vLabYou.frame.origin.y = PERC_BlueHeight + originY
        vLabYou.frame.size.width = AlmostFullWidth
        vLabYou.frame.size.height = PERC_TitlePurpleHeight
        let lTitleYou = UILabel()
        lTitleYou.text = title
        lTitleYou.font = titleFont
        lTitleYou.sizeToFit()
        lTitleYou.frame.size.height = PERC_TitlePurpleHeight
        lTitleYou.frame.origin.x = 10.0
        lTitleYou.frame.origin.y = 0.0
        vLabYou.addSubview(lTitleYou)
        scMain.addSubview(vLabYou)
        let vContainerYou = UIView()
        vContainerYou.frame.origin.x = PERC_BlackWidth
        vContainerYou.frame.origin.y = CGRectGetMaxY(vLabYou.frame)
        vContainerYou.frame.size.width = AlmostFullWidth
        vContainerYou.frame.size.height = containerHeight
        let lFeaturedYou = UILabel()
        lFeaturedYou.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        lFeaturedYou.numberOfLines = 0
        lFeaturedYou.frame.size.width = AlmostFullWidth - 2 * PERC_DarkRedWidth
        lFeaturedYou.text = text
        //lFeaturedYou.font = lFont
        lFeaturedYou.frame.origin.x = PERC_DarkRedWidth
        lFeaturedYou.frame.origin.y = PERC_DarkRedWidth
        lFeaturedYou.sizeToFit()
        vContainerYou.addSubview(lFeaturedYou)
        let scLatestYou = UIScrollView()
        scLatestYou.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scLatestYou.frame.origin.y = /*EDIT 2 November REMOVE THIS SPACE PERC_PurpleHeight REEDIT 17 Nov reput the space+*/PERC_PurpleHeight + CGRectGetMaxY(lFeaturedYou.frame)
        scLatestYou.frame.origin.x = 0.0
        scLatestYou.frame.size.height = PERC_LibCoverHeight
        scLatestYou.frame.size.width = AlmostFullWidth
        scLatestYou.tag = getBonusTagFromCat(title)
        searchBooks("bonuscategory\(self.bonusCategory)", sv: scLatestYou, latest: true)//GETTING THE BOOKS HERE
        vContainerYou.addSubview(scLatestYou)
        vContainerYou.frame.size.height = 2 * PERC_DarkRedWidth + PERC_PurpleHeight + lFeaturedYou.frame.size.height + scLatestYou.frame.size.height
        scMain.addSubview(vContainerYou)
        //This way, when user clicks on an image i the feed, we can scroll to it
        dic["bonus\(bonusCategory)"] = vLabYou.frame.origin.y
        
        if nextColorIsBlue {
            nextColorIsBlue = false
            vContainerYou.backgroundColor = colVContainer
            vLabYou.backgroundColor = colClassicBlue
            lFeaturedYou.textColor = colClassicBlue
        } else {
            nextColorIsBlue = true
            vContainerYou.backgroundColor = colVRedContainer
            vLabYou.backgroundColor = colClassicRed
            lFeaturedYou.textColor = colClassicRed
        }
        lTitleYou.textColor = UIColor.whiteColor()
        scLatestYou.scrollEnabled = true
        scLatestYou.userInteractionEnabled = true
        viewCounter += 1
        self.bonusCategory += 1
        return CGRectGetMaxY(vContainerYou.frame)
    }
    
    func searchBooks(cat : String, sv : UIScrollView, latest : Bool){
        //Query
        let query = PFQuery(className:"Book")
        query.whereKey("category", containsString: cat)
        if !latest {
            query.whereKey("latest", notEqualTo: latest)
        } else {
            query.whereKey("latest", equalTo: latest)
        }
        //To cancel the queries, we keep a reference of them
        self.mainQueries.addObject(query)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) books from \(cat) category")
                
                if let objects = objects {
                    for object in objects {
                        print(object.objectId)
                        //We create a view for each book
                        var ivCover : UIImageView!
                        if latest {
                            ivCover = UIImageView(frame: CGRect(x: PERC_DarkRedWidth + CGFloat(self.counterLatestByCategory[cat]!) * (PERC_DarkRedWidth + PERC_LibCoverWidth), y: 0.0, width: PERC_LibCoverWidth, height: PERC_LibCoverHeight))
                        } else {
                            ivCover = UIImageView(frame: CGRect(x: PERC_DarkRedWidth + CGFloat(self.counterFeaturedByCategory[cat]!) * (PERC_DarkRedWidth + PERC_LibCoverWidth), y: 0.0, width: PERC_LibCoverWidth, height: PERC_LibCoverHeight))
                        }
                        
                        let bId = UIButton(frame: ivCover.frame)
                        bId.frame.origin = CGPoint(x: 0.0, y: 0.0)
                        if let uProfilePict = object.objectForKey("covermini") as? PFFile {
                            uProfilePict.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let img = UIImage(data: data!)
                                        ivCover.image = img
                                    })
                                } else {
                                    print(error?.localizedDescription as Any)
                                }
                            })
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            //The id of the book
                            bId.setTitle(object.objectId, forState: UIControlState.Normal)
                            bId.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), forState: UIControlState.Normal)
                            bId.addTarget(self, action: #selector(LibraryController.bookClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                            sv.addSubview(ivCover)
                            ivCover.addSubview(bId)
                            ivCover.userInteractionEnabled = true
                            sv.contentSize = CGSize(width: CGRectGetMaxX(ivCover.frame) + PERC_DarkRedWidth, height: sv.frame.size.height)
                        })
                        if latest {
                            self.counterLatestByCategory[cat] = self.counterLatestByCategory[cat]! + 1
                        } else {
                            self.counterFeaturedByCategory[cat] = self.counterFeaturedByCategory[cat]! + 1
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func getCatTitle(s : String) -> String {
        //The titles of the categories have changed so instead of changing the database, we replace by the new ones
        if s == "Business" {
            return "Business & Startups"
        } else if s == "Biography" {
            return "Biographies & Memoirs"
        } else if s == "Adventure" {
            return "Fantasy & Adventure"
        } else if s == "Self-Help" {
            return "Self-Help & Spirituality"
        } else if s == "Poetry" {
            return "Short Stories & Poetry"
        } else if s == "Academic" {
            return "Academic & Reference"
        } else {
            return s
        }
    }
    
    func getTagFromCat(cat : String) -> Int {
        return allCategories.indexOf(cat)!
    }
    
    func getBonusTagFromCat(cat : String) -> Int {
        return bonusCategoriesReverse[cat]!
    }
    
    @IBAction func bookClicked(sender : UIButton){
        hvDisappear()
        if menuShowed {
            showMenu()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : BookDescriptionController = storyboard.instantiateViewControllerWithIdentifier("bookdescription") as! BookDescriptionController
            
            let iv = sender.superview as! UIImageView
            if iv.image != nil {
                vc.bookCover = iv.image!
            }
            vc.bookId = sender.titleLabel?.text
            let tag = iv.superview?.tag //tag of all the categories has been set in buildScrollView or so
            var backText = ""
            if tag < 100 { backText = getCatTitle(allCategories[tag!])//Bonus categories
            } else { backText = bonusCategories[tag!]! }//Normal categories
            
            if backText.characters.count > 12 {
                backText = (backText as NSString).substringToIndex(12)
                backText += "..."
            }
            navigationItem.backBarButtonItem = UIBarButtonItem(title: backText, style: .Plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func scTapped(sender : UITapGestureRecognizer) {
        if menuShowed { showMenu() }
    }
    
    func hvDisappear() {
        if hv != nil {
            hv.disappear()
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hvDisappear()
    }
    
    func backToFeedSwipe(sender : UIGestureRecognizer){
        if self.menuShowed {
            self.showMenu()
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
        self.vMenu.hidden = true
        Functions.delay(0.5){
            self.vMenu.hidden = false
        }
    }
    
    override func popToFeed(sender : UIButton){
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y -= (PERC_BeigeHeight + 1)
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.vMenu.hidden = true
                Functions.delay(0.5){
                    self.vMenu.hidden = false
                }
        })
    }
    
    override func goToAbout(sender: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y += (PERC_BeigeHeight + 1) * 3
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : AboutController = storyboard.instantiateViewControllerWithIdentifier("aboutcontroller") as! AboutController
                self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    override func goToMyCollection(sender : UIButton){
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y += (PERC_BeigeHeight + 1) * 2
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                var vcs = self.navigationController!.viewControllers
                let newVCs = NSMutableArray()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myCollec : MyCollectionController = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
                newVCs.addObject(vcs[0])
                newVCs.addObject(myCollec)
                let trans = CATransition()
                trans.duration = 0.5
                trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                trans.type = kCATransitionMoveIn
                trans.subtype = kCATransitionFromLeft
                self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
                self.navigationController?.setViewControllers(newVCs as NSArray as! [UIViewController], animated: false)
        })
    }
}
