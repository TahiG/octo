//
//  SignUp.swift
//  Globe
//
//  Created by Charles Masson on 04/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import Parse
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4


class SignUpController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tfFirstName : UITextField!
    @IBOutlet var tfName : UITextField!
    @IBOutlet var tfMail : UITextField!
    @IBOutlet var tfPass : UITextField!
    @IBOutlet var tfConfirmPass : UITextField!
    @IBOutlet var lCreate : UILabel!
    @IBOutlet var lOrBy : UILabel!
    @IBOutlet var ivFBSignup : UIImageView!
    @IBOutlet var bFBSignup : UIButton!
    @IBOutlet var bSignUp : ButtonDoneContinue!
    
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        navigationItem.title = "Sign Up"        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrow"), style: .Plain, target: self, action: #selector(backToAppStart))
        navigationController?.navigationBarHidden = false
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backToAppStartBySwipe))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        lCreate.sizeToFit()
        lCreate.frame.size.width += 12 //12 px margin each side
        lCreate.frame.size.height = 0//PERC_TitlePurpleHeight
        lCreate.frame.origin.y = 64 + PERC_GreenHeight//PERC_DarkGreenHeight
        lCreate.frame.origin.x = PERC_BlackWidth
        
        ivFBSignup.frame.size.width = screenWidth - 2 * PERC_BlackWidth
        ivFBSignup.frame.size.height = ivFBSignup.frame.size.width / 6
        ivFBSignup.frame.origin.x = PERC_BlackWidth
        ivFBSignup.frame.origin.y = CGRectGetMaxY(lCreate.frame) + PERC_GreenHeight
        bFBSignup.frame.size.width = ivFBSignup.frame.size.width
        bFBSignup.frame.size.height = ivFBSignup.frame.size.height
        bFBSignup.frame.origin.x = PERC_BlackWidth
        bFBSignup.frame.origin.y = CGRectGetMaxY(lCreate.frame) + PERC_GreenHeight
        
        
        
        //Blue placeholder
        let color : UIColor = GrayPlaceholder//UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
        tfFirstName.attributedPlaceholder = NSAttributedString(string: "First name", attributes: [NSForegroundColorAttributeName: color])
        tfName.attributedPlaceholder = NSAttributedString(string: "Surname", attributes: [NSForegroundColorAttributeName: color])
        tfMail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: color])
        tfPass.attributedPlaceholder = NSAttributedString(string: "Create Password", attributes: [NSForegroundColorAttributeName: color])
        tfConfirmPass.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: color])
        
        //Placing form
        let textFieldsWidth = screenWidth - PERC_BlackWidth * 2
        let vSpace = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        let vSpacea = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        let vSpaceb = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        let vSpacec = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        let vSpaced = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        
        
        tfFirstName.frame.origin.x = PERC_BlackWidth
        tfFirstName.frame.origin.y = CGRectGetMaxY(bFBSignup.frame) + PERC_PurpleHeight
        tfFirstName.frame.size.width = textFieldsWidth / 2 - PERC_BlackWidth / 2
        tfFirstName.frame.size.height = PERC_TextFieldHeight
        tfFirstName.leftViewMode = UITextFieldViewMode.Always
        tfFirstName.leftView = vSpace
        tfFirstName.delegate = self
        tfName.frame.origin.x = halfScreenWidth + PERC_BlackWidth / 2
        tfName.frame.origin.y = CGRectGetMaxY(bFBSignup.frame) + PERC_PurpleHeight
        tfName.frame.size.width = textFieldsWidth / 2 - PERC_BlackWidth / 2
        tfName.frame.size.height = PERC_TextFieldHeight
        tfName.leftViewMode = UITextFieldViewMode.Always
        tfName.leftView = vSpacea
        tfName.delegate = self
        tfMail.frame.origin.x = PERC_BlackWidth
        tfMail.frame.origin.y = CGRectGetMaxY(tfName.frame) + PERC_OrangeHeight
        tfMail.frame.size.width = textFieldsWidth
        tfMail.frame.size.height = PERC_TextFieldHeight
        tfMail.leftViewMode = UITextFieldViewMode.Always
        tfMail.leftView = vSpaceb
        tfMail.delegate = self
        tfPass.frame.origin.x = PERC_BlackWidth
        tfPass.frame.origin.y = CGRectGetMaxY(tfMail.frame) + PERC_OrangeHeight
        tfPass.frame.size.width = textFieldsWidth
        tfPass.frame.size.height = PERC_TextFieldHeight
        tfPass.leftViewMode = UITextFieldViewMode.Always
        tfPass.leftView = vSpacec
        tfPass.delegate = self
        tfConfirmPass.frame.origin.x = PERC_BlackWidth
        tfConfirmPass.frame.origin.y = CGRectGetMaxY(tfPass.frame) + PERC_OrangeHeight
        tfConfirmPass.frame.size.width = textFieldsWidth
        tfConfirmPass.frame.size.height = PERC_TextFieldHeight
        tfConfirmPass.leftViewMode = UITextFieldViewMode.Always
        tfConfirmPass.leftView = vSpaced
        tfConfirmPass.delegate = self
        
        lOrBy.frame.origin.x = PERC_BlackWidth
        lOrBy.frame.origin.y = CGRectGetMinY(tfName.frame) - lOrBy.frame.height - PERC_OrangeHeight
        
        bSignUp.frame.origin.y = screenHeight - bSignUp.frame.size.height - PERC_BottomMarginNextButton//CGRectGetMaxY(tfConfirmPass.frame) + PERC_PurpleHeight
        bSignUp.center.x = halfScreenWidth
    }
    
    @IBAction func backToAppStart(sender : UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    @IBAction func signUpReleased(sender : UIButton){
        sender.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1)
    }
    
    
    @IBAction func signUpClicked(sender: UIButton!){
        sender.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        if tfFirstName.text != "" && tfName.text != "" && tfMail.text != "" && tfPass.text != "" && tfConfirmPass != "" {
            let user = PFUser()
            user.username = tfMail.text
            user.email = tfMail.text
            user.password = tfPass.text
            self.addActivityIndicator()
            user.signUpInBackgroundWithBlock { (success, error) -> Void in
                self.removeActivityIndicator()
                if error == nil {
                    if success {
                        user.setObject(self.tfFirstName.text!, forKey: "firstname")
                        user.setObject(self.tfName.text!, forKey: "lastname")
                        user.saveInBackground()
                        print("success")
                        self.pushQuestionnaireFromBottom()
                        //self.presentViewController(vc, animated: true, completion: nil)
                    } else {
                        print(error)
                    }
                } else {
                    let alert = UIAlertController(title: "Sign Up", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    print(error)
                }
            }
        } else {
            let alert = UIAlertController(title: "Sign Up", message: "You did not fill each field", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func facebookSignUpClicked(sender: UIButton!){

         addActivityIndicator()
         PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email", "user_friends"]) {
             (user: PFUser?, error: NSError?) -> Void in
             if let user = user {
                 if user.isNew {
                    //User never connected to this app with these credentials
                    user.setObject(false, forKey: "didEnterPreferences")
                    user.saveInBackground()//no need to see any error
                    self.removeActivityIndicator()
                    self.pushQuestionnaireFromBottom()
                    //self.presentViewController(vc, animated: true, completion: nil)
                 } else {
                    //Returning user, we check if he entered his preferences
                    if let didEnterPreferences = PFUser.currentUser()!.objectForKey("didEnterPreferences") as? Bool {
                        if didEnterPreferences {
                            print("current user did enter his prefs")
                            self.removeActivityIndicator()
                            //All good


                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("navcontroller")
                            if let nav = self.navigationController {
                                //nav.pushViewController(vc, animated: true)
                                nav.presentViewController(vc, animated: true, completion: nil)
                            }
                            
                        } else {
                            print("current user did not enter his prefs")
                            self.removeActivityIndicator()
                            //Go questionnaire
                            self.pushQuestionnaireFromBottom()
                            //self.presentViewController(vc, animated: true, completion: nil)
                        }
                    }
                 }
             } else {
                print("Uh oh. The user cancelled the Facebook login.")
                self.removeActivityIndicator()
             }
         }
    }

    func backToAppStartBySwipe(sender: UIGestureRecognizer){
        /*UIView.animateWithDuration(0.5, animations: {
            self.view.frame.origin.x = screenWidth
            }, completion: {
                (value: Bool) in
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        })*/
        navigationController?.popToRootViewControllerAnimated(true)
        UIView.animateWithDuration(0.5, animations: {
            self.navigationController?.navigationBar.frame.origin.y = -64
        })
    }
    
    //TF UX
    func textFieldDidBeginEditing(tf: UITextField) {
        tfGoesUp(tf)
    }
    
    func textFieldDidEndEditing(tf: UITextField) {
        tfGoesDown(tf)
    }
    
    func tfGoesUp(tf: UITextField){
        UIView.beginAnimations("tfGoesUp", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = CGRectOffset(self.view.frame, 0, -80)
        UIView.commitAnimations()
        delay(0.3){
            self.lCreate.hidden = true
        }
    }
    
    func tfGoesDown(tf: UITextField){
        self.lCreate.hidden = false
        UIView.beginAnimations("tfGoesDown", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(0.3)
        self.view.frame = CGRectOffset(self.view.frame, 0, 80)
        UIView.commitAnimations()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(tf: UITextField) -> Bool {
        if tf == tfFirstName {
            tfName.becomeFirstResponder()
        } else if tf == self.tfName {
            self.tfMail.becomeFirstResponder()
        } else if tf == self.tfMail {
            self.tfPass.becomeFirstResponder()
        } else if tf == self.tfPass {
            self.tfConfirmPass.becomeFirstResponder()
        } else {
            tf.resignFirstResponder()
        }
        return true
    }
    
    func pushQuestionnaireFromBottom() {
        mustLaunchEditProfile = false
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromTop
        navigationController!.view.layer.addAnimation(trans, forKey: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("firstquestionnaire")
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
