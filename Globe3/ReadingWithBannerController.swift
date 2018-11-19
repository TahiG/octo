//
//  ReadingController.swift
//  Globe3
//
//  Created by Charles Masson on 31/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import ZipArchive
import Parse
import GoogleMobileAds
import MessageUI
import Social
import FolioReaderKit

class ReadingWithBannerController : UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, DataBackDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var wvRead : ReadingWebview!
    var wvPreviousChapter : ReadingWebview!
    var wvNextChapter : ReadingWebview!
    var bookId : String!
    var hideStatusBar = false
    
    var dir : String!
    var nChapters = 0
    var firstChapterId : String!
    var contentDir : String! //Directory of content files. Can be OEBPS or OBPS or whatever
    
    var bookDir : String!//Directory of epub file
    var chapters = NSMutableArray()//Contains all the idref from .opf file
    var dic = Dictionary<String, String>()//idref correponding to the name of the corresponding file
    var nameOfChapter = NSMutableArray()
    var pathOfChapter = NSMutableArray()
    
    var tocSuffix : String!//Table of content file
    var coverSuffix : String!
    
    var vMenu : UIView!
    var menuShowed = false
    var blurView = UIVisualEffectView()
    var navBarShowed = true
    var bookTitle : String! //Set in ebookfromparse method
    var bookAuthor : String! //Set in ebookfromparse method
    var labPage = UILabel()
    var vTitle : UIWindow! //View above navbar which hides it when user taps on the page
    var lTopBookTitle : UILabel!
    var vBelowWv : UIView!
    
    var nChapterToGetNPages = 0//Used when loading the ebook to know how many pages we got
    var nPages = 0//Total pages
    //Pages number
    var currentChapter = 0
    var currentPageInChapter = 0
    var currentPageAtAll = 0 // number displayed at the bottom
    //Number of pages in ...
    var nPagesInCurrentChapter = 0
    var nPagesInNextChapter = 0
    var nPagesInPreviousChapter = 0
    var nPagesPerChapter = NSMutableArray()//Pages per chapter
    var previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter = false
    
    var stillLoading = true
    
    var urlToGoBackTo : NSURL!//If user clicks chapters, or another menu button, keep the page he was reading
    var xOffsetToGoBackTo : CGFloat!
    var weAreGoingBackToAPage = false
    
    var wvIsLoadingNewChapter = false // Used when swipe at he end of a chapter or swipe right at the beginning of a chapter
    var wvIsloadingNextChapter = true // If the user swiped left at the end ; false if user swiped right at the beginning
    
    var userClickedChapters = false//Both true if user clicks chapters
    var userGoesToToc = false//So we know we have to load toc chapter
    
    var userClickedSearchResult = false
    var textSearched : String!
    var occurenceClickedInSearch : Int!
    
    var userClickedCover = false
    
    let wvWidth = screenWidth - 2 * PERC_BlackWidth
    
    var tfJumpToPage : UITextField! //Used to jump to a page
    var wvIsCurrentlyJumpingAndWeNeedToChangeOffset = false
    var wvIsJumpingTo : Int!
    
    var weGoDirectlyToAPage = false
    var wvJustFinishedLoading = false
    var wvHasLoadedTheSavedChapter = false
    var savedChapter = 0
    var savedPageInChapter = 0
    
    var cover : UIImage! //To go to covercontroller
    
    //Options views
    @IBOutlet var vOptions : UIView!
    @IBOutlet var ivBrightnessSmall : UIImageView!
    @IBOutlet var ivBrightnessBig : UIImageView!
    @IBOutlet var slBrightness : UISlider!
    @IBOutlet var bFontMinu : UIButton!
    @IBOutlet var bFontPlus : UIButton!
    @IBOutlet var bGrayBackground : UIButton!
    @IBOutlet var bBlackBackground : UIButton!
    @IBOutlet var bFontHelvetica : UIButton!
    @IBOutlet var bFontGeorgia : UIButton!
    @IBOutlet var bFontBaskerville : UIButton!
    @IBOutlet var bFontPalatino : UIButton!
    //@IBOutlet var scFonts : UIScrollView!
    @IBOutlet var vFonts : UIView!
    @IBOutlet var pvLoading : UIProgressView!
    @IBOutlet var aivLoading : UIActivityIndicatorView!
    @IBOutlet var lLoading : UILabel!
    //Options var
    var isBackgroundGray = true
    var fontSize = 14
    var optionsUp = false
    var wvFont = "Helvetica"
    var bFocusedFont : Int! //0 Helvetica selected, 1 Georgia selected, 2 Baskerville selected, 3 Palatino selected
    var previousFont : UIButton!
    var arrFontButton : NSArray!
    let transImgPath = NSBundle().pathForResource("imgtrans", ofType: "png") //Used for the transparency of the webview which is not transparent anyway.... Consider removing this
    var ban : GADBannerView!
    //Book end views
    @IBOutlet var vEnd : UIView!
    @IBOutlet var lCongrats : UILabel!
    @IBOutlet var lFinished : UILabel!
    @IBOutlet var lBookTitle : UILabel!
    @IBOutlet var lAuthor : UILabel!
    @IBOutlet var lTell : UILabel!
    @IBOutlet var ivShareFacebook : UIImageView!
    @IBOutlet var ivShareTwitter : UIImageView!
    @IBOutlet var ivShareEmail : UIImageView!
    //TOC
    var svToc : UIScrollView!
    var arrChaptersLinks = NSMutableArray()
    override func viewDidLoad() {
        getTitle()
        //Menu
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: .Plain, target: self, action: #selector(showMenu))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cogs"), style: .Plain, target: self, action: #selector(optionsClicked))
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        //Swipe
        let gswipeBackLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeBackLeft))
        self.view.addGestureRecognizer(gswipeBackLeft)
        gswipeBackLeft.direction = .Left
        let gswipeBackRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeBackRight))
        self.view.addGestureRecognizer(gswipeBackRight)
        gswipeBackRight.direction = .Right
        let mainTap = UITapGestureRecognizer(target: self, action: #selector(didSwipeDown))
        self.view.addGestureRecognizer(mainTap)
        
        buildMenu()
        blurView.frame = self.view.bounds
        blurView.backgroundColor = UIColor.clearColor()
        
        ReadingFunctions.saveInCurrentlyReading(bookId)
        //Ads
        ban = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        ban.hidden = true
        ban.frame.origin = CGPoint(x: 0.0, y: screenHeight - ban.frame.height)
        ban.adUnitID = "ca-app-pub-2767445788042395/9122087465"
        ban.rootViewController = self
        ban.loadRequest(GADRequest())
        self.view.addSubview(ban)
        //END Ads
        
        //views
        wvRead.frame.origin.y = PERC_LightTealHeight - 64//Comprend pas
        wvRead.frame.origin.x = PERC_BlackWidth
        wvRead.frame.size.width = wvWidth
        wvRead.frame.size.height = PERC_ReadingPageHeightWithBanner + 64 //Idem
        wvRead.delegate = self
        initNextWebview()
        initPreviousWebview()
        wvNextChapter.hidden = true
        wvPreviousChapter.hidden = true
        self.view.addSubview(wvNextChapter)
        self.view.addSubview(wvPreviousChapter)
        
        let swLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swLeft.direction = UISwipeGestureRecognizerDirection.Left
        let swRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swRight.direction = UISwipeGestureRecognizerDirection.Right
        let swDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
        swDown.direction = UISwipeGestureRecognizerDirection.Down
        let wvTap = UITapGestureRecognizer(target: self, action: #selector(wvTapped))
        wvRead.gestureRecognizers = [swLeft, swRight, swDown, wvTap]
        wvTap.delegate = self
        wvTap.numberOfTapsRequired = 1
        wvRead.userInteractionEnabled = true
        wvRead.stringByEvaluatingJavaScriptFromString("addCSSRule('body', 'background-color: transparent !important; background-image:url(\(transImgPath)); background-repeat: repeat-x; background-size:\(wvRead.frame.size.width)px \(wvRead.frame.size.height)px;')")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.setAttribute('style', 'margin:0!important;padding:0!important;')")
        if !isBackgroundGray { wvRead.loadDarkBackground() }
        else { wvRead.loadGrayBackground() }
        
        vBelowWv = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(wvRead.frame) + PERC_YellowHeight, width: screenWidth - PERC_BlackWidth * 2, height: 1))
        vBelowWv.backgroundColor = UIColor.blackColor()
        self.view.addSubview(vBelowWv)
        vBelowWv.hidden = true
        
        labPage.frame.origin.y = CGRectGetMaxY(vBelowWv.frame) + PERC_YellowHeight
        labPage.font = UIFont(name: "MuseoSans-300", size: 13)
        labPage.text = "0"
        labPage.center.x = self.view.center.x
        self.view.addSubview(labPage)
        
        vTitle = UIWindow(frame: self.navigationController!.navigationBar.frame)
        vTitle.frame.origin.y = 0
        vTitle.frame.size.height = 64
        vTitle.windowLevel = UIWindowLevelStatusBar + 1
        vTitle.frame.size.height += 1
        vTitle.backgroundColor = UIColor.clearColor()
        vTitle.makeKeyAndVisible()
        let fontTitle = UIFont(name: "Interstate-Regular", size: 17)
        lTopBookTitle = UILabel()
        lTopBookTitle.frame.origin.y = PERC_GreenHeight
        lTopBookTitle.font = fontTitle
        lTopBookTitle.alpha = 0
        vTitle.addSubview(lTopBookTitle)
        vTitle.hidden = true
        
        //Loading views
        lLoading.center.x = view.center.x
        lLoading.center.y = view.center.y - aivLoading.frame.size.height
        aivLoading.center = self.view.center
        pvLoading.frame.size.width = AlmostFullWidth
        pvLoading.center = self.view.center
        pvLoading.frame.origin.y += aivLoading.frame.size.height
        
        //Options views
        let vSepFromRead = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1 / (UIScreen.mainScreen().scale)))
        vSepFromRead.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepFromRead)
        ivBrightnessSmall.frame = CGRect(x: PERC_BlackWidth, y: PERC_DarkRedWidth, width: PERC_BlueHeight, height: PERC_BlueHeight)
        ivBrightnessBig.frame.size = CGSize(width: PERC_GreenHeight, height: PERC_GreenHeight)
        ivBrightnessBig.frame.origin.x = screenWidth - PERC_BlackWidth - ivBrightnessBig.frame.size.width
        ivBrightnessBig.center.y = ivBrightnessSmall.center.y
        slBrightness.frame = ivBrightnessSmall.frame
        slBrightness.frame.origin.x = CGRectGetMaxX(ivBrightnessSmall.frame) + PERC_DarkRedWidth
        slBrightness.frame.size.width = CGRectGetMinX(ivBrightnessBig.frame) - CGRectGetMaxX(ivBrightnessSmall.frame) - 2 * PERC_DarkRedWidth
        slBrightness.setValue(Float(UIScreen.mainScreen().brightness), animated: false)
        
        let vSepSL = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(slBrightness.frame) + PERC_YellowHeight, width: screenWidth, height: 1))
        vSepSL.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepSL)
        
        bFontMinu.frame = CGRect(x: 0, y: CGRectGetMaxY(vSepSL.frame), width: halfScreenWidth - 1, height: PERC_DarkTealHeight)
        
        let vSepB = UIView(frame: CGRect(x: halfScreenWidth - 1, y: CGRectGetMaxY(vSepSL.frame), width: 1, height: PERC_DarkTealHeight))
        vSepB.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepB)
        
        bFontPlus.frame = CGRect(x: halfScreenWidth + 1, y: CGRectGetMaxY(vSepSL.frame), width: halfScreenWidth - 1, height: PERC_DarkTealHeight)
        
        let vSepFont = UIView(frame: vSepSL.frame)
        vSepFont.frame.origin.y = CGRectGetMaxY(bFontMinu.frame)
        vSepFont.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepFont)
        //Fonts
        vFonts.frame = CGRect(x: 0, y: CGRectGetMaxY(vSepFont.frame), width: screenWidth, height: PERC_DarkTealHeight + PERC_BlueHeight)
        let heightFont = PERC_ButtonFont - 2, yOriginFont = PERC_BlueHeight / 2, xSpace = PERC_BlackWidth
        bFontHelvetica.frame = CGRect(x: PERC_BlackWidth, y: yOriginFont, width: HalfScreenButtonWidth, height: PERC_ButtonFont - 2)
        bFontGeorgia.frame = CGRect(x: CGRectGetMaxX(bFontHelvetica.frame) + xSpace, y: yOriginFont, width: HalfScreenButtonWidth, height: heightFont)
        bFontBaskerville.frame = CGRect(x: CGRectGetMaxX(bFontGeorgia.frame) + xSpace, y: yOriginFont, width: HalfScreenButtonWidth, height: heightFont)
        bFontPalatino.frame = CGRect(x: CGRectGetMaxX(bFontBaskerville.frame) + xSpace, y: yOriginFont, width: HalfScreenButtonWidth, height: heightFont)
        previousFont = bFontHelvetica
        
        let vSepSc = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(vFonts.frame), width: screenWidth, height: 1))
        vSepSc.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepSc)
        
        bGrayBackground.frame = CGRect(x: 0, y: CGRectGetMaxY(vSepSc.frame), width: halfScreenWidth, height: PERC_DarkTealHeight + PERC_TealHeight)
        bBlackBackground.frame = CGRect(x: halfScreenWidth, y: CGRectGetMaxY(vFonts.frame), width: halfScreenWidth, height: PERC_DarkTealHeight + PERC_TealHeight)
        let vSepBB = UIView(frame: CGRect(x: halfScreenWidth - 1, y: CGRectGetMaxY(vSepSc.frame), width: 1, height: bGrayBackground.frame.size.height))
        vSepBB.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepBB)
        
        vOptions.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: CGRectGetMaxY(bBlackBackground.frame))
        //END options views
        weGoDirectlyToAPage = getPreferredWVAttributes() //True if a page is saved in userdefaults
        setCarroussel()
        //Start loading
        wvRead.hidden = true
        pvLoading.hidden = true
        aivLoading.hidden = false
        aivLoading.startAnimating()
        if isBookInDocs() { //Loading ebook from doc directory
            _ = NSFileManager.defaultManager()
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir = dirPaths[0] 
            bookDir = docsDir.stringByAppendingPathComponent(self.bookId)
            afterStoringEBookInDocs()
        } else { //Loading ebook from parse and saving in doc directory
            ebookFromParse()
        }
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#EFEFEF', 'important')")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#000000'")
        wvNextChapter.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#EFEFEF', 'important')")
        wvNextChapter.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#000000'")
        wvPreviousChapter.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#EFEFEF', 'important')")
        wvPreviousChapter.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#000000'")
        vBelowWv.backgroundColor = UIColor.blackColor()
        labPage.textColor = UIColor.blackColor()
        lTopBookTitle.textColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor(red: 239/255, green: 237/255, blue: 237/255, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        Functions.delay(0.5) { //So we don't see it when coming from another controller
            self.wvNextChapter.hidden = false
            self.wvPreviousChapter.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.wvNextChapter.hidden = true //So we don't see it when going to another controller
        self.wvPreviousChapter.hidden = true
        vTitle.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) { vTitle.hidden = true }
    
    //Charger chapitres quand fini puis swipe gauche pour amener a chapitre 0
    func webViewDidFinishLoad(webView: UIWebView) {
        //We do this before so if we load a new chapter, it will have the real number of pages BUT we only do this if the webview finished loading
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.textAlign = 'left'")
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.textJustify = 'none'")
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.fontFamily = '\(wvFont)'")
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSize)pt'")
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.lineHeight = '\(fontSize * 3 / 2)pt'")
        webView.stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontFamily = '\(wvFont)';ps[i].style.fontSize = '\(fontSize)pt';ps[i].style.textAlign = 'left';ps[i].style.textJustify = 'none'}")
        if !isBackgroundGray { (webView as! ReadingWebview).loadDarkBackground() }
        else { (webView as! ReadingWebview).loadGrayBackground() }
        
        if webView == wvRead {
            Functions.delay(0.2) { self.nPagesInCurrentChapter = webView.pageCount }
            //Loading data for optimal reading experience
            updateChapterTitle()
            if stillLoading {//Getting pages number of this chapter / updating total pages
                loadingText("Loading chapters")
                pvLoading.hidden = false
                pvLoading.setProgress(Float(nChapterToGetNPages) / Float(nChapters), animated: false)
                let n = webView.pageCount
                self.nPages += n
                print("\(n) pages in \(self.nChapterToGetNPages)")
                //Updating pagesperchapter
                self.nPagesPerChapter.addObject(n)
                if (nChapters - 1) == self.nChapterToGetNPages {
                    //Last chapter, we load the first page again
                    pvLoading.hidden = true
                    aivLoading.hidden = true
                    lLoading.hidden = true
                    Functions.delay(0.3) { self.wvRead.hidden = false }
                    print("c'est le dernier")
                    self.currentChapter = 0
                    self.currentPageAtAll = 0
                    self.currentPageInChapter = 0
                    self.stillLoading = false //End of the loading
                    if weGoDirectlyToAPage { //If there's a saved chapter
                        currentChapter = savedChapter
                        currentPageInChapter = savedPageInChapter //We load the chapter
                        wvRead.loadRequest(getURLRequestFromChapter(savedChapter))
                        wvHasLoadedTheSavedChapter = true
                    }
                    print(self.nPagesPerChapter)
                    webView.loadRequest(getURLRequestFromChapter(currentChapter))
                } else {//Not the last one, we load the next one
                    self.nChapterToGetNPages += 1
                    webView.loadRequest(getURLRequestFromChapter(nChapterToGetNPages))
                }
            } else if userClickedChapters {
                if !userGoesToToc {
                    if weAreGoingBackToAPage {
                        wvRead.scrollView.contentOffset.x = self.xOffsetToGoBackTo
                        weAreGoingBackToAPage = false
                    } else {
                        //User clicked on a chapter
                        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: .Plain, target: self, action: #selector(showMenu))
                        //We wanna know which chapter was clicked
                        currentChapter = getChapter()
                        updateCurrentPageWhichIsAtBeginningOfCurrentChapter()
                        //Load previous and next chapters
                        wvNextChapter.loadRequest(getURLRequestFromChapter(currentChapter + 1))
                        wvPreviousChapter.loadRequest(getURLRequestFromChapter(currentChapter - 1))
                        previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter = true
                        updateChapterTitle()
                    }
                    userClickedChapters = false
                } else { userGoesToToc = false }
            } else if wvIsCurrentlyJumpingAndWeNeedToChangeOffset {
                //We need to jump to current page
                UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * self.wvWidth
                    }, completion: nil)
            }
            
            if wvHasLoadedTheSavedChapter { //The saved chapter has been loaded
                print("\(savedChapter)      \(savedPageInChapter)")
                Functions.delay(0.7) { //We scroll to the page
                    let pageWidth = self.wvRead.scrollView.contentSize.width / CGFloat(self.nPagesInCurrentChapter) //Before the page was cut : now it's not
                    self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * pageWidth
                    self.wvHasLoadedTheSavedChapter = false
                    self.weGoDirectlyToAPage = false
                }
                //Load the next chapter in background so it will be ready when user reaches the end of current one
                self.wvNextChapter.loadRequest(getURLRequestFromChapter(currentChapter + 1))
                //Load previous chapter for the same reason
                if self.currentChapter != 0 {
                    previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter = true
                    self.wvPreviousChapter.loadRequest(getURLRequestFromChapter(currentChapter - 1))
                }
                wvHasLoadedTheSavedChapter = false
            }
            
            if userClickedSearchResult {
                userClickedSearchResult = false
                updateCurrentPageWhichIsAtBeginningOfCurrentChapter()
                Functions.delay(0.3) {
                    print("\(self.occurenceClickedInSearch)")
                    self.currentPageInChapter = self.wvRead.scrollToSearchedText(self.textSearched, occurence: self.occurenceClickedInSearch)
                }
            }
        } else if webView == wvNextChapter {
            print("requete chargee sur next wv")
            let c = webView.pageCount
            Functions.delay(0.25) { //So we have time to load the font
                self.nPagesInNextChapter = c
                print("\(c) pages in next chapter")
            }
        } else if webView == wvPreviousChapter {
            if previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter {
                Functions.delay(0.3) {
                    self.nPagesInPreviousChapter = webView.pageCount
                    let pageWidth = self.wvPreviousChapter.scrollView.contentSize.width / CGFloat(self.nPagesInPreviousChapter)
                    self.wvPreviousChapter.scrollView.contentOffset.x = CGFloat(self.nPagesInPreviousChapter - 1) * pageWidth
                }
                previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter = false
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool { return true }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        vTitle.hidden = true
        return super.canPerformAction(action, withSender: sender)
    }
    
    func getTitle() {
        let q = PFQuery(className: "Book")
        q.whereKey("objectId", equalTo: bookId)
        q.getFirstObjectInBackgroundWithBlock({ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                if let s = object?.objectForKey("name") as? String {
                    self.navigationItem.title = s
                    self.bookTitle = s
                }
                self.bookAuthor = object?.objectForKey("author") as? String
            }
        })
    }
    
    @IBAction func swipeBackLeft(sender : UISwipeGestureRecognizer) {didSwipeLeft(UISwipeGestureRecognizer())}
    @IBAction func swipeBackRight(sender : UISwipeGestureRecognizer) {didSwipeRight(UISwipeGestureRecognizer())}
    
    @IBAction func didSwipeRight(sender : UISwipeGestureRecognizer) {
        //if navbar is shown, we remove everything as the user is reading
        if navBarShowed { wvTapped(UITapGestureRecognizer()) }
        if currentPageInChapter > 0 {
            currentPageInChapter -= 1
            let pageWidth = self.wvRead.scrollView.contentSize.width / CGFloat(self.nPagesInCurrentChapter) //Before the page was cut : now it's not
            UIView.animateWithDuration(Double(0.3), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * pageWidth
                return
                }, completion: nil)
            currentPageAtAll -= 1
            labPage.text = "\(currentPageAtAll)"
            labPage.sizeToFit()
            labPage.center.x = view.center.x
        } else {
            //Previous chapter
            if currentChapter != 0 {
                currentChapter -= 1
                currentPageAtAll -= 1
                currentPageInChapter = nPagesInPreviousChapter - 1
                nPagesPerChapter[currentChapter] = nPagesInPreviousChapter
                nPagesInCurrentChapter = nPagesInPreviousChapter
                UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.frame.origin.x = screenWidth
                    self.wvPreviousChapter.frame.origin.x = PERC_BlackWidth
                    }, completion: { _ in
                        self.wvRead.loadRequest(self.getURLRequestFromChapter(self.currentChapter))
                        Functions.delay(0.3) { //We replace the previous chapter webview with the real one
                            let pageWidth = self.wvRead.scrollView.contentSize.width / CGFloat(self.nPagesInCurrentChapter)
                            print("\(pageWidth)    \(self.nPagesInCurrentChapter)     \(self.wvRead.scrollView.contentSize.width)")
                            print(pageWidth * CGFloat(self.nPagesInCurrentChapter - 1))
                            self.wvRead.scrollView.contentOffset.x = pageWidth * CGFloat(self.nPagesInCurrentChapter - 1)//CGFloat(self.currentPageInChapter) * self.wvWidth
                            self.loadPrevNextAndReplaceMainWebview(false)
                        }
                })
                labPage.text = "\(currentPageAtAll)"
                labPage.sizeToFit()
                labPage.center.x = view.center.x
            }
            ReadingFunctions.saveCurrentChapter(bookId, savechapter: currentChapter)
        }
        ReadingFunctions.saveCurrentPage(bookId, savepage: currentPageInChapter)
    }
    
    @IBAction func didSwipeLeft(sender : UISwipeGestureRecognizer){
        //if navbar is shown, we remove everything as the user is reading
        if navBarShowed {
            wvTapped(UITapGestureRecognizer())
        }
        if (currentPageInChapter + 1) != nPagesInCurrentChapter/*nPagesPerChapter[currentChapter] as! Int*/ {//Smae chapter, next page
            currentPageInChapter += 1
            let pageWidth = self.wvRead.scrollView.contentSize.width / CGFloat(self.nPagesInCurrentChapter) //Before the page was cut : now it's not
            UIView.animateWithDuration(Double(0.3), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * pageWidth  // * self.wvWidth  OLD VERSION
                print(self.wvRead.scrollView.contentOffset.x)
                print(self.wvRead.scrollView.contentSize.width)
                print(CGFloat(self.nPagesInCurrentChapter))
                return
                }, completion: nil)
            currentPageAtAll += 1
            labPage.text = "\(self.currentPageAtAll)"
            labPage.sizeToFit()
            labPage.center.x = view.center.x
        } else {
            //Next chapter
            if currentChapter < nChapters - 1 {
                currentChapter += 1
                currentPageAtAll += 1
                currentPageInChapter = 0
                nPagesPerChapter[currentChapter] = nPagesInNextChapter
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.frame.origin.x = -screenWidth
                    self.wvNextChapter.frame.origin.x = PERC_BlackWidth
                    }, completion: { _ in
                        self.wvRead.loadRequest(self.getURLRequestFromChapter(self.currentChapter))
                        Functions.delay(0.25) { //We replace the next chapter webview with the real one
                            self.loadPrevNextAndReplaceMainWebview(true)
                        }
                })
                self.labPage.text = "\(self.currentPageAtAll)"
                self.labPage.sizeToFit()
                self.labPage.center.x = self.view.center.x
            } else {
                endOfTheBook()
            }
            ReadingFunctions.saveCurrentChapter(bookId, savechapter: currentChapter)
        }
        ReadingFunctions.saveCurrentPage(bookId, savepage: currentPageInChapter)
    }
    
    func loadPrevNextAndReplaceMainWebview(next : Bool) {
        if next {
            self.wvRead.frame.origin.x = PERC_BlackWidth
            self.wvNextChapter.frame.origin.x = screenWidth + PERC_BlackWidth
        } else {
            self.wvRead.frame.origin.x = PERC_BlackWidth
            self.wvPreviousChapter.frame.origin.x = -screenWidth
        }
        //Load the next chapter in background so it will be ready when user reaches the end of current one
        self.wvNextChapter.loadRequest(getURLRequestFromChapter(currentChapter + 1))
        //Load previous chapter for the same reason
        if self.currentChapter != 0 {
            previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter = true
            self.wvPreviousChapter.loadRequest(getURLRequestFromChapter(currentChapter - 1))
        }
    }
    
    @IBAction func didSwipeDown(sender : UISwipeGestureRecognizer){
        optionsGoDown()
    }
    
    func initNextWebview() {
        wvNextChapter = ReadingWebview()
        wvNextChapter.frame = CGRect(x: PERC_BlackWidth + screenWidth, y: PERC_LightTealHeight, width: wvWidth, height: PERC_ReadingPageHeightWithBanner)
        wvNextChapter.delegate = self
        wvRead.stringByEvaluatingJavaScriptFromString("addCSSRule('body', 'background-color: transparent !important; background-image:url(\(transImgPath)); background-repeat: repeat-x; background-size:\(wvRead.frame.size.width)px \(wvRead.frame.size.height)px;')")
    }
    
    func initPreviousWebview() {
        wvPreviousChapter = ReadingWebview()
        wvPreviousChapter.frame = CGRect(x: PERC_BlackWidth - screenWidth, y: PERC_LightTealHeight, width: wvWidth, height: PERC_ReadingPageHeightWithBanner)
        wvPreviousChapter.delegate = self
        wvPreviousChapter.stringByEvaluatingJavaScriptFromString("addCSSRule('body', 'background-color: transparent !important; background-image:url(\(transImgPath)); background-repeat: repeat-x; background-size:\(wvRead.frame.size.width)px \(wvRead.frame.size.height)px;')")
    }
    
    func getChapter() -> Int {
        let url = self.wvRead.request?.URL?.lastPathComponent
        for i in 0  ..< chapters.count {
            let d = dic[chapters[i] as! String]!
            if url! == d { return i }
        }
        return 0
    }
    
    func updateChapterTitle() {
        lTopBookTitle.text = (nameOfChapter[currentChapter] as! String)
        lTopBookTitle.sizeToFit()
        lTopBookTitle.lineBreakMode = .ByTruncatingTail
        if lTopBookTitle.frame.size.width > AlmostFullWidth {
            lTopBookTitle.frame.size.width = AlmostFullWidth
        }        
        lTopBookTitle.center.x = self.view.center.x
    }
    
    func getURLRequestFromChapter(chap : Int) -> NSURLRequest {
        let path = pathOfChapter[chap] as! NSString
        if path.contains("#") {
            let r = path.rangeOfString("#")
            let before = path.substringToIndex(r.location)
            let urlChapter = NSURL(fileURLWithPath: self.bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(before))
            return NSURLRequest(URL: urlChapter)
        } else {
            let urlChapter = NSURL(fileURLWithPath: self.bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(pathOfChapter[chap] as! String))
            return NSURLRequest(URL: urlChapter)
        }
        
    }
    
    func updateCurrentPageWhichIsAtBeginningOfCurrentChapter(){
        var temp = 0
        for i in 0  ..< self.currentChapter { temp += self.nPagesPerChapter[i] as! Int }
        currentPageAtAll = temp
        currentPageInChapter = 0
        labPage.text = "\(currentPageAtAll)"
        labPage.sizeToFit()
        labPage.center.x = view.center.x
    }
    
    @IBAction func wvTapped(sender : UITapGestureRecognizer){
        optionsGoDown()
        //Smooth transitions to hide and show some stuffs which are not necesary for the reader
        removeMenuWithTap()
        //If the user clicked chapters, we don't care about imersion s this functionality won't work
        if !userClickedChapters {
            if navBarShowed {
                vTitle.hidden = false
                UIView.animateWithDuration(0.3, animations: {
                    self.vBelowWv.backgroundColor = UIColor.clearColor()
                    self.labPage.alpha = 0
                    self.vTitle.backgroundColor = self.view.backgroundColor
                    self.lTopBookTitle.alpha = 0.6
                    self.ban.hidden = false
                    return
                    }, completion: { _ in
                        self.labPage.hidden = true
                        return
                })
                navBarShowed = false
            } else {
                if isBackgroundGray {
                    UIView.animateWithDuration(0.3, animations: {
                        self.vBelowWv.backgroundColor = UIColor.blackColor()
                        self.labPage.alpha = 0.6
                        self.vTitle.backgroundColor = UIColor.clearColor()
                        self.lTopBookTitle.alpha = 0
                        self.ban.hidden = true
                        return
                        }, completion: { _ in
                            self.vTitle.hidden = true
                            self.labPage.hidden = false
                            return
                    })
                } else {
                    UIView.animateWithDuration(0.3, animations: {
                        self.vBelowWv.backgroundColor = UIColor.whiteColor()
                        self.labPage.alpha = 0.6
                        self.vTitle.backgroundColor = UIColor.clearColor()
                        self.lTopBookTitle.alpha = 0
                        self.ban.hidden = true
                        return
                        }, completion: { _ in
                            self.vTitle.hidden = true
                            self.labPage.hidden = false
                            return
                    })
                }
                navBarShowed = true
            }
        }
    }
    
    func isBookInDocs() -> Bool {
        let ud = NSUserDefaults.standardUserDefaults()
        return (ud.objectForKey("BOOK_IN_DOCS" + self.bookId) != nil) ? ud.boolForKey("BOOK_IN_DOCS\(self.bookId)") : false
    }
    //Getting the ebook from parse and (below,) parsing ebook content
    func ebookFromParse() {
        //Loading
        loadingText("Loading eBook")
        //Getting ebook data
        let queryBook = PFQuery(className: "Book")
        queryBook.whereKey("objectId", equalTo: self.bookId)
        queryBook.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                self.bookTitle = object?.objectForKey("name") as! String
                self.bookAuthor = object?.objectForKey("author") as! String
                self.navigationItem.title = self.bookTitle
                self.lTopBookTitle.text = self.bookTitle
                self.lTopBookTitle.sizeToFit()
                self.lTopBookTitle.center.x = self.view.center.x
                self.lTopBookTitle.lineBreakMode = .ByTruncatingTail
                self.lTopBookTitle.frame.size.width = AlmostFullWidth
                let dat = object?.objectForKey("epub") as! PFFile
                dat.getDataInBackgroundWithBlock({
                    (bookData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        print("returning epub file")
                        //Data retrieved, we store epub file
                        if self.storeEPubInDoc(bookData!) {
                            //Unzip epub
                            //self.loadingText("Saving eBook")
                            let zip = ZipArchive()
                            if zip.UnzipOpenFile(self.bookDir.stringByAppendingPathComponent("book.epub")) {
                                let isUnzipped = zip.UnzipFileTo(self.bookDir, overWrite: true)
                                if !isUnzipped {
                                    print("unzip failed")
                                    zip.UnzipCloseFile()
                                } else {
                                    //All good we fill reference dictionary with the content file
                                    self.afterStoringEBookInDocs()
                                }
                            }
                        }
                    } else { print(error) }
                })
            } else { print(error) }
        }
    }
    
    func afterStoringEBookInDocs() {
        let contentFilePath = self.getContentFilePath()
        var contentFullPath : String!
        if self.contentDir != nil {//This was just to get content folder if it exists
            contentFullPath = self.contentDir + "/" + contentFilePath
        } else {
            self.contentDir = ""
            contentFullPath = contentFilePath
        }

        print ("Content path = \(contentFullPath)")

        self.fillRefDictionnaryWithContentFilePath(contentFullPath)
    }
    
    func storeEPubInDoc(ebookData : NSData) -> Bool {
        //Getting documents dir path
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0]
        //Creating book dir
        bookDir = docsDir.stringByAppendingPathComponent(self.bookId)
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(bookDir, withIntermediateDirectories: true, attributes: nil)
            //Creating file book.epub in previously created dir
            if !filemgr.createFileAtPath(bookDir.stringByAppendingPathComponent("book.epub"), contents: ebookData, attributes: nil){
                print("Failed to create file")
                return false
            } else {
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setBool(true, forKey: "BOOK_IN_DOCS\(self.bookId)")
                ud.synchronize()
                return true
            }
        } catch {
            print("Error creating dir")
            return false
        }
    }
    
    func getContentFilePath() -> String {
        //Get container.xml
        var strContainer : NSString = ""
        do {
            try strContainer = NSString(contentsOfFile: bookDir.stringByAppendingPathComponent("META-INF").stringByAppendingPathComponent("container.xml"), encoding: NSUTF8StringEncoding)
        } catch let error as NSError { print(error.localizedDescription) }
        //Parse container.xml
        var tempScanned: NSString?
        let sc = NSScanner(string: strContainer as String)
        if sc.scanUpToString("<rootfile ", intoString:nil) {
            sc.scanString("<rootfile ", intoString:nil)
            if sc.scanUpToString(">", intoString:&tempScanned) {
                //Parse rootfile attributes
                let sn = tempScanned as! String
                let newSc = NSScanner(string: sn)
                if newSc.scanUpToString("path=\"", intoString: nil) {
                    newSc.scanString("path=\"", intoString: nil)
                    if newSc.scanUpToString("\"", intoString: &tempScanned) {
                        let fullPath = tempScanned as! String
                        let scFullPath = NSScanner(string: fullPath)
                        var folder : NSString?
                        if fullPath.contains("/") {
                            if scFullPath.scanUpToString("/", intoString: &folder) {
                                self.contentDir = folder as! String
                                let fileName = tempScanned!.stringByReplacingOccurrencesOfString(self.contentDir + "/", withString: "")
                                return fileName as String
                            } else { return fullPath }
                        } else { return fullPath }
                    }
                }
            }
        }
        return "OEBPS/content.opf" //Return default value
    }
    
    func fillRefDictionnaryWithContentFilePath(path : String!){
        //Content File
        var strContent : NSString = ""
        do { try strContent = NSString(contentsOfFile: bookDir.stringByAppendingPathComponent(path), encoding: NSUTF8StringEncoding) }
        catch let error as NSError { print(error.localizedDescription) }
            
        //We get the content of manifest tag
        let manifestScan = NSScanner(string : strContent as String)
        manifestScan.scanUpToString("<manifest", intoString: nil)
        manifestScan.scanString("<manifest", intoString: nil)
        var manifestContent : NSString?
        manifestScan.scanUpToString("</manifest>", intoString: &manifestContent)
        //We get the ids and the hrefs of the different files in the manifest node
        var petitScanned: NSString?
        let petitScanner = NSScanner(string: manifestContent! as String)
        var ncxFound = false
        var anyMore = true
        while anyMore {
            var href : String!
            var id : String!
            if petitScanner.scanUpToString("<item ", intoString:nil) {
                //We get the content of each "<item />"
                petitScanner.scanString("<item ", intoString:nil)
                petitScanner.scanUpToString(">", intoString:&petitScanned)
                //Get id attr
                let scanId = NSScanner(string: petitScanned as! String)
                scanId.scanUpToString("id=\"", intoString: nil)
                scanId.scanString("id=\"", intoString: nil)
                var idTemp : NSString?
                scanId.scanUpToString("\"", intoString: &idTemp)
                id = idTemp as! String
                //Get href attr
                let scanRef = NSScanner(string: petitScanned as! String)
                scanRef.scanUpToString("href=\"", intoString: nil)
                scanRef.scanString("href=\"", intoString: nil)
                var hrefTemp : NSString?
                scanRef.scanUpToString("\"", intoString: &hrefTemp)
                href = hrefTemp as! String
            } else { anyMore = false }
            if anyMore {
                if id.contains("cover") || id == "cover" { coverSuffix = href }
                else if id.contains("ncx") || id == "ncx" { ncxFound = true ; id = "ncx" }
                dic[id] = href
            }
        }
        if ncxFound { parseNcxFile(bookDir.stringByAppendingPathComponent(contentDir).stringByAppendingPathComponent(dic["ncx"]!)) }
    }
    
    func parseNcxFile(ncxPath : String) {
        var strNcx : NSString = ""
        do { try strNcx = NSString(contentsOfFile: ncxPath, encoding: NSUTF8StringEncoding) }
        catch let error as NSError { print(error.localizedDescription) }
        
        //We get the content of navMap tag
        let navMapScan = NSScanner(string : strNcx as String)
        navMapScan.scanUpToString("<navMap", intoString: nil)
        navMapScan.scanString("<navMap", intoString: nil)
        var navMapContent : NSString?
        navMapScan.scanUpToString("</navMap>", intoString: &navMapContent)
        //We get the chapters names and src in each navPoint tag
        var navPointScanned: NSString?
        let navPointScanner = NSScanner(string: navMapContent! as String)
        var anyMore = true
        var prevSrc = "", prevTitle = ""
        while anyMore {
            var src : String!
            var chapterTitle : String!
            if navPointScanner.scanUpToString("<navPoint", intoString:nil) {
                //We get the content of each "<navPoint>"
                navPointScanner.scanString("<navPoint", intoString:nil)
                navPointScanner.scanUpToString("</navPoint>", intoString:&navPointScanned)
                while navPointScanned!.contains("<navPoint") {//We only want the children
                    navPointScanned = navPointScanned?.substringFromIndex(navPointScanned!.rangeOfString("<navPoint").location + 5)
                }
                //Get chapter title
                let textScanner = NSScanner(string: navPointScanned as! String)
                textScanner.scanUpToString("<text", intoString: nil)
                textScanner.scanString("<text>", intoString: nil)
                var chapterTitleTemp : NSString?
                textScanner.scanUpToString("</text>", intoString: &chapterTitleTemp)
                chapterTitle = chapterTitleTemp as! String
                //Get <content /> node
                let contentScanner = NSScanner(string: navPointScanned as! String)
                contentScanner.scanUpToString("<content", intoString: nil)
                contentScanner.scanString("<content", intoString: nil)
                var contentScanned : NSString?
                contentScanner.scanUpToString("/>", intoString: &contentScanned)
                //Get src attr in content node
                let srcScanner = NSScanner(string: contentScanned as! String)
                srcScanner.scanUpToString("src=\"", intoString: nil)
                srcScanner.scanString("src=\"", intoString: nil)
                var srcScanned : NSString?
                srcScanner.scanUpToString("\"", intoString: &srcScanned)
                src = srcScanned as! String
                if src != prevSrc || chapterTitle != prevTitle {
                    nameOfChapter.addObject(chapterTitle)
                    pathOfChapter.addObject(src)
                    prevSrc = src
                    prevTitle = chapterTitle
                } else { anyMore = false }
            } else { anyMore = false }
        }
        print(nameOfChapter)
        print(pathOfChapter)
        self.nChapters = nameOfChapter.count
        wvRead.loadRequest(getURLRequestFromChapter(0))
        Functions.delay(0.1) { self.generateTOC() }
    }
    
    func generateTOC() {
        svToc = UIScrollView(frame : CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight - 64))
        let fontColor = UIColor(red: 88 / 255, green: 91 / 255, blue: 1, alpha: 1)
        var nextOriginY : CGFloat = 20
        for i in 0  ..< pathOfChapter.count {
            let bChapter = UIButton()
            bChapter.setTitle("\(i + 1). \(nameOfChapter[i] as! String)", forState: .Normal)
            bChapter.titleLabel?.numberOfLines = 0
            bChapter.frame.origin = CGPoint(x: PERC_BlackWidth, y: nextOriginY)
            bChapter.addTarget(self, action: #selector(ReadingWithBannerController.bChapterClicked(_:)), forControlEvents: .TouchUpInside)
            bChapter.setTitleColor(fontColor, forState: .Normal)
            bChapter.tag = i
            bChapter.sizeToFit()
            bChapter.frame.size.width = AlmostFullWidth
            bChapter.titleLabel?.textAlignment = .Left
            bChapter.contentHorizontalAlignment = .Left
            bChapter.contentVerticalAlignment = .Top
            bChapter.layoutIfNeeded()
            svToc.addSubview(bChapter)
            nextOriginY += bChapter.titleLabel!.frame.size.height + 18
            let vSep = UIView(frame: CGRect(x: PERC_BlackWidth, y: nextOriginY, width: AlmostFullWidth, height: 1))
            vSep.backgroundColor = fontColor
            svToc.addSubview(vSep)
            nextOriginY += 5
        }
        svToc.contentSize = CGSize(width: screenWidth, height: nextOriginY + 20)
        svToc.hidden = true
        svToc.alpha = 0
        svToc.backgroundColor = UIColor(red: 239/255, green: 237/255, blue: 237/255, alpha: 1)
        self.view.addSubview(svToc)
    }
    
    @IBAction func bChapterClicked(sender : UIButton) {
        previousWVIsLoadingAndHasToScrollToTheEndOfTheChapter = true
        let tag = sender.tag
        wvRead.loadRequest(getURLRequestFromChapter(tag))
        if tag > 0 { wvPreviousChapter.loadRequest(getURLRequestFromChapter(tag - 1)) }
        if tag < nChapters - 1 { wvNextChapter.loadRequest(getURLRequestFromChapter(tag + 1)) }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: .Plain, target: self, action: #selector(showMenu))
        UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.svToc.alpha = 0
            }, completion: { _ in
                self.svToc.hidden = true
            })
        currentChapter = tag
        currentPageInChapter = 0
        updateCurrentPageWhichIsAtBeginningOfCurrentChapter()
    }
    
    func stringWithoutHtmlTags(html : NSString) -> String {
        return html.stringByReplacingOccurrencesOfString("<[^>]+>",
            withString: "",
            options: NSStringCompareOptions.RegularExpressionSearch,
            range: NSMakeRange(0, html.length))
    }
    //END getting ebook from parse
    func goToPage(page : Int){
        //Called when user entered a page number after clicking jump to page
        var totalPages = 0
        for i in 0  ..< nPagesPerChapter.count {
            let nPagesInI = totalPages + (nPagesPerChapter[i] as! Int)
            if page <= nPagesInI {
                //We wanna load this chapter
                //Updating navigation data
                self.currentChapter = i
                self.currentPageAtAll = page
                self.currentPageInChapter = page - totalPages
                //Updating views
                self.labPage.text = "\(page)"
                self.labPage.sizeToFit()
                self.labPage.center.x = self.view.center.x
                //Preparing offset changes
                self.wvIsCurrentlyJumpingAndWeNeedToChangeOffset = true
                //Loading chapter's file
                wvRead.loadRequest(getURLRequestFromChapter(i))
                return
            } else {
                totalPages = nPagesInI
            }
        }
    }
    
    //Selected font button
    func focusedFontButton(font : String) -> Int {
        if font == "Helvetica" { return 0 }
        else if font == "Georgia" { return 1 }
        else if font == "Baskerville" { return 2 }
        else { return 3 }
    }
    
    func setCarroussel() {
        bFocusedFont = focusedFontButton(wvFont)
        arrFontButton = [bFontHelvetica, bFontGeorgia, bFontBaskerville, bFontPalatino]
        (arrFontButton[bFocusedFont] as! UIButton).center.x = self.view.center.x
        (arrFontButton[bFocusedFont] as! UIButton).setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        //Button before
        (arrFontButton[prevCarrNum(bFocusedFont)] as! UIButton).frame.origin.x = CGRectGetMinX((arrFontButton[bFocusedFont] as! UIButton).frame) - PERC_BlackWidth - (arrFontButton[prevCarrNum(bFocusedFont)] as! UIButton).frame.size.width
        //Button after
        (arrFontButton[nextCarrNum(bFocusedFont)] as! UIButton).frame.origin.x = CGRectGetMaxX((arrFontButton[bFocusedFont] as! UIButton).frame) + PERC_BlackWidth
        //Swipe
        vFonts.userInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(fontsSwipedLeft))
        swipeLeft.direction = .Left
        vFonts.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(fontsSwipedRight))
        swipeRight.direction = .Right
        vFonts.addGestureRecognizer(swipeRight)
        for b in arrFontButton {
            let b = b as! UIButton
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(fontsSwipedLeft))
            swipeLeft.direction = .Left
            b.addGestureRecognizer(swipeLeft)
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(fontsSwipedRight))
            swipeRight.direction = .Right
            b.addGestureRecognizer(swipeRight)
        }
        carrButtonFromNum(nextCarrNum(nextCarrNum(bFocusedFont))).hidden = true //The button that is not visible is hidden so it won't do a mess when swipe
    }
    
    func nextCarrNum(n : Int) -> Int { return (n == 3) ? 0 : (n + 1) }
    
    func prevCarrNum(n : Int) -> Int { return (n == 0) ? 3 : (n - 1) }
    
    func carrButtonFromNum(n : Int) -> UIButton { return arrFontButton[n] as! UIButton }
    
    func numFromCarrButton(b : UIButton) -> Int { return arrFontButton.indexOfObject(b) }
    
    //Options interactions
    @IBAction func brightnessChanged(sender : UISlider){
        UIScreen.mainScreen().brightness = CGFloat(sender.value)
    }
    
    @IBAction func fontsSwipedLeft(sender : UISwipeGestureRecognizer) {
        //Invisible becomes visible
        carrButtonFromNum(nextCarrNum(nextCarrNum(bFocusedFont))).frame.origin.x = screenWidth * 1.5
        carrButtonFromNum(nextCarrNum(nextCarrNum(bFocusedFont))).hidden = false
        bFocusedFont = nextCarrNum(bFocusedFont)//Change focus
        fontClicked(carrButtonFromNum(bFocusedFont))
    }
    
    @IBAction func fontsSwipedRight(sender : UISwipeGestureRecognizer) {
        //Invisible becomes visible
        carrButtonFromNum(prevCarrNum(prevCarrNum(bFocusedFont))).frame.origin.x = -screenWidth * 1.5
        carrButtonFromNum(prevCarrNum(prevCarrNum(bFocusedFont))).hidden = false
        bFocusedFont = prevCarrNum(bFocusedFont)//Change focus
        fontClicked(carrButtonFromNum(bFocusedFont))
    }
    
    @IBAction func fontClicked(sender : UIButton){
        let newFocus = numFromCarrButton(sender)
        if newFocus == nextCarrNum(bFocusedFont) {
            carrButtonFromNum(nextCarrNum(nextCarrNum(bFocusedFont))).frame.origin.x = screenWidth * 1.5
            carrButtonFromNum(nextCarrNum(nextCarrNum(bFocusedFont))).hidden = false
        } else {
            carrButtonFromNum(prevCarrNum(prevCarrNum(bFocusedFont))).frame.origin.x = -screenWidth * 1.5
            carrButtonFromNum(prevCarrNum(prevCarrNum(bFocusedFont))).hidden = false
        }
        bFocusedFont = newFocus
        UIView.animateWithDuration(0.2, animations: {//Animate all
            self.carrButtonFromNum(self.bFocusedFont).center.x = self.view.center.x
            //Button before
            (self.arrFontButton[self.prevCarrNum(self.bFocusedFont)] as! UIButton).frame.origin.x = CGRectGetMinX((self.arrFontButton[self.bFocusedFont] as! UIButton).frame) - PERC_BlackWidth - (self.arrFontButton[self.prevCarrNum(self.bFocusedFont)] as! UIButton).frame.size.width
            //Button after
            (self.arrFontButton[self.nextCarrNum(self.bFocusedFont)] as! UIButton).frame.origin.x = CGRectGetMaxX((self.arrFontButton[self.bFocusedFont] as! UIButton).frame) + PERC_BlackWidth
            //The last one is hidden
            self.carrButtonFromNum(self.nextCarrNum(self.nextCarrNum(self.bFocusedFont))).hidden = true
            }, completion: { _ in
                
        })
        
        wvFont = sender.titleForState(UIControlState.Normal)!
        wvRead.loadFont(wvFont)
        previousFont.setTitleColor(UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1), forState: UIControlState.Normal)
        sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        previousFont = sender
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(wvFont, forKey: "PREFERRED_FONTFAMILY")
        ud.synchronize()
        updateWVBecauseOfFont()
    }
    
    @IBAction func decreaseFont(sender : UIButton){
        fontSize -= 1
        javaScriptMakeNewFontSize(fontSize, forWebView: wvRead)
        javaScriptMakeNewFontSize(fontSize, forWebView: wvPreviousChapter)
        javaScriptMakeNewFontSize(fontSize, forWebView: wvNextChapter)
        Functions.delay(0.3){
            self.updateWVBecauseOfFont()
        }
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(fontSize, forKey: "PREFERRED_FONTSIZE")
        ud.synchronize()
    }
    
    @IBAction func increaseFont(sender : UIButton){
        fontSize += 1
        javaScriptMakeNewFontSize(fontSize, forWebView: wvRead)
        javaScriptMakeNewFontSize(fontSize, forWebView: wvPreviousChapter)
        javaScriptMakeNewFontSize(fontSize, forWebView: wvNextChapter)
        Functions.delay(0.3){
            self.updateWVBecauseOfFont()
        }
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(fontSize, forKey: "PREFERRED_FONTSIZE")
        ud.synchronize()
    }
    
    func javaScriptMakeNewFontSize(fontSize : Int, forWebView wv : UIWebView) {
        wv.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSize)pt'")
        wv.stringByEvaluatingJavaScriptFromString("document.body.style.lineHeight = '\(fontSize * 3 / 2)pt'")
        wv.stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontSize = '\(fontSize)pt';ps[i].style.lineHeight = '\(fontSize * 3 / 2)pt';}")
    }
    
    func updateWVBecauseOfFont() {
        nPagesPerChapter[currentChapter] = wvRead.pageCount
        if currentChapter != 0 { nPagesPerChapter[currentChapter - 1] = wvPreviousChapter.pageCount }
        if currentChapter != nPagesPerChapter.count - 1 { nPagesPerChapter[currentChapter + 1] = wvNextChapter.pageCount }
        nPagesInCurrentChapter = wvRead.pageCount
        nPagesInPreviousChapter = wvPreviousChapter.pageCount
        nPagesInNextChapter = wvNextChapter.pageCount
        let pageWidth = wvPreviousChapter.scrollView.contentSize.width / CGFloat(nPagesInPreviousChapter)
        wvPreviousChapter.scrollView.contentOffset.x = CGFloat(nPagesInPreviousChapter - 1) * pageWidth
        print("\(wvPreviousChapter.scrollView.contentOffset.x)         \(nPagesInPreviousChapter)")
    }
    
    @IBAction func backToOptions(sender : UIButton){
        UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.vOptions.frame.origin.x = 0
            }, completion: nil)
    }
    
    @IBAction func darkBackground(sender : UIButton){
        optionsGoDown()
        isBackgroundGray = false
        makeWVDisappearThenFadeIn()//We hide the wv to make it fade in (so the user won't see the delay
        wvRead.loadDarkBackground()
        wvNextChapter.loadDarkBackground()
        wvPreviousChapter.loadDarkBackground()
        vBelowWv.backgroundColor = UIColor.whiteColor()//Update the other views
        labPage.textColor = UIColor.whiteColor()
        lTopBookTitle.textColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.blackColor()
        ReadingFunctions.updatePreferDark(userPrefersDark: true)
    }
    
    @IBAction func grayBackground(sender : UIButton){
        optionsGoDown()
        isBackgroundGray = true
        makeWVDisappearThenFadeIn()
        wvRead.loadGrayBackground()
        wvNextChapter.loadGrayBackground()
        wvPreviousChapter.loadGrayBackground()
        vBelowWv.backgroundColor = UIColor.blackColor()
        labPage.textColor = UIColor.blackColor()
        lTopBookTitle.textColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor(red: 239/255, green: 237/255, blue: 237/255, alpha: 1)
        ReadingFunctions.updatePreferDark(userPrefersDark: false)
    }
    
    func makeWVDisappearThenFadeIn() {
        wvRead.alpha = 0
        Functions.delay(0.2) {
            UIView.animateWithDuration(0.3, animations: {
                self.wvRead.alpha = 1.0
            })
        }
    }
    
    func optionsGoDown(){
        if optionsUp {
            UIView.animateWithDuration(0.3, animations: {
                self.vOptions.frame.origin.y = screenHeight
                self.vOptions.frame.origin.x = 0
            })
            optionsUp = false
        }
    }
    //END Options interacions
    //Search book
    func searchedStringAndNumberOfClickedOccurenceInChapter(searched : String, occurence : Int, chapter : Int) {
        removeMenuWithTap()
        currentChapter = chapter
        userClickedSearchResult = true
        textSearched = searched
        occurenceClickedInSearch = occurence
        wvRead.loadRequest(getURLRequestFromChapter(chapter))
    }
    
    func getPreferredWVAttributes() -> Bool {
        let ud = NSUserDefaults.standardUserDefaults()
        if ud.objectForKey("PREFERRED_FONTSIZE") != nil { fontSize = ud.integerForKey("PREFERRED_FONTSIZE") }
        if ud.objectForKey("PREFERRED_FONTFAMILY") != nil { wvFont = ud.objectForKey("PREFERRED_FONTFAMILY") as! String }
        if ud.objectForKey("PREFERRED_BLACKBACKGROUND") != nil {
            if ud.boolForKey("PREFERRED_BLACKBACKGROUND") {
                isBackgroundGray = false
                self.view.backgroundColor = UIColor.blackColor()
                vBelowWv.backgroundColor = UIColor.whiteColor()
                labPage.textColor = UIColor.whiteColor()
                lTopBookTitle.textColor = UIColor.whiteColor()
            }
        }
        if ud.objectForKey("CURRENTCHAPTER_IN\(self.bookId)") != nil {
            self.savedChapter = ud.integerForKey("CURRENTCHAPTER_IN\(self.bookId)")
            if ud.objectForKey("CURRENTPAGEINCHAPTER_IN\(self.bookId)") != nil { self.savedPageInChapter = ud.integerForKey("CURRENTPAGEINCHAPTER_IN\(self.bookId)") }
            return true
        }
        return false
    }
    
    func showMenu(sender : UIBarButtonItem){
        self.view.bringSubviewToFront(vMenu)
        if menuShowed {
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = -PERC_MenuWidth
                self.blurView.effect = nil
                }, completion: { _ in
                    self.blurView.removeFromSuperview()
            })
            menuShowed = false
        } else {
            self.view.addSubview(blurView)
            self.view.bringSubviewToFront(vMenu)
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = 0.0
                self.blurView.effect = UIBlurEffect(style: .Dark)
                }, completion: nil)
            menuShowed = true
        }
    }
    
    func removeMenuWithTap(){
        if menuShowed {
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = -PERC_MenuWidth
                self.blurView.effect = nil
                }, completion: { _ in
                    self.blurView.removeFromSuperview()
            })
            menuShowed = false
        }
    }
    
    @IBAction func mainTap(sender : UITapGestureRecognizer) {
        removeMenuWithTap()
        optionsGoDown()
    }
    
    func buildMenu(){
        //Menu view
        let menuColor : UIColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
        let separatorWidth : CGFloat = PERC_MenuWidth - 2 * PERC_BlackWidth
        
        vMenu = UIView(frame: CGRect(x: -PERC_MenuWidth, y: 64, width: PERC_MenuWidth, height: screenHeight - 64))
        vMenu.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 0.8)
        vMenu.hidden = true
        Functions.delay(0.5){
            self.vMenu.hidden = false
        }
        
        let bMenuFeed = MenuButton(text: "GLOBE FEED", originY: PERC_LightBrownHeight - PERC_BeigeHeight)
        let vBelowFeed = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMenuFeed.frame), width: separatorWidth, height: 1))
        vBelowFeed.backgroundColor = menuColor
        bMenuFeed.addTarget(self, action: #selector(ReadingWithBannerController.popToFeed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let bLibrary = MenuButton(text: "LIBRARY", originY: CGRectGetMaxY(vBelowFeed.frame))
        let vBelowLib = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bLibrary.frame), width: separatorWidth, height: 1))
        vBelowLib.backgroundColor = menuColor
        bLibrary.addTarget(self, action: #selector(ReadingWithBannerController.goToLibrary(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let bMyCollection = MenuButton(text: "MY COLLECTION", originY: CGRectGetMaxY(vBelowLib.frame))
        bMyCollection.addTarget(self, action: #selector(ReadingWithBannerController.goToMyCollection(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let vBelowMy = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMyCollection.frame), width: separatorWidth, height: 2))
        vBelowMy.backgroundColor = menuColor
        
        let bCover = MenuButton(text: "COVER ART", originY: CGRectGetMaxY(vBelowMy.frame))
        let vBelowCover = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bCover.frame), width: separatorWidth, height: 1))
        vBelowCover.backgroundColor = menuColor
        bCover.addTarget(self, action: #selector(ReadingWithBannerController.goToCover(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let bSearchBook = MenuButton(text: "SEARCH BOOK", originY: CGRectGetMaxY(vBelowCover.frame))
        let vBelowSB = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bSearchBook.frame), width: separatorWidth, height: 1))
        vBelowSB.backgroundColor = menuColor
        bSearchBook.addTarget(self, action: #selector(ReadingWithBannerController.searchBook(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let bChapters = MenuButton(text: "CHAPTERS", originY: CGRectGetMaxY(vBelowSB.frame))
        let vBelowCh = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bChapters.frame), width: separatorWidth, height: 1))
        vBelowCh.backgroundColor = menuColor
        bChapters.addTarget(self, action: #selector(ReadingWithBannerController.goToToc(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let bJump = MenuButton(text: "JUMP TO PAGE", originY: CGRectGetMaxY(vBelowCh.frame))
        let vBelowJ = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bJump.frame), width: separatorWidth, height: 1))
        vBelowJ.backgroundColor = menuColor
        bJump.addTarget(self, action: #selector(ReadingWithBannerController.jumpToPage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let bOpt = MenuButton(text: "OPTIONS", originY: CGRectGetMaxY(vBelowJ.frame))
        let vBelowOpt = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bOpt.frame), width: separatorWidth, height: 1))
        vBelowOpt.backgroundColor = menuColor
        bOpt.addTarget(self, action: #selector(ReadingWithBannerController.showOptions(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        vMenu.addSubview(bMenuFeed)
        vMenu.addSubview(vBelowFeed)
        vMenu.addSubview(bLibrary)
        vMenu.addSubview(vBelowLib)
        vMenu.addSubview(bCover)
        vMenu.addSubview(vBelowCover)
        vMenu.addSubview(bMyCollection)
        vMenu.addSubview(vBelowMy)
        vMenu.addSubview(bSearchBook)
        vMenu.addSubview(vBelowSB)
        vMenu.addSubview(bChapters)
        vMenu.addSubview(vBelowCh)
        vMenu.addSubview(bJump)
        vMenu.addSubview(vBelowJ)
        vMenu.addSubview(bOpt)
        vMenu.addSubview(vBelowOpt)
        self.view.addSubview(vMenu)
    }
    
    @IBAction func goToCover(sender : UIButton) {
        removeMenuWithTap()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("cover") as! CoverController
        vc.img = self.cover
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func goToToc(sender : UIButton){
        removeMenuWithTap()
        svToc.hidden = false
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.svToc.alpha = 1
            }, completion: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(backToPage))
    }
    
    @IBAction func backToPage(sender : UIBarButtonItem){
        removeMenuWithTap()
        UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.svToc.alpha = 0
            }, completion: { _ in
                self.svToc.hidden = true
        })
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: .Plain, target: self, action: #selector(showMenu))
    }
    
    @IBAction func popToFeed(sender : UIButton){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func goToMyCollection(sender : UIButton){
        var vcs = self.navigationController!.viewControllers
        let newVCs = NSMutableArray()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myCollec : MyCollectionController = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
        newVCs.addObject(vcs[0])
        newVCs.addObject(myCollec)
        self.navigationController?.setViewControllers(newVCs as NSArray as! [UIViewController], animated: true)
    }
    
    @IBAction func goToLibrary(sender : UIButton){
        var vcs = self.navigationController!.viewControllers
        let newVCs = NSMutableArray()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lib : LibraryController = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
        
        newVCs.addObject(vcs[0])
        newVCs.addObject(lib)
        self.navigationController?.setViewControllers(newVCs as NSArray as! [UIViewController], animated: true)
    }
    
    @IBAction func jumpToPage(sender : UIButton){
        if menuShowed { removeMenuWithTap() }
        if optionsUp { optionsGoDown() }
        let alert = UIAlertController(title: "Jump To", message: "Please enter the number of the page below (max : \(self.nPages)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "00"
            textField.keyboardType = UIKeyboardType.NumberPad
            self.tfJumpToPage = textField
        })
        alert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { _ in
            self.goToPage(Int((self.tfJumpToPage.text! as NSString).intValue))
            return
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showOptions(sender : UIButton){ showMainOptions() }
    
    @IBAction func optionsClicked(sender : UIBarButtonItem) { showMainOptions() }
    
    func showMainOptions() {
        if optionsUp {
            removeMenuWithTap()
            optionsGoDown()
        } else {
            removeMenuWithTap()
            self.view.bringSubviewToFront(self.vOptions)
            optionsUp = true
            UIView.animateWithDuration(0.3, animations: {
                self.vOptions.frame.origin.y = screenHeight - self.vOptions.frame.size.height
            })
        }
    }
    
    @IBAction func searchBook(sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("searchbook") as! SearchBookController
        vc.bookPath = bookDir.stringByAppendingPathComponent(self.contentDir)
        vc.chaptersPaths = pathOfChapter
        vc.chaptersNames = nameOfChapter
        /*vc.dic = dic
        vc.chapters = chapters*/
        vc.dataDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadingText(text : String) {
        lLoading.text = text
        lLoading.sizeToFit()
        lLoading.center.x = view.center.x
    }
    
    override func prefersStatusBarHidden() -> Bool { return self.hideStatusBar }
    
    //End of the book share
    func endOfTheBook() {
        vEnd.frame = self.view.frame
        vEnd.frame.size.height -= ban.frame.size.height
        vEnd.frame.origin.x = screenWidth
        vEnd.hidden = false
        vEnd.userInteractionEnabled = true
        
        let heightShare = AlmostFullWidth / 6
        
        lBookTitle.text = bookTitle
        lAuthor.text = "By \(bookAuthor)"
        
        lCongrats.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_LightBrownHeight)
        lFinished.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lCongrats.frame) + PERC_RedHeight)
        lBookTitle.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lFinished.frame) + PERC_RedHeight)
        lAuthor.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lBookTitle.frame) + PERC_RedHeight)
        lTell.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lAuthor.frame) + PERC_RedHeight)
        sizeToFitLabel(lCongrats)
        sizeToFitLabel(lFinished)
        sizeToFitLabel(lBookTitle)
        sizeToFitLabel(lAuthor)
        sizeToFitLabel(lTell)
        
        ivShareFacebook.frame = CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(lTell.frame) + PERC_DarkPurpleHeight, width: AlmostFullWidth, height: heightShare)
        ivShareFacebook.userInteractionEnabled = true
        ivShareTwitter.frame = CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(ivShareFacebook.frame) + PERC_BlueHeight, width: AlmostFullWidth, height: heightShare)
        ivShareTwitter.userInteractionEnabled = true
        ivShareEmail.frame = CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(ivShareTwitter.frame) + PERC_BlueHeight, width: AlmostFullWidth, height: heightShare)
        ivShareEmail.userInteractionEnabled = true
        
        UIView.animateWithDuration(0.3, animations: {
            self.vEnd.frame.origin.x = 0
        })
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ReadingWithBannerController.swipeLeftEndView(_:)))
        swipeLeft.direction = .Right
        vEnd.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func swipeLeftEndView(sender : UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.3, animations: {
            self.vEnd.frame.origin.x = screenWidth
            }, completion: {_ in
        self.vEnd.hidden = true
        })
    }
    
    func sizeToFitLabel(l : UILabel) {
        l.sizeToFit()
        l.frame.size.width += 10
        l.frame.size.height = PERC_TitlePurpleHeight
    }
    
    @IBAction func fbShare(sender : UITapGestureRecognizer) { fbShareFromParent() }
    
    @IBAction func twittShare(sender : UITapGestureRecognizer) { twittShareFromParent() }
    
    @IBAction func mailShare(sender : UITapGestureRecognizer) { mailShareFromParent() }
    
    func fbShareFromParent() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            vTitle.hidden = true
            navBarShowed = true
            let cvc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            cvc.setInitialText("I just finished \(bookTitle) on globe! Check it out!")
            self.presentViewController(cvc, animated: true, completion: nil)
        }
    }
    
    func twittShareFromParent() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            vTitle.hidden = true
            navBarShowed = true
            let cvc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            cvc.setInitialText("I just finished \(bookTitle) on globe! Check it out! @go_globe")
            self.presentViewController(cvc, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailShareFromParent() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("I just finished \(bookTitle) on globe app")
        mc.setMessageBody("\n\n\n\n\ngetglobe.co", isHTML: false)
        self.presentViewController(mc, animated: true, completion: nil)
    }
}
