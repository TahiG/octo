//
//  Questionnaire3Controller.swift
//  Globe
//
//  Created by Charles Masson on 07/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//


import UIKit
import Parse


class Questionnaire3Controller : UIViewController {
    
    @IBOutlet var lTitle1 : UILabel!
    @IBOutlet var lTitle2 : UILabel!
    @IBOutlet var bRomance : QuestionnaireButton!
    @IBOutlet var bMystery : QuestionnaireButton!
    @IBOutlet var bBiography : QuestionnaireButton!
    @IBOutlet var bAcademic : QuestionnaireButton!
    @IBOutlet var bPoetry : QuestionnaireButton!
    @IBOutlet var bAdventure : QuestionnaireButton!
    @IBOutlet var bSelfHelp : QuestionnaireButton!
    @IBOutlet var bSciFi : QuestionnaireButton!
    @IBOutlet var bClassic : QuestionnaireButton!
    @IBOutlet var bBiography2 : QuestionnaireButton!
    @IBOutlet var bTrade : QuestionnaireButton!
    @IBOutlet var bBusiness : QuestionnaireButton!
    @IBOutlet var bNext : ButtonDoneContinue!
    @IBOutlet var ivBottom : UIImageView!
    @IBOutlet var scButtons : UIScrollView!
    
    let ud = NSUserDefaults.standardUserDefaults()
    
    //All
    let borderColorNormal = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1).CGColor
    let borderColorSelected = UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1).CGColor
    
    var arrUDToDelete : NSMutableArray!
    
    override func viewDidLoad() {
        
        navigationItem.title = "About You"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrowup"), style: .Plain, target: self, action: #selector(Questionnaire3Controller.backToPrevious(_:)))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(Questionnaire3Controller.backToPreviousPage(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        lTitle1.sizeToFit()
        lTitle1.frame.size.width += 10
        lTitle1.frame.size.height = PERC_TitlePurpleHeight
        lTitle1.frame.origin.y = PERC_TitlePurpleHeight//64 + PERC_GreenHeight//PERC_DarkGreenHeight
        lTitle1.frame.origin.x = PERC_BlackWidth
        lTitle2.sizeToFit()
        lTitle2.frame.size.width += 10
        lTitle2.frame.size.height = PERC_TitlePurpleHeight
        lTitle2.frame.origin.y = CGRectGetMaxY(lTitle1.frame) + PERC_RedHeight
        lTitle2.frame.origin.x = PERC_BlackWidth
        
        scButtons.frame.size.width = screenWidth
        scButtons.frame.size.height = screenHeight
        scButtons.frame.origin.x = 0
        scButtons.frame.origin.y = 0//CGRectGetMaxY(lTitle2.frame) + PERC_PurpleHeight
        
        bAcademic.frame.origin.y = CGRectGetMaxY(lTitle2.frame) + PERC_PurpleHeight
        bBiography.frame.origin.y = CGRectGetMaxY(bAcademic.frame) + PERC_GreenHeight
        bBusiness.frame.origin.y = CGRectGetMaxY(bBiography.frame) + PERC_GreenHeight
        bClassic.frame.origin.y = CGRectGetMaxY(bBusiness.frame) + PERC_GreenHeight
        bBiography2.frame.origin.y = CGRectGetMaxY(bClassic.frame) + PERC_GreenHeight
        bAdventure.frame.origin.y = CGRectGetMaxY(bBiography2.frame) + PERC_GreenHeight
        bMystery.frame.origin.y = CGRectGetMaxY(bAdventure.frame) + PERC_GreenHeight
        bPoetry.frame.origin.y = CGRectGetMaxY(bMystery.frame) + PERC_GreenHeight
        bRomance.frame.origin.y = CGRectGetMaxY(bPoetry.frame) + PERC_GreenHeight
        bSciFi.frame.origin.y = CGRectGetMaxY(bRomance.frame) + PERC_GreenHeight
        bSelfHelp.frame.origin.y = CGRectGetMaxY(bSciFi.frame) + PERC_GreenHeight
        bTrade.frame.origin.y = CGRectGetMaxY(bSelfHelp.frame) + PERC_GreenHeight

        
        /*//First column
        bRomance.frame.size.width = HalfScreenButtonWidth
        bRomance.frame.size.height = PERC_ButtonQuestionnaire
        bRomance.frame.origin.y = 0
        bRomance.frame.origin.x = PERC_BlackWidth
        bRomance.layer.borderColor = borderColorNormal
        bMystery.frame.size.width = HalfScreenButtonWidth
        bMystery.frame.size.height = PERC_ButtonQuestionnaire
        bMystery.frame.origin.y = CGRectGetMaxY(bRomance.frame) + PERC_BlueHeight
        bMystery.frame.origin.x = PERC_BlackWidth
        bMystery.layer.borderColor = borderColorNormal
        bBiography.frame.size.width = HalfScreenButtonWidth
        bBiography.frame.size.height = PERC_ButtonQuestionnaire
        bBiography.frame.origin.y = CGRectGetMaxY(bMystery.frame) + PERC_BlueHeight
        bBiography.frame.origin.x = PERC_BlackWidth
        bBiography.layer.borderColor = borderColorNormal
        bAcademic.frame.size.width = HalfScreenButtonWidth
        bAcademic.frame.size.height = PERC_ButtonQuestionnaire
        bAcademic.frame.origin.y = CGRectGetMaxY(bBiography.frame) + PERC_BlueHeight
        bAcademic.frame.origin.x = PERC_BlackWidth
        bAcademic.layer.borderColor = borderColorNormal
        bPoetry.frame.size.width = HalfScreenButtonWidth
        bPoetry.frame.size.height = PERC_ButtonQuestionnaire
        bPoetry.frame.origin.y = CGRectGetMaxY(bAcademic.frame) + PERC_BlueHeight
        bPoetry.frame.origin.x = PERC_BlackWidth
        bPoetry.layer.borderColor = borderColorNormal
        bAdventure.frame.size.width = HalfScreenButtonWidth
        bAdventure.frame.size.height = PERC_ButtonQuestionnaire
        bAdventure.frame.origin.y = CGRectGetMaxY(bPoetry.frame) + PERC_BlueHeight
        bAdventure.frame.origin.x = PERC_BlackWidth
        bAdventure.layer.borderColor = borderColorNormal
        
        //Second column        
        bSelfHelp.frame.size.width = HalfScreenButtonWidth
        bSelfHelp.frame.size.height = PERC_ButtonQuestionnaire
        bSelfHelp.frame.origin.y = 0
        bSelfHelp.frame.origin.x = secondColOriginY
        bSelfHelp.layer.borderColor = borderColorNormal
        bSciFi.frame.size.width = HalfScreenButtonWidth
        bSciFi.frame.size.height = PERC_ButtonQuestionnaire
        bSciFi.frame.origin.y = CGRectGetMaxY(bSelfHelp.frame) + PERC_BlueHeight
        bSciFi.frame.origin.x = secondColOriginY
        bSciFi.layer.borderColor = borderColorNormal
        bClassic.frame.size.width = HalfScreenButtonWidth
        bClassic.frame.size.height = PERC_ButtonQuestionnaire
        bClassic.frame.origin.y = CGRectGetMaxY(bSciFi.frame) + PERC_BlueHeight
        bClassic.frame.origin.x = secondColOriginY
        bClassic.layer.borderColor = borderColorNormal
        bBiography2.frame.size.width = HalfScreenButtonWidth
        bBiography2.frame.size.height = PERC_ButtonQuestionnaire
        bBiography2.frame.origin.y = CGRectGetMaxY(bClassic.frame) + PERC_BlueHeight
        bBiography2.frame.origin.x = secondColOriginY
        bBiography2.layer.borderColor = borderColorNormal
        bTrade.frame.size.width = HalfScreenButtonWidth
        bTrade.frame.size.height = PERC_ButtonQuestionnaire
        bTrade.frame.origin.y = CGRectGetMaxY(bBiography2.frame) + PERC_BlueHeight
        bTrade.frame.origin.x = secondColOriginY
        bTrade.layer.borderColor = borderColorNormal
        bBusiness.frame.size.width = HalfScreenButtonWidth
        bBusiness.frame.size.height = PERC_ButtonQuestionnaire
        bBusiness.frame.origin.y = CGRectGetMaxY(bTrade.frame) + PERC_BlueHeight
        bBusiness.frame.origin.x = secondColOriginY
        bBusiness.layer.borderColor = borderColorNormal*/
        
       // scButtons.frame.size.height = PERC_OrangeVomiHeight - PERC_GreenHeight - scButtons.frame.origin.y
        //If cat have been previously liked, they are highlightened & no longer clickable
        var views = self.scButtons.subviews
        for i in 0  ..< views.count {
            if views[i].isKindOfClass(QuestionnaireButton){
                let txt = getParseTitle((views[i] as! QuestionnaireButton).currentTitle!)
                //print("on regarde \(txt)")
                if (ud.objectForKey("LIKE\(txt)") != nil) {
                    //print((vrai as! String) + "existe")
                    if ud.boolForKey("LIKE\(txt)") {
                        let b = views[i] as! UIButton
                        b.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)
                        b.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                        b.userInteractionEnabled = false
                    }
                }
            }
        }
        //If categories have been previously unliked, they are highlightened
        /*for(var i = 0 ; i < views.count ; i++){
        if views[i].isKindOfClass(UIButton){
        var txt = views[i].currentTitle!!
        if let vrai: AnyObject = ud.objectForKey("DISLIKE" + txt) {
        //print((vrai as! String) + "existe")
        if ud.boolForKey("DISLIKE" + txt) {
        var b = views[i] as! UIButton
        b.backgroundColor = UIColor(red: 208/255, green: 206/255, blue: 206/255, alpha: 1)
        b.setTitleColor(UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1), forState: UIControlState.Selected)
        b.selected = true
        b.layer.borderColor = borderColorSelected
        }
        }
        }
        }*/
        
        //RàZ
        for i in 0  ..< views.count {
            if views[i].isKindOfClass(QuestionnaireButton){
                let txt = (views[i] as! QuestionnaireButton).currentTitle!
                if (ud.objectForKey("DISLIKE" + txt) != nil) {
                    ud.removeObjectForKey("DISLIKE" + txt)
                }
            }
        }
        
        
        bNext.frame.origin.y = CGRectGetMaxY(bTrade.frame) + PERC_GreenHeight//PERC_OrangeVomiHeight
        bNext.center.x = self.view.center.x
        
        scButtons.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(bNext.frame) + PERC_BottomMarginNextButton)
        
        ivBottom.frame.size.height = PERC_TealHeight
        ivBottom.contentMode = UIViewContentMode.ScaleAspectFit
        ivBottom.frame.origin.y = CGRectGetMaxY(bNext.frame) + PERC_BlueHeight
        ivBottom.center.x = self.view.center.x
    }
    
    override func viewDidAppear(animated: Bool) {
        bNext.backgroundColor = MainOrangeColor
    }
    
    @IBAction func catButtonClicked(sender : QuestionnaireButton){
        
        if sender.selected {
            sender.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 0)
            sender.setTitleColor(UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1), forState: UIControlState.Normal)
            sender.layer.borderColor = borderColorNormal
            sender.selected = false
            
            ud.setBool(false, forKey: "DISLIKE\(sender.currentTitle!)")
        } else {
            sender.backgroundColor = UIColor(red: 208/255, green: 206/255, blue: 206/255, alpha: 1)
            sender.setTitleColor(UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1), forState: UIControlState.Selected)
            sender.layer.borderColor = borderColorSelected
            sender.selected = true
            
            ud.setBool(true, forKey: "DISLIKE\(sender.currentTitle!)")
            arrUDToDelete.addObject("DISLIKE\(sender.currentTitle!)")
        }
    }
    
    @IBAction func nextClicked(sender : UIButton){
        
        let arr: NSMutableArray = []
        var views = self.scButtons.subviews
        for i in 0  ..< views.count {
            if views[i].isKindOfClass(QuestionnaireButton){
                //print(views[i].currentTitle!!)
                if !views[i].isKindOfClass(ButtonDoneContinue) {
                    let b = views[i] as! UIButton
                    if b.selected {
                        arr.addObject(getParseTitle(b.currentTitle!))
                    }
                }
            }
        }
        let user = PFUser.currentUser()
        if user != nil {
            user?.setObject(arr, forKey: "bookhate")
            user?.saveInBackground()
        }
        
        
        sender.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        next()
    }
    
    func next() {
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromTop
        navigationController!.view.layer.addAnimation(trans, forKey: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("fourthquestionnaire") as! Questionnaire4Controller
        vc.arrUDToDelete = arrUDToDelete
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func backToPreviousPage(sender: UIGestureRecognizer){
        backToPrevious(UIBarButtonItem())
    }
    
    @IBAction func backToPrevious(sender : UIBarButtonItem){
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromBottom
        navigationController!.view.layer.addAnimation(trans, forKey: nil)
        navigationController?.popViewControllerAnimated(false)
    }
    
    func getParseTitle(buttonTitle : String) -> String {
        if buttonTitle == "Business & Startups" {
            return "Business"
        } else if buttonTitle == "Biographies & Memoirs" {
            return "Biography"
        } else if buttonTitle == "Fantasy & Adventure" {
            return "Adventure"
        } else if buttonTitle == "Self-Help & Spirituality" {
            return "Self-Help"
        } else if buttonTitle == "Short Stories & Poetry" {
            return "Poetry"
        } else if buttonTitle == "Academic & Reference" {
            return "Academic"
        } else {
            return buttonTitle
        }
    }
    
    /*override func prefersStatusBarHidden() -> Bool {
    return true
    }*/
}