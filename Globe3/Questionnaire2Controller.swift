//
//  QuestionnaireController.swift
//  Globe
//
//  Created by Charles Masson on 07/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//


import UIKit
import Parse


class Questionnaire2Controller : UIViewController {
    
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
    let arrUDToDelete = NSMutableArray()
    
    override func viewDidLoad() {
        
        navigationItem.title = "About You"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrowup"), style: .Plain, target: self, action: #selector(Questionnaire2Controller.backToPrevious(_:)))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(Questionnaire2Controller.backToPreviousPage(_:)))
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
        
        //All
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
        
        //RàZ
        var views = self.scButtons.subviews
        for i in 0  ..< views.count {
            if views[i].isKindOfClass(QuestionnaireButton){
                let txt = (views[i] as! QuestionnaireButton).currentTitle!
                if let _: AnyObject = ud.objectForKey("LIKE" + txt) {
                    self.ud.removeObjectForKey("LIKE" + txt)
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
            sender.selected = false
            ud.setBool(false, forKey: "LIKE\(getParseTitle(sender.currentTitle!))")
        } else {
            sender.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            sender.selected = true
            ud.setBool(true, forKey: "LIKE\(getParseTitle(sender.currentTitle!))")
            arrUDToDelete.addObject("LIKE\(getParseTitle(sender.currentTitle!))")
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
                        arr.addObject(self.getParseTitle(b.currentTitle!))
                    }
                }
            }
        }
        let user = PFUser.currentUser()
        if user != nil {
            user?.setObject(arr, forKey: "booklike")
            user?.saveInBackground()
        }
        sender.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        next()
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
    
    func next() {
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromTop
        navigationController!.view.layer.addAnimation(trans, forKey: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : Questionnaire3Controller = storyboard.instantiateViewControllerWithIdentifier("thirdquestionnaire") as! Questionnaire3Controller
        vc.arrUDToDelete = arrUDToDelete
        navigationController?.pushViewController(vc, animated: false)
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


