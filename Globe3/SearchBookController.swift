//
//  SearchBookController.swift
//  Globe3
//
//  Created by Charles Masson on 11/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class SearchBookController : UIViewController, UITextFieldDelegate {
    @IBOutlet var vHeader : UIView!
    @IBOutlet var ivSearch : UIImageView!
    @IBOutlet var ivCancel : UIImageView!
    @IBOutlet var bCancel : UIButton!
    @IBOutlet var tfSearch : UITextField!
    @IBOutlet var vBelowSearchField : UIView!
    @IBOutlet var scResults : UIScrollView!
    
    var bookPath : NSString!
   /* var chapters : NSMutableArray!//Contains all the idref from .opf file
    var dic : Dictionary<String, String>!//idref correponding to the name of the corresponding file*/
    
    var chaptersPaths : NSMutableArray!
    var chaptersNames : NSMutableArray!
    
    var activityIndicator : UIActivityIndicatorView!
    
    let afterBefore = 100 // Length of string before and after found text
    
    var currentChapter = 0
    var countResult = 0
    var occurenceInChapter = 1
    var tabChapters = NSMutableArray()
    var tabOccurences = NSMutableArray()
    
    var tabTexts = NSMutableArray()
    
    
    var dataDelegate : DataBackDelegate?
    var textEntered : String!
    
    var stop = false
    
    let titleFont = UIFont(name: "MuseoSans-700", size: 12.5)
    let titleColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
    
    let countLimit = 500
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Search book"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SearchBookController.back(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        
        vHeader.frame.origin.x = 0.0
        vHeader.frame.origin.y = 64.0
        vHeader.frame.size.height = PERC_SearchHeight + 3 * PERC_YellowHeight
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
        
        ivCancel.frame = ivSearch.frame
        ivCancel.frame.origin.x = screenWidth - ivSearch.frame.size.width - 2 * PERC_SearchMargin - 18 / 2
        
        bCancel.frame = ivCancel.frame
        bCancel.addTarget(self, action: #selector(SearchBookController.eraseText(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        tfSearch.frame.origin.x = CGRectGetMaxX(ivSearch.frame) + PERC_BlackWidth
        tfSearch.frame.origin.y = 0.0
        tfSearch.frame.size.height = vBelowSearchField.frame.size.height
        tfSearch.frame.size.width = CGRectGetMinX(ivCancel.frame) - CGRectGetMaxX(ivSearch.frame) - 2 * PERC_BlackWidth
        tfSearch.returnKeyType = UIReturnKeyType.Search
        tfSearch.delegate = self
        
        let vBlackBelow = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(vHeader.frame), width: screenWidth, height: 1))
        vBlackBelow.backgroundColor = UIColor.blackColor()
        self.view.addSubview(vBlackBelow)
        
        scResults.frame.origin.x = 0.0
        scResults.frame.origin.y = CGRectGetMaxY(vBlackBelow.frame)
        scResults.frame.size.width = screenWidth
        scResults.frame.size.height = screenHeight - vHeader.frame.size.height - 64 - 1
        scResults.backgroundColor = UIColor(red: 239/255, green: 237/255, blue: 237/255, alpha: 1.0)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(tf: UITextField) -> Bool {
        self.view.endEditing(true)
        if tf == self.tfSearch {
            searchBook()
        }
        return true
    }
    
    func searchBook(){
        currentChapter = 0
        occurenceInChapter = 1
        countResult = 0
        stop = false
        for v in scResults.subviews { v.removeFromSuperview() }
        let searched = tfSearch.text
        addActivityIndicator()
        textEntered = searched
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for c in self.chaptersPaths {
                if !stop {
                    var str : NSString = ""
                    do {
                        try str = NSString(contentsOfFile: self.bookPath.stringByAppendingPathComponent(c as! String), encoding: NSUTF8StringEncoding)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                    let s = self.stringWithoutHtmlTags(str)
                    if s.contains(searched!){
                        //dispatch_async(dispatch_get_main_queue(), {
                        self.showResults(s, searched: searched!, currentChapter: self.currentChapter)
                        self.currentChapter += 1
                        //})
                    }
                    
                    self.occurenceInChapter = 1
                    print(self.currentChapter)
                    print(c)
                }
                
            }
        if(stop) {
            let alert = UIAlertController(title: "Search", message: "Too many results, this may take a while", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Display 500 results", style: UIAlertActionStyle.Cancel, handler: buildResultViews)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            buildResultViews(UIAlertAction())
        }
        
        //})
        self.removeActivityIndicator()
    }
    
    func stringWithoutHtmlTags(html : NSString) -> String {
        return html.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: NSMakeRange(0, html.length))
    }
    
    func showResults(text : NSString, searched : String, currentChapter: Int){
        let r = text.rangeOfString(searched)
        var rangeToCut : NSRange!
        //Cutting the string to show in the result
        if r.location > afterBefore / 2 {
            if r.location + r.length < text.length + afterBefore / 2 {
                rangeToCut = NSMakeRange(r.location - afterBefore / 2, r.length + afterBefore)
            } else {
                rangeToCut = NSMakeRange(r.location - afterBefore / 2, 50 + (text.length - r.location))
            }
        } else {
            if r.location + r.length < text.length + afterBefore / 2 {
                rangeToCut = NSMakeRange(0, r.length + afterBefore / 2)
            } else {
                rangeToCut = NSMakeRange(0, text.length)
            }
        }
        let result = text.substringWithRange(rangeToCut)
        print(result)
        print(currentChapter)
        if countResult < countLimit {
           // dispatch_after(0,1, dispatch_get_main_queue(), {
                //self.buildResultView(result, currentChapter: currentChapter)
            //})
            
        } else {
            if !stop {
                self.stop = true
                /*let alert = UIAlertController(title: "Search", message: "Too many results : 2000 results displayed", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)*/
            }
            
        }
        
        
        self.tabChapters.insertObject(currentChapter, atIndex: self.countResult)
        self.tabOccurences.insertObject(self.occurenceInChapter, atIndex: self.countResult)
        self.tabTexts.insertObject(result, atIndex: self.countResult)
        self.countResult += 1
        //For the next one, we cut the string
        let rToNext = NSMakeRange(rangeToCut.location + rangeToCut.length, text.length - (rangeToCut.location + rangeToCut.length))
        let restOfText = text.substringWithRange(rToNext)
        if restOfText.contains(searched){
            occurenceInChapter += 1
            showResults(restOfText, searched: searched, currentChapter: currentChapter)
        }
    }
    
    func buildResultView(resultText : String, currentChapter : Int) {
        let vResult = UIView(frame: CGRectMake(0.0, CGFloat(countResult) * (PERC_DarkGreenPukeHeight + 1), screenWidth, PERC_DarkGreenPukeHeight))
        let lTitle = UILabel()
        lTitle.text = (chaptersNames[currentChapter] as! String)
        //lTitle.text = "Chapter \(self.currentChapter - 3)"
        lTitle.font = titleFont
        lTitle.textColor = titleColor
        lTitle.sizeToFit()
        lTitle.frame.origin.y = PERC_YellowHeight
        lTitle.frame.origin.x = 2 * PERC_BlackWidth
        
        let lResult = UILabel()
        lResult.numberOfLines = 0
        lResult.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lResult.text = resultText
        lResult.frame.size.width = screenWidth - 2 * PERC_BlackWidth
        lResult.frame.size.height = PERC_DarkGreenPukeHeight - PERC_PurpleHeight
        lResult.frame.origin.x = PERC_BlackWidth
        lResult.frame.origin.y = PERC_YellowHeight + CGRectGetMaxY(lTitle.frame)
        
        let vBelowResult = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(vResult.frame), width: screenWidth, height: 1))
        vBelowResult.backgroundColor = UIColor.blackColor()
        vResult.addSubview(lTitle)
        vResult.addSubview(lResult)
        
        let bBack = UIButton(frame: vResult.frame)
        bBack.setTitle("\(self.countResult)", forState: UIControlState.Normal)
        bBack.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        bBack.addTarget(self, action: #selector(SearchBookController.resultClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        scResults.addSubview(vResult)
        scResults.addSubview(vBelowResult)
        scResults.addSubview(bBack)
        scResults.contentSize.height = CGRectGetMaxY(vResult.frame)
    }
    
    func buildResultViews(alert: UIAlertAction) {
        for i in 0  ..< min(500, tabChapters.count)  {
            let vResult = UIView(frame: CGRectMake(0.0, CGFloat(i) * (PERC_DarkGreenPukeHeight + 1), screenWidth, PERC_DarkGreenPukeHeight))
            let lTitle = UILabel()
            lTitle.text = (chaptersNames[tabChapters[i] as! Int] as! String)
            //lTitle.text = "Chapter \(self.currentChapter - 3)"
            lTitle.font = titleFont
            lTitle.textColor = titleColor
            lTitle.sizeToFit()
            lTitle.frame.origin.y = PERC_YellowHeight
            lTitle.frame.origin.x = 2 * PERC_BlackWidth
            
            let lResult = UILabel()
            lResult.numberOfLines = 0
            lResult.lineBreakMode = NSLineBreakMode.ByWordWrapping
            lResult.text = (tabTexts[i] as! String)
            lResult.frame.size.width = screenWidth - 2 * PERC_BlackWidth
            lResult.frame.size.height = PERC_DarkGreenPukeHeight - PERC_PurpleHeight
            lResult.frame.origin.x = PERC_BlackWidth
            lResult.frame.origin.y = PERC_YellowHeight + CGRectGetMaxY(lTitle.frame)
            
            let vBelowResult = UIView(frame: CGRect(x: 0, y: CGRectGetMaxY(vResult.frame), width: screenWidth, height: 1))
            vBelowResult.backgroundColor = UIColor.blackColor()
            vResult.addSubview(lTitle)
            vResult.addSubview(lResult)
            let bBack = UIButton(frame: vResult.frame)
            bBack.setTitle("\(i)", forState: UIControlState.Normal)
            bBack.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
            bBack.addTarget(self, action: #selector(SearchBookController.resultClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            scResults.addSubview(vResult)
            scResults.addSubview(vBelowResult)
            scResults.addSubview(bBack)
            scResults.contentSize.height = CGRectGetMaxY(vResult.frame)

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
    
    @IBAction func resultClicked(sender : UIButton) {
        let numberOfClickedResult = Int(sender.currentTitle!)
       // let numberOfClickedResult = sender.currentTitle?.toInt()
        let chapterClicked = tabChapters[numberOfClickedResult!] as! Int
        let occurenceClicked = tabOccurences[numberOfClickedResult!] as! Int
        dataDelegate?.searchedStringAndNumberOfClickedOccurenceInChapter(textEntered, occurence: occurenceClicked, chapter: chapterClicked)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func back(sender : UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func eraseText(sender : UIButton) {
        tfSearch.text = ""
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    override func didReceiveMemoryWarning() {
        dismissViewControllerAnimated(false, completion: nil)
    }
}

protocol DataBackDelegate {
    func searchedStringAndNumberOfClickedOccurenceInChapter(searched : String, occurence : Int, chapter : Int)
}
