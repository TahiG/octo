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

class ReadingController : UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, DataBackDelegate {
    
    @IBOutlet var wvRead : ReadingWebview!
    
    var bookId : String!
    var hideStatusBar = false
    
    var activityIndicator : UIActivityIndicatorView!
    var dir : String!
    var nChapters : Int!
    var firstChapterId : String!
    var contentDir : String! //Directory of content files. Can be OEBPS or OBPS or whatever
    
    var bookDir : String!//Directory of epub file
    var chapters = NSMutableArray()//Contains all the idref from .opf file
    var dic = Dictionary<String, String>()//idref correponding to the name of the corresponding file
    
    var tocSuffix : String!//Table of content file
    var coverSuffix : String!
    
    var vMenu : UIView!
    var menuShowed = false
    var navBarShowed = true
    var bookTitle : String! //Set in ebookfromparse method
    var labPage = UILabel()
    var vTitle : UIWindow! //View above navbar which hides it when user taps on the page
    var lTopBookTitle : UILabel!
    var vBelowWv : UIView!
    
    var nChapterToGetNPages = 0//Used when loading the ebook to know how many pages we got
    var nPages = 0//Total pages
    var currentPageInChapter = 0
    var currentChapter = 0
    var nPagesPerChapter = NSMutableArray()//Pages per chapter
    var currentPageAtAll = 0 // number displayed at the bottom
    
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
    @IBOutlet var scFonts : UIScrollView!
    //Options var
    var isBackgroundGray = true
    var fontSize = 14                                                                                 
    var optionsUp = false
    var wvFont = "Helvetica"
    var previousFont : UIButton!
    
    let transImgPath = NSBundle().pathForResource("imgtrans", ofType: "png") //Used for the transparency of the webview which is not transparent anyway.... Consider removing this
    
    override func viewDidLoad() {
        addActivityIndicator()
        
        //Menu
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: UIBarButtonItemStyle.Plain, target: self, action: "showMenu:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cogs"), style: UIBarButtonItemStyle.Plain, target: self, action: "optionsClicked:")
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        buildMenu()
        
        //views
        wvRead.frame.origin.y = PERC_LightTealHeight - 64
        wvRead.frame.origin.x = PERC_BlackWidth
        wvRead.frame.size.width = wvWidth
        wvRead.frame.size.height = PERC_ReadingPageHeight + 60
        wvRead.paginationBreakingMode = UIWebPaginationBreakingMode.Page
        wvRead.paginationMode = UIWebPaginationMode.LeftToRight
        wvRead.delegate = self
        wvRead.scrollView.scrollEnabled = false
        wvRead.opaque = false
        wvRead.backgroundColor = UIColor.clearColor()
        
        var swLeft = UISwipeGestureRecognizer(target: self, action: "didSwipeLeft:")
        swLeft.direction = UISwipeGestureRecognizerDirection.Left
        var swRight = UISwipeGestureRecognizer(target: self, action: "didSwipeRight:")
        swRight.direction = UISwipeGestureRecognizerDirection.Right
        var swDown = UISwipeGestureRecognizer(target: self, action: "didSwipeDown:")
        swDown.direction = UISwipeGestureRecognizerDirection.Down
        var wvTap = UITapGestureRecognizer(target: self, action: "wvTapped:")
        wvRead.gestureRecognizers = [swLeft, swRight, swDown, wvTap]
        wvTap.delegate = self
        wvTap.numberOfTapsRequired = 1
        wvRead.userInteractionEnabled = true
        wvRead.stringByEvaluatingJavaScriptFromString("addCSSRule('body', 'background-color: transparent !important; background-image:url(\(transImgPath)); background-repeat: repeat-x; background-size:\(wvRead.frame.size.width)px \(wvRead.frame.size.height)px;')")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.setAttribute('style', 'background:#EFEFEF!important;')")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.setAttribute('style', 'margin:0!important;padding:0!important;')")
        
        vBelowWv = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(wvRead.frame) + PERC_YellowHeight, width: screenWidth - PERC_BlackWidth * 2, height: 1))
        vBelowWv.backgroundColor = UIColor.blackColor()
        self.view.addSubview(vBelowWv)
        
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
        
        //Options views
        ivBrightnessSmall.frame = CGRect(x: PERC_BlackWidth, y: PERC_DarkRedWidth, width: PERC_BlueHeight, height: PERC_BlueHeight)
        ivBrightnessBig.frame.size = CGSize(width: PERC_GreenHeight, height: PERC_GreenHeight)
        ivBrightnessBig.frame.origin.x = screenWidth - PERC_BlackWidth - ivBrightnessBig.frame.size.width
        ivBrightnessBig.center.y = ivBrightnessSmall.center.y
        slBrightness.frame = ivBrightnessSmall.frame
        slBrightness.frame.origin.x = CGRectGetMaxX(ivBrightnessSmall.frame) + PERC_DarkRedWidth
        slBrightness.frame.size.width = CGRectGetMinX(ivBrightnessBig.frame) - CGRectGetMaxX(ivBrightnessSmall.frame) - 2 * PERC_DarkRedWidth
        slBrightness.setValue(Float(UIScreen.mainScreen().brightness), animated: false)
        
        var vSepSL = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(slBrightness.frame) + PERC_YellowHeight, width: screenWidth, height: 2))
        vSepSL.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepSL)
        
        bFontMinu.frame = CGRect(x: 0, y: CGRectGetMaxY(vSepSL.frame), width: halfScreenWidth - 1, height: PERC_DarkTealHeight)
        
        var vSepB = UIView(frame: CGRect(x: halfScreenWidth - 1, y: CGRectGetMaxY(vSepSL.frame), width: 2, height: PERC_DarkTealHeight))
        vSepB.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepB)
        
        bFontPlus.frame = CGRect(x: halfScreenWidth + 1, y: CGRectGetMaxY(vSepSL.frame), width: halfScreenWidth - 1, height: PERC_DarkTealHeight)
        
        var vSepFont = UIView(frame: vSepSL.frame)
        vSepFont.frame.origin.y = CGRectGetMaxY(bFontMinu.frame)
        vSepFont.backgroundColor = UIColor.blackColor()
        vOptions.addSubview(vSepFont)
        //Fonts
        scFonts.frame = CGRect(x: 0, y: CGRectGetMaxY(vSepFont.frame), width: screenWidth, height: PERC_DarkTealHeight + PERC_BlueHeight)
        
        bFontHelvetica.frame = CGRect(x: PERC_BlackWidth, y: PERC_BlueHeight / 2, width: HalfScreenButtonWidth, height: PERC_ButtonFont - 2)
        bFontGeorgia.frame = CGRect(x: CGRectGetMaxX(bFontHelvetica.frame) + PERC_BlackWidth, y: PERC_BlueHeight / 2, width: HalfScreenButtonWidth, height: PERC_ButtonFont - 2)
        bFontBaskerville.frame = CGRect(x: CGRectGetMaxX(bFontGeorgia.frame) + PERC_BlackWidth, y: PERC_BlueHeight / 2, width: HalfScreenButtonWidth, height: PERC_ButtonFont - 2)
        bFontPalatino.frame = CGRect(x: CGRectGetMaxX(bFontBaskerville.frame) + PERC_BlackWidth, y: PERC_BlueHeight / 2, width: HalfScreenButtonWidth, height: PERC_ButtonFont - 2)
        scFonts.contentSize.width = CGRectGetMaxX(bFontPalatino.frame) + PERC_BlackWidth
        previousFont = bFontHelvetica
        
        bGrayBackground.frame = CGRect(x: 0, y: CGRectGetMaxY(scFonts.frame), width: halfScreenWidth, height: PERC_DarkTealHeight + PERC_TealHeight)        
        bBlackBackground.frame = CGRect(x: halfScreenWidth, y: CGRectGetMaxY(scFonts.frame), width: halfScreenWidth, height: PERC_DarkTealHeight + PERC_TealHeight)
        
        vOptions.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: CGRectGetMaxY(bBlackBackground.frame))
        //END options views
        
        //For testing
        //bookId = "PMh0poSOKF"
        //self.wvRead.loadHTMLString("<body style=\"background-color:transparent\">KIKOU SALOPPE</body>", baseURL: nil)
        ebookFromParse()
    }
    //Charger chapitres quand fini puis swipe gauche pour amener a chapitre 0
    func webViewDidFinishLoad(webView: UIWebView) {
        //We do this before so if we load a new chapter, it will have the real number of pages BUT we only do this if the webview finished loading
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.fontFamily = '\(wvFont)'")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSize)pt'")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.lineHeight = '\(fontSize * 3 / 2)pt'")
        wvRead.stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontFamily = '\(wvFont)';ps[i].style.fontSize = '\(fontSize)pt';}")
        
        println(webView.request!.URL!.absoluteString)
        //Loading data for optimal reading experience
        lTopBookTitle.text = "Chapter \(currentChapter - 3)"
        lTopBookTitle.sizeToFit()
        lTopBookTitle.center.x = self.view.center.x
        if stillLoading {
            //Getting pages number of this chapter / updating total pages
            var n = webView.pageCount
            self.nPages += n
            println("\(n) pages in \(self.nChapterToGetNPages)")
            //Updating pagesperchapter
            self.nPagesPerChapter.addObject(n)
            if (chapters.count - 1) == self.nChapterToGetNPages {
                //Last chapter, we load the first page again
                println("c'est le dernier")
                self.currentChapter = 0
                self.currentPageAtAll = 0
                self.currentPageInChapter = 0
                let codeb : String = chapters[self.currentChapter] as! String
                let suffixb = dic[codeb]
                let urlChapterb = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(suffixb!))
                self.stillLoading = false
                println(self.nPagesPerChapter)
                webView.loadRequest(NSURLRequest(URL: urlChapterb!))
            } else {
                //Not the last one, we load the next one
                self.nChapterToGetNPages++
                let code: String = chapters[self.nChapterToGetNPages] as! String
                println(code)
                let suffix = dic[code]
                println(suffix)
                let urlChapter = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(suffix!))
                webView.loadRequest(NSURLRequest(URL: urlChapter!))
            }
        } else if userClickedChapters {
            if !userGoesToToc {
                if weAreGoingBackToAPage {
                    wvRead.scrollView.contentOffset.x = self.xOffsetToGoBackTo
                    weAreGoingBackToAPage = false
                } else {
                    //User clicked on a chapter
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: UIBarButtonItemStyle.Plain, target: self, action: "showMenu:")
                    //We wanna know which chapter was clicked
                    self.currentChapter = getChapter()
                    self.updateCurrentPageWhichIsAtBeginningOfCurrentChapter()
                }
                userClickedChapters = false
            } else {
                userGoesToToc = false
            }
        } else if wvIsLoadingNewChapter {
            self.nPagesPerChapter[self.currentChapter] = wvRead.pageCount
            if wvIsloadingNextChapter {
                self.wvRead.scrollView.contentOffset.x = -self.wvWidth
                UIView.animateWithDuration(Double(0.2), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.scrollView.contentOffset.x = 0
                    return
                    }, completion: nil)
            } else {
                self.currentPageInChapter = self.nPagesPerChapter[self.currentChapter] as! Int - 1
                self.wvRead.scrollView.contentOffset.x = CGFloat(self.nPagesPerChapter[self.currentChapter] as! Int) * self.wvWidth
                UIView.animateWithDuration(Double(0.2), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * self.wvWidth
                    return
                    }, completion: nil)
            }
            wvIsLoadingNewChapter = false
        } else if wvIsCurrentlyJumpingAndWeNeedToChangeOffset {
            //We need to jump to current page
            UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * self.wvWidth
                return
                }, completion: nil)
        }
        
        if !stillLoading { //Ebook is not loading anymore, we load user's preferences
            if !isBackgroundGray {
                //wvRead.stringByEvaluatingJavaScriptFromString("document.body.setAttribute('style', 'background:#000000!important')")
                wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#000000', 'important')")
                wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#EFEFEF'")
            } else {
                //wvRead.stringByEvaluatingJavaScriptFromString("document.body.setAttribute('style', 'background:#EFEFEF!important')")
                wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#EFEFEF', 'important')")
                wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#000000'")
            }
            //To use if user clicks chapter in TOC
            //self.currentChapter = getChapter()
            updateCurrentPageWhichIsAtBeginningOfCurrentChapter()
        }
        
        if userClickedSearchResult {
            userClickedSearchResult = false
            updateCurrentPageWhichIsAtBeginningOfCurrentChapter()
            delay(0.3) {
                webView.stringByEvaluatingJavaScriptFromString("function scrollToSearched(elt){ if (elt) {if (elt.nodeType == 3) { while (true) { var value = elt.nodeValue;var idx = value.toLowerCase().indexOf('\(self.textSearched)');if (idx < 0) break; var span = document.createElement('span'); var text = document.createTextNode(value.substr(idx,\(count(self.textSearched)))); span.appendChild(text); span.setAttribute('class','onsentape'); span.setAttribute('id','searched-now-' +  count); span.style.backgroundColor='yellow'; span.style.color='black'; text = document.createTextNode(value.substr(idx+\(count(self.textSearched)))); elt.deleteData(idx, value.length - idx); var next = elt.nextSibling; elt.parentNode.insertBefore(span, next); elt.parentNode.insertBefore(text, next); elt = text; count++;}}else if (elt.nodeType == 1) { if (elt.style.display != 'none' && elt.nodeName.toLowerCase() != 'select') { for (var i=elt.childNodes.length-1; i>=0; i--) { scrollToSearched(elt.childNodes[i]); } } } } } var count = 1; scrollToSearched(document.body);")
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func didSwipeRight(sender : UISwipeGestureRecognizer){
        if self.currentPageInChapter > 0 {
            self.currentPageInChapter--
            UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * self.wvWidth
                return
                }, completion: nil)
            self.currentPageAtAll--
            self.labPage.text = "\(self.currentPageAtAll)"
            self.labPage.sizeToFit()
            self.labPage.center.x = self.view.center.x
        } else {
            //Previous chapter
            if self.currentChapter != 0 {
                self.currentChapter--
                self.currentPageAtAll--
                let code: String = chapters[self.currentChapter] as! String
                let suffix = dic[code]
                let urlChapter = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(suffix!))
                let nextReq = NSURLRequest(URL: urlChapter!)
                UIView.animateWithDuration(Double(0.2), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.scrollView.contentOffset.x = -self.wvWidth
                    return
                    }, completion: { _ in
                        self.wvIsLoadingNewChapter = true
                        self.wvIsloadingNextChapter = false
                        self.wvRead.loadRequest(nextReq)
                        return
                })
                self.labPage.text = "\(self.currentPageAtAll)"
                self.labPage.sizeToFit()
                self.labPage.center.x = self.view.center.x
            }
        }
    }
    
    @IBAction func didSwipeLeft(sender : UISwipeGestureRecognizer){
        if (self.currentPageInChapter + 1) != self.nPagesPerChapter[self.currentChapter] as! Int {
            self.currentPageInChapter++
            UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter) * self.wvWidth
                return
                }, completion: nil)
            self.currentPageAtAll++
            self.labPage.text = "\(self.currentPageAtAll)"
            self.labPage.sizeToFit()
            self.labPage.center.x = self.view.center.x
        } else {
            //Next chapter
            if self.currentChapter < self.nChapters - 1 {
                self.currentChapter++
                self.currentPageAtAll++
                UIView.animateWithDuration(Double(0.2), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.wvRead.scrollView.contentOffset.x = CGFloat(self.currentPageInChapter + 1) * self.wvWidth
                    return
                    }, completion: { _ in
                        self.currentPageInChapter = 0
                        let code: String = self.chapters[self.currentChapter] as! String
                        let suffix = self.dic[code]
                        let urlChapter = NSURL(fileURLWithPath: self.bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(suffix!))
                        let nextReq = NSURLRequest(URL: urlChapter!)
                        self.wvIsLoadingNewChapter = true
                        self.wvIsloadingNextChapter = true
                        self.wvRead.loadRequest(nextReq)
                        return
                })
                self.labPage.text = "\(self.currentPageAtAll)"
                self.labPage.sizeToFit()
                self.labPage.center.x = self.view.center.x
            }
            
        }
    }
    
    @IBAction func didSwipeDown(sender : UISwipeGestureRecognizer){
        optionsGoDown()
    }
    
    func getChapter() -> Int {
        let url = self.wvRead.request?.URL?.lastPathComponent
        for(var i = 0 ; i < chapters.count ; i++){
            let d = dic[chapters[i] as! String]!
            if url! == d {
                return i
            }
        }
        return 0
    }
    
    func updateCurrentPageWhichIsAtBeginningOfCurrentChapter(){
        var temp = 0
        for(var i = 0 ; i < self.currentChapter ; i++){
            temp += self.nPagesPerChapter[i] as! Int
        }
        self.currentPageAtAll = temp
        self.currentPageInChapter = 0
    }
    
    @IBAction func wvTapped(sender : UITapGestureRecognizer){
        optionsGoDown()
        //Smooth transitions to hide and show some stuffs which are not necesary for the reader
        removeMenuWithTap()
        //If the user clicked chapters, we don't car about imersion s this functionality won't work
        if !userClickedChapters {
            if navBarShowed {
                vTitle.hidden = false
                UIView.animateWithDuration(0.3, animations: {
                    self.vBelowWv.backgroundColor = UIColor.clearColor()
                    //self.labPage.textColor = UIColor.clearColor()
                    self.labPage.alpha = 0.6
                    self.vTitle.backgroundColor = self.view.backgroundColor
                    self.lTopBookTitle.alpha = 0.6
                    return
                    }, completion: { _ in
                        self.labPage.hidden = false
                        return
                })
                navBarShowed = false
            } else {
                if isBackgroundGray {
                    UIView.animateWithDuration(0.3, animations: {
                        self.vBelowWv.backgroundColor = UIColor.blackColor()
                        //self.labPage.textColor = UIColor.blackColor()
                        self.labPage.alpha = 0
                        self.vTitle.backgroundColor = UIColor.clearColor()
                        self.lTopBookTitle.alpha = 0
                        return
                        }, completion: { _ in
                            self.vTitle.hidden = true
                            self.labPage.hidden = true
                            return
                    })
                } else {
                    UIView.animateWithDuration(0.3, animations: {
                        self.vBelowWv.backgroundColor = UIColor.whiteColor()
                        //self.labPage.textColor = UIColor.whiteColor()
                        self.labPage.alpha = 0
                        self.vTitle.backgroundColor = UIColor.clearColor()
                        self.lTopBookTitle.alpha = 0
                        return
                        }, completion: { _ in
                            self.vTitle.hidden = true
                            self.labPage.hidden = true
                            return
                    })
                }
                navBarShowed = true
            }
        }
    }
    
    func isBookInDocs() -> Bool {
        let ud = NSUserDefaults.standardUserDefaults()
        if ud.objectForKey("BOOK" + self.bookId) != nil {
            return ud.boolForKey("BOOK" + self.bookId)
        } else {
            return false
        }
    }
    //Getting the ebook from parse and (below,) parsing ebook content
    func ebookFromParse() {
        //Getting ebook data
        var queryBook = PFQuery(className: "Book")
        queryBook.whereKey("objectId", equalTo: self.bookId)
        queryBook.getFirstObjectInBackgroundWithBlock{ (object: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                self.bookTitle = object?.objectForKey("name") as! String
                self.navigationItem.title = self.bookTitle
                self.lTopBookTitle.text = self.bookTitle
                self.lTopBookTitle.sizeToFit()
                self.lTopBookTitle.center.x = self.view.center.x
                var dat = object?.objectForKey("epub") as! PFFile
                dat.getDataInBackgroundWithBlock({
                    (bookData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        println("returning epub file")
                        //Data retrieved, we store epub file
                        if self.storeEPubInDoc(bookData!) {
                            //Unzip epub
                            var zip = ZipArchive()
                            if zip.UnzipOpenFile(self.bookDir.stringByAppendingPathComponent("book.epub")) {
                                var isUnzipped = zip.UnzipFileTo(self.bookDir, overWrite: true)
                                if !isUnzipped {
                                    println("unzip failed")
                                    zip.UnzipCloseFile()
                                } else {
                                    //All good we fill reference dictionary with the content file
                                    var contentFilePath = self.getContentFilePath()
                                    var contentFullPath : String!
                                    if self.contentDir != nil {//This was just to get content folder if it exists
                                        contentFullPath = self.contentDir + "/" + contentFilePath
                                    } else {
                                        self.contentDir = ""
                                        contentFullPath = contentFilePath
                                    }
                                    self.fillRefDictionnaryWithContentFilePath(contentFullPath)
                                    self.getChaptersFromContentFilePath(contentFullPath)
                                    self.removeActivityIndicator()
                                }
                            }
                        }
                    } else {
                        println(error)
                    }
                })
            } else {
                println(error)
            }
        }
    }
    
    func storeEPubInDoc(ebookData : NSData) -> Bool {
        //Getting documents dir path
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        //Creating book dir
        bookDir = docsDir.stringByAppendingPathComponent(self.bookId)
        var error: NSError?
        if !filemgr.createDirectoryAtPath(bookDir, withIntermediateDirectories: true, attributes: nil, error: &error) {
            println("Failed to create dir: \(error!.localizedDescription)")
            return false
        } else {
            //Creating file book.epub in previously created dir
            if !filemgr.createFileAtPath(bookDir.stringByAppendingPathComponent("book.epub"), contents: ebookData, attributes: nil){
                println("Failed to create dir: \(error!.localizedDescription)")
                return false
            } else {
                return true
            }
        }
    }
    
    func getContentFilePath() -> String {
        //Get container.xml
        let filemgr = NSFileManager.defaultManager()
        let strContainer = NSString(contentsOfFile: bookDir.stringByAppendingPathComponent("META-INF").stringByAppendingPathComponent("container.xml"), encoding: NSUTF8StringEncoding, error: nil)
        //Parse container.xml
        var tempScanned: NSString?
        let sc = NSScanner(string: strContainer! as String)
        var contentPath : String!
        if sc.scanUpToString("<rootfile ", intoString:nil) {
            sc.scanString("<rootfile ", intoString:nil)
            if sc.scanUpToString(">", intoString:&tempScanned) {
                //Parse rootfile attributes
                let sn = tempScanned as! String
                let newSc = NSScanner(string: sn)
                if newSc.scanUpToString("path=\"", intoString: nil){
                    newSc.scanString("path=\"", intoString: nil)
                    if newSc.scanUpToString("\"", intoString: &tempScanned){
                        let fullPath = tempScanned as! String
                        println(fullPath)
                        let scFullPath = NSScanner(string: fullPath)
                        var folder : NSString?
                        if scFullPath.scanUpToString("/", intoString: &folder){
                            self.contentDir = folder as! String
                            var fileName = tempScanned!.stringByReplacingOccurrencesOfString(self.contentDir + "/", withString: "")
                            return fileName as String
                        } else {
                            return fullPath
                        }
                    }
                }
            }
        }
        return "OEBPS/content.opf" //Return default value
    }
    
    func fillRefDictionnaryWithContentFilePath(path : String!){
        //Content File
        let strContent = NSString(contentsOfFile: bookDir.stringByAppendingPathComponent(path), encoding: NSUTF8StringEncoding, error: nil)
        //We get the content of manifest tag
        let manifestScan = NSScanner(string : strContent! as String)
        manifestScan.scanUpToString("<manifest", intoString: nil)
        manifestScan.scanString("<manifest", intoString: nil)
        var manifestContent : NSString?
        manifestScan.scanUpToString("</manifest>", intoString: &manifestContent)
        //We get the ids and the hrefs of the different files in the manifest node
        var petitScanned: NSString?
        let petitScanner = NSScanner(string: manifestContent! as String)
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
            } else {
                anyMore = false
            }
            if anyMore {
                if id.contains("cover") || id == "cover" {
                    coverSuffix = href
                } else if id.contains("toc") || id == "toc" || id.contains("TOC") || id == "TOC" {
                    tocSuffix = href
                }
                dic[id] = href
            }
        }
        //By the way, we get toc url   CONSIDER REMOVING THIS PART
        let scanGuide = NSScanner(string: strContent as! String)
        if scanGuide.scanUpToString("<guide>", intoString: nil){
            scanGuide.scanString("<guide>", intoString: nil)
            var guide : NSString?
            if scanGuide.scanUpToString("</guide>", intoString:&guide){
                let smScan = NSScanner(string: guide as! String)
                var foundToc = false
                var bugCounter = 0
                do {
                    bugCounter++
                    smScan.scanUpToString("<reference", intoString: nil)
                    smScan.scanString("<reference", intoString: nil)
                    var ref : NSString?
                    if smScan.scanUpToString("/>", intoString: &ref){
                        let sRef = ref as! String
                        if (sRef as NSString).rangeOfString("toc").location != NSNotFound {
                            let refScan = NSScanner(string: sRef)
                            refScan.scanString("href=\"", intoString: nil)
                            var tocRef : NSString?
                            if refScan.scanUpToString("\"", intoString: &tocRef){
                                self.tocSuffix = tocRef as! String
                                println("Found toc. File is \(self.tocSuffix)")
                                foundToc = true
                            }
                        }
                    }
                    
                } while !foundToc && bugCounter < 500
            }
        }
    }
    
    func getChaptersFromContentFilePath(path : String) {
        var fci : NSString?
        var tmp : NSString!
        let strContent = NSString(contentsOfFile: bookDir.stringByAppendingPathComponent(path), encoding: NSUTF8StringEncoding, error: nil)
        let scanChapter = NSScanner(string: strContent! as String)
        var anymoreChapters = true
        //We get the first chapter id to load it first
        do {
            if scanChapter.scanUpToString("idref=\"", intoString:nil) {
                scanChapter.scanString("idref=\"", intoString:nil)
                if scanChapter.scanUpToString("\"", intoString:&fci) {
                    tmp = fci!
                }
            }
        } while tmp.rangeOfString("leaf").location != NSNotFound
        
        var counter = 0
        firstChapterId = tmp as! String
        chapters.insertObject(firstChapterId, atIndex: counter)
        println(firstChapterId)
        println(dic[firstChapterId])
        counter++
        
       while anymoreChapters {
            if scanChapter.scanUpToString("idref=\"", intoString:nil) {
                scanChapter.scanString("idref=\"", intoString:nil)
                if scanChapter.scanUpToString("\"", intoString:&fci) {
                    var chapterId = fci as! String
                    //See above id & href to understand this condition
                    /*if chapterId.contains("cover") || chapterId == "cover" {
                        println("cover file")
                    } else if chapterId.contains("toc") || chapterId == "toc" || chapterId.contains("TOC") || chapterId == "TOC" {
                        println("toc file")
                    } else {
                        chapters.insertObject(chapterId, atIndex: counter)
                        counter++
                    }*/
                    chapters.insertObject(chapterId, atIndex: counter)
                    counter++
                    //chapters.insertObject(chapterId, atIndex: counter)
                    println(chapterId)
                    println(dic[chapterId])
                }
            } else {
                anymoreChapters = false
            }
        }
        self.nChapters = counter
        
        //We retrieve the url from the dictionary
        var suffix = dic[firstChapterId]
        //Full path
        let urlFirstChapter = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent("OEBPS").stringByAppendingPathComponent(suffix!))
        //Loading in webview
        wvRead.loadRequest(NSURLRequest(URL: urlFirstChapter!))
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
        for(var i = 0 ; i < nPagesPerChapter.count ; i++){
            var nPagesInI = totalPages + (nPagesPerChapter[i] as! Int)
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
                let suffix = dic[chapters[i] as! String]
                let pageUrl = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(suffix!))
                wvRead.loadRequest(NSURLRequest(URL: pageUrl!))
                return
            } else {
                totalPages = nPagesInI
            }
        }
    }
    
    //Options interactions
    @IBAction func brightnessChanged(sender : UISlider){
        UIScreen.mainScreen().brightness = CGFloat(sender.value)
    }
    
    @IBAction func decreaseFont(sender : UIButton){
        fontSize -= 1
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSize)pt'")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.lineHeight = '\(fontSize * 3 / 2)pt'")
        wvRead.stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontSize = '\(fontSize)pt';ps[i].style.lineHeight = '\(fontSize * 3 / 2)pt';}")
        delay(0.3){
            self.nPagesPerChapter[self.currentChapter] = self.wvRead.pageCount
        }
    }
    
    @IBAction func increaseFont(sender : UIButton){
        fontSize += 1
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSize)pt'")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.lineHeight = '\(fontSize * 3 / 2)pt'")
        wvRead.stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontSize = '\(fontSize)pt';ps[i].style.lineHeight = '\(fontSize * 3 / 2)pt';}")
        delay(0.3){
            self.nPagesPerChapter[self.currentChapter] = self.wvRead.pageCount
        }
    }
    
    @IBAction func chooseFont(sender : UIButton){
        UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.vOptions.frame.origin.x = -screenWidth
        }, completion: nil)
    }
    
    @IBAction func fontClicked(sender : UIButton){
        wvFont = sender.titleForState(UIControlState.Normal)!
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.fontFamily = '\(wvFont)'")
        wvRead.stringByEvaluatingJavaScriptFromString("var ps = document.getElementsByTagName('p');for(var i =0;i<ps.length;i++){ps[i].style.fontFamily = '\(wvFont)';}")
        previousFont.setTitleColor(UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1), forState: UIControlState.Normal)
        sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        previousFont = sender
    }
    
    @IBAction func backToOptions(sender : UIButton){
        UIView.animateWithDuration(Double(0.4), delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.vOptions.frame.origin.x = 0
            }, completion: nil)
    }
    
    @IBAction func darkBackground(sender : UIButton){
        optionsGoDown()
        isBackgroundGray = false
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#000000', 'important')")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#EFEFEF'")
        vBelowWv.backgroundColor = UIColor.whiteColor()
        labPage.textColor = UIColor.whiteColor()
        lTopBookTitle.textColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    @IBAction func grayBackground(sender : UIButton){
        optionsGoDown()
        isBackgroundGray = true
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.setProperty('background', '#EFEFEF', 'important')")
        wvRead.stringByEvaluatingJavaScriptFromString("document.body.style.color = '#000000'")
        vBelowWv.backgroundColor = UIColor.blackColor()
        labPage.textColor = UIColor.blackColor()
        lTopBookTitle.textColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor(red: 239/255, green: 237/255, blue: 237/255, alpha: 1)
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
        let chapId = chapters[chapter] as! String
        var suffix = dic[chapId]
        let url = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(contentDir).stringByAppendingPathComponent(suffix!))
        wvRead.loadRequest(NSURLRequest(URL: url!))
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
    
    func removeMenuWithTap(){
        if menuShowed {
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = -PERC_MenuWidth
                }, completion: nil)
            menuShowed = false
        }
    }
    
    func buildMenu(){
        //Menu view
        let menuColor : UIColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
        let separatorWidth : CGFloat = PERC_MenuWidth - 2 * PERC_BlackWidth
        let menuFont = UIFont(name: "MuseoSans-700", size: 17.5)
        
        vMenu = UIView(frame: CGRect(x: -PERC_MenuWidth, y: 64, width: PERC_MenuWidth, height: screenHeight - 64))
        vMenu.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 0.8)
        vMenu.hidden = true
        delay(0.5){
            self.vMenu.hidden = false
        }
        
        var bMenuFeed = MenuButton(text: "GLOBE FEED", originY: PERC_LightBrownHeight - PERC_BeigeHeight)
        var vBelowFeed = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMenuFeed.frame), width: separatorWidth, height: 1))
        vBelowFeed.backgroundColor = menuColor
        bMenuFeed.addTarget(self, action: "popToFeed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bLibrary = MenuButton(text: "LIBRARY", originY: CGRectGetMaxY(vBelowFeed.frame))
        var vBelowLib = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bLibrary.frame), width: separatorWidth, height: 1))
        vBelowLib.backgroundColor = menuColor
        bLibrary.addTarget(self, action: "goToLibrary:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bMyCollection = MenuButton(text: "MY COLLECTION", originY: CGRectGetMaxY(vBelowLib.frame))
        bMyCollection.addTarget(self, action: "goToMyCollection:", forControlEvents: UIControlEvents.TouchUpInside)
        var vBelowMy = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMyCollection.frame), width: separatorWidth, height: 2))
        vBelowMy.backgroundColor = menuColor
        
        var bCover = MenuButton(text: "COVER ART", originY: CGRectGetMaxY(vBelowMy.frame))
        var vBelowCover = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bCover.frame), width: separatorWidth, height: 1))
        vBelowCover.backgroundColor = menuColor
        bCover.addTarget(self, action: "goToCover:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bSearchBook = MenuButton(text: "SEARCH BOOK", originY: CGRectGetMaxY(vBelowCover.frame))
        var vBelowSB = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bSearchBook.frame), width: separatorWidth, height: 1))
        vBelowSB.backgroundColor = menuColor
        bSearchBook.addTarget(self, action: "searchBook:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bChapters = MenuButton(text: "CHAPTERS", originY: CGRectGetMaxY(vBelowSB.frame))
        var vBelowCh = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bChapters.frame), width: separatorWidth, height: 1))
        vBelowCh.backgroundColor = menuColor
        bChapters.addTarget(self, action: "goToToc:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bJump = MenuButton(text: "JUMP TO PAGE", originY: CGRectGetMaxY(vBelowCh.frame))
        var vBelowJ = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bJump.frame), width: separatorWidth, height: 1))
        vBelowJ.backgroundColor = menuColor
        bJump.addTarget(self, action: "jumpToPage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bOpt = MenuButton(text: "OPTIONS", originY: CGRectGetMaxY(vBelowJ.frame))
        var vBelowOpt = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bOpt.frame), width: separatorWidth, height: 1))
        vBelowOpt.backgroundColor = menuColor
        bOpt.addTarget(self, action: "showOptions:", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        userClickedCover = true
        self.urlToGoBackTo = self.wvRead.request!.URL!
        self.xOffsetToGoBackTo = self.wvRead.scrollView.contentOffset.x
        let urlChapter = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(self.tocSuffix))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "backToPage:")
        self.wvRead.loadRequest(NSURLRequest(URL: urlChapter!))
    }
    
    @IBAction func goToToc(sender : UIButton){
        removeMenuWithTap()
        userClickedChapters = true
        userGoesToToc = true
        self.urlToGoBackTo = self.wvRead.request!.URL!
        self.xOffsetToGoBackTo = self.wvRead.scrollView.contentOffset.x
        let urlChapter = NSURL(fileURLWithPath: bookDir.stringByAppendingPathComponent(self.contentDir).stringByAppendingPathComponent(self.tocSuffix))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "backToPage:")
        self.wvRead.loadRequest(NSURLRequest(URL: urlChapter!))
    }
    
    @IBAction func backToPage(sender : UIBarButtonItem){
        removeMenuWithTap()
        self.weAreGoingBackToAPage = true
        self.wvRead.loadRequest(NSURLRequest(URL: self.urlToGoBackTo))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: UIBarButtonItemStyle.Plain, target: self, action: "showMenu:")
    }
    
    @IBAction func popToFeed(sender : UIButton){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func goToMyCollection(sender : UIButton){
        var vcs = self.navigationController!.viewControllers
        var newVCs = NSMutableArray()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myCollec : MyCollectionController = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
        newVCs.addObject(vcs[0])
        newVCs.addObject(myCollec)
        self.navigationController?.setViewControllers(newVCs as [AnyObject], animated: true)
    }
    
    @IBAction func goToLibrary(sender : UIButton){
        var vcs = self.navigationController!.viewControllers
        var newVCs = NSMutableArray()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lib : LibraryController = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
        
        newVCs.addObject(vcs[0])
        newVCs.addObject(lib)
        self.navigationController?.setViewControllers(newVCs as [AnyObject], animated: true)
    }
    
    @IBAction func jumpToPage(sender : UIButton){
        var alert = UIAlertController(title: "Jump To", message: "Please enter the number of the page below (max : \(self.nPages)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "00"
            textField.keyboardType = UIKeyboardType.NumberPad
            self.tfJumpToPage = textField
        })
        alert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { _ in
            self.goToPage(Int((self.tfJumpToPage.text as NSString).intValue))
            return
            }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showOptions(sender : UIButton){
        if optionsUp{
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
    
    
    @IBAction func optionsClicked(sender : UIBarButtonItem) {
        if optionsUp{
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
        vc.dic = dic
        vc.chapters = chapters
        vc.dataDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.hideStatusBar
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}