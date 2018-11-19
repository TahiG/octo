//
//  ForgottenPasswordController.swift
//  Globe
//
//  Created by Charles Masson on 12/01/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class ForgottenPasswordController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var lTitle : UILabel!
    @IBOutlet var lOr : UILabel!
    @IBOutlet var tfEmail : UITextField!
    @IBOutlet var ivFacebook : UIImageView!
    @IBOutlet var bFacebook : UIButton!
    @IBOutlet var bReset : ButtonDoneContinue!
    
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        navigationItem.title = "Reset your password"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrow"), style: .Plain, target: self, action: #selector(ForgottenPasswordController.backToAppStart(_:)))
        
        lTitle.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_GreenHeight + PERC_YellowHeight + 64)
        lTitle.sizeToFit()
        
        tfEmail.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_YellowHeight + CGRectGetMaxY(lTitle.frame))
        tfEmail.frame.size = CGSize(width: AlmostFullWidth, height: PERC_TextFieldHeight)
        
        let color : UIColor = GrayPlaceholder
        tfEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: color])
        tfEmail.leftViewMode = UITextFieldViewMode.Always
        tfEmail.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        tfEmail.delegate = self
        
        lOr.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_GreenHeight + CGRectGetMaxY(tfEmail.frame))
        lOr.sizeToFit()
        
        ivFacebook.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_GreenHeight + CGRectGetMaxY(lOr.frame))
        ivFacebook.frame.size = CGSize(width: AlmostFullWidth, height: AlmostFullWidth / 6)
        
        bFacebook.frame = ivFacebook.frame
        
        bReset.frame.origin.y = screenHeight - bReset.frame.size.height - PERC_BottomMarginNextButton
        bReset.center.x = halfScreenWidth
    }
    
    @IBAction func facebookClicked(sender : UIButton) {
         self.addActivityIndicator()
         PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email", "user_friends"], block: {
         (user: PFUser?, error: NSError?) -> Void in
         if let user = user {
         if user.isNew {//User is new so he goes directly to the questionnaire
         self.removeActivityIndicator()
         print("User signed up and logged in through Facebook!")
         self.pushQuestionnaireFromBottom()
         } else {//User may already have answered the questionnaire
         if let didEnterPreferences = user.objectForKey("didEnterPreferences") as? Bool {
         if didEnterPreferences {
         self.removeActivityIndicator()
         print("user logged in via facebook, he is a returning user and has completed the questionnaire")
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyboard.instantiateViewControllerWithIdentifier("navcontroller")
         self.presentViewController(vc, animated: true, completion: nil)
         } else {
         self.removeActivityIndicator()
         print("User logged in via facebook, he is a returning user but did not complete the questionnaire")
         self.pushQuestionnaireFromBottom()
         }
         } else {
         self.removeActivityIndicator()
         print("User logged in via facebook, he is a returning user but did not complete the questionnaire")
         self.pushQuestionnaireFromBottom()
         }
         }
         } else {
         self.removeActivityIndicator()
         print("Uh oh. The user cancelled the Facebook login : ")
         print(error)
         }
         })
    }
    
    @IBAction func resetClicked(sender : UIButton) {
        self.view.endEditing(true)
        let mail = tfEmail.text
        if mail == nil {
            let alert = UIAlertController(title: "Reset", message: "Please enter your email adress", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            addActivityIndicator()
            PFUser.requestPasswordResetForEmailInBackground(mail!, block: {(success, error) -> Void in
                if error != nil {
                    self.removeActivityIndicator()
                    let alert = UIAlertController(title: "Reset", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.removeActivityIndicator()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("passwordresetted") as! PasswordResettedController
                    vc.mail = mail
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    @IBAction func backToAppStart(sender : UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func pushQuestionnaireFromBottom() {
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
        if activityIndicator != nil {
            activityIndicator.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
