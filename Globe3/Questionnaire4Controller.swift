//
//  Questionnaire4Controller.swift
//  Globe
//
//  Created by Charles Masson on 07/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse

class Questionnaire4Controller : UIViewController {
    
    @IBOutlet var lTitle1 : UILabel!
    @IBOutlet var lTitle2 : UILabel!
    @IBOutlet var bReadMore : UIButton!
    @IBOutlet var bResearch : UIButton!
    @IBOutlet var bExplore : UIButton!
    @IBOutlet var bNotSure : UIButton!
    @IBOutlet var bDone : ButtonDoneContinue!
    @IBOutlet var ivBottom : UIImageView!
    
    let ud = NSUserDefaults.standardUserDefaults()
    var selectedChoice : String!
    
    var arrUDToDelete : NSMutableArray!
    
    override func viewDidLoad() {
        
        navigationItem.title = "About You"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrowup"), style: .Plain, target: self, action: #selector(backToPrevious))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(backToPreviousPage))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        lTitle1.sizeToFit()
        lTitle1.frame.size.width += 10
        lTitle1.frame.size.height = PERC_TitlePurpleHeight
        lTitle1.frame.origin.y = 64 + PERC_GreenHeight//PERC_DarkGreenHeight
        lTitle1.frame.origin.x = PERC_BlackWidth
        lTitle2.sizeToFit()
        lTitle2.frame.size.width += 10
        lTitle2.frame.size.height = PERC_TitlePurpleHeight
        lTitle2.frame.origin.y = CGRectGetMaxY(lTitle1.frame) + PERC_RedHeight
        lTitle2.frame.origin.x = PERC_BlackWidth
        
        let borderColorNormal = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1).CGColor
        let buttonsWidth = screenWidth - 2 * PERC_BlackWidth
        //First column
        bReadMore.frame.size.width = buttonsWidth
        bReadMore.frame.size.height = PERC_ButtonQuestionnaire
        bReadMore.frame.origin.y = CGRectGetMaxY(lTitle2.frame) + PERC_PurpleHeight
        bReadMore.frame.origin.x = PERC_BlackWidth
        bReadMore.titleEdgeInsets = UIEdgeInsets(top: 0, left: PERC_BlackWidth / 1.5, bottom: 0, right: 0)
        bReadMore.layer.borderColor = borderColorNormal
        bResearch.frame.size.width = buttonsWidth
        bResearch.frame.size.height = PERC_ButtonQuestionnaire
        bResearch.frame.origin.y = CGRectGetMaxY(bReadMore.frame) + PERC_BlueHeight
        bResearch.frame.origin.x = PERC_BlackWidth
        bResearch.titleEdgeInsets = UIEdgeInsets(top: 0, left: PERC_BlackWidth / 1.5, bottom: 0, right: 0)
        bResearch.layer.borderColor = borderColorNormal
        bExplore.frame.size.width = buttonsWidth
        bExplore.frame.size.height = PERC_ButtonQuestionnaire
        bExplore.frame.origin.y = CGRectGetMaxY(bResearch.frame) + PERC_BlueHeight
        bExplore.frame.origin.x = PERC_BlackWidth
        bExplore.titleEdgeInsets = UIEdgeInsets(top: 0, left: PERC_BlackWidth / 1.5, bottom: 0, right: 0)
        bExplore.layer.borderColor = borderColorNormal
        bNotSure.frame.size.width = buttonsWidth
        bNotSure.frame.size.height = PERC_ButtonQuestionnaire
        bNotSure.frame.origin.y = CGRectGetMaxY(bExplore.frame) + PERC_BlueHeight
        bNotSure.frame.origin.x = PERC_BlackWidth
        bNotSure.titleEdgeInsets = UIEdgeInsets(top: 0, left: PERC_BlackWidth / 1.5, bottom: 0, right: 0)
        bNotSure.layer.borderColor = borderColorNormal
        
        
        bDone.frame.origin.y = screenHeight - bDone.frame.size.height - PERC_BottomMarginNextButton//PERC_OrangeVomiHeight
        bDone.center.x = self.view.center.x
        
        ivBottom.frame.size.height = PERC_TealHeight
        ivBottom.contentMode = UIViewContentMode.ScaleAspectFit
        ivBottom.frame.origin.y = CGRectGetMaxY(bDone.frame) + PERC_BlueHeight
        ivBottom.center.x = self.view.center.x
    }
    
    override func viewDidAppear(animated: Bool) {
        bDone.backgroundColor = MainOrangeColor
    }
    
    @IBAction func catButtonClicked(sender : UIButton){
        if sender.selected {
            sender.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 0)
            sender.setTitleColor(UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1), forState: UIControlState.Normal)
            sender.selected = false
        } else {
            var views = self.view.subviews
            for i in 0  ..< 5 /*obj : AnyObject in views */{
                if views[i].isKindOfClass(UIButton){
                    (views[i] as! UIButton).selected = false
                    (views[i] as! UIButton).backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 0)
                    (views[i] as! UIButton).setTitleColor(UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1), forState: UIControlState.Normal)
                }
            }
            sender.selected = true
            sender.backgroundColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1)
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            self.selectedChoice = sender.currentTitle!
        }
    }
    
    @IBAction func doneClicked(sender : UIButton){
        if selectedChoice == nil {
            let alert = UIAlertController(title: "Questionnaire", message: "Please choose an item", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let user = PFUser.currentUser()
            
            user?.setObject(self.selectedChoice, forKey: "readinggoal")
            user?.setObject(true, forKey: "didEnterPreferences")
            user?.saveInBackground()
            sender.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
            //Remove the userdefaults entered before
            if arrUDToDelete != nil && arrUDToDelete.count != 0 {
                let ud = NSUserDefaults.standardUserDefaults()
                for s in arrUDToDelete {
                    ud.removeObjectForKey(s as! String)
                }
                ud.synchronize()
            }
            //Load real app
            next()
        }
        
    }
    
    func next() {
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromTop
        navigationController!.view.layer.addAnimation(trans, forKey: nil)
        
        mustLaunchEditProfile = false
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setBool(false, forKey: "mustLaunchEditProfile")
        ud.synchronize()
        print("must launch edit is \(mustLaunchEditProfile)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("navcontroller")
        navigationController?.presentViewController(vc, animated: false, completion: nil)
        navigationController?.popToRootViewControllerAnimated(false)
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
    
    /*override func prefersStatusBarHidden() -> Bool {
    return true
    }*/
}