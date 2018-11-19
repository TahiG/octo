//
//  LogInController.swift
//  Globe
//
//  Created by Charles Masson on 06/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import Parse
import UIKit
//import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class LogInController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var lSignIn : UILabel!
    @IBOutlet var lOrBy : UILabel!
    @IBOutlet var tfName : UITextField!
    @IBOutlet var tfPass : UITextField!
    @IBOutlet var ivFBLogin : UIImageView!
    @IBOutlet var bFBLogin : UIButton!
    @IBOutlet var bLogin : ButtonDoneContinue!
    @IBOutlet var bForgottenPassword : UIButton!
    
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        navigationItem.title = "Log In"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrow"), style: .Plain, target: self, action: #selector(LogInController.backToAppStart(_:)))
        navigationController?.navigationBarHidden = false
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(LogInController.backToAppStartBySwipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        lSignIn.sizeToFit()
        lSignIn.frame.size.width += 10
        lSignIn.frame.size.height = 0//PERC_TitlePurpleHeight
        lSignIn.frame.origin.y = 64 + PERC_GreenHeight//PERC_DarkGreenHeight
        lSignIn.frame.origin.x = PERC_BlackWidth
        
        ivFBLogin.frame.size.width = screenWidth - 2 * PERC_BlackWidth
        ivFBLogin.frame.size.height = ivFBLogin.frame.size.width / 6
        ivFBLogin.frame.origin.x = PERC_BlackWidth
        ivFBLogin.frame.origin.y = CGRectGetMaxY(lSignIn.frame) + PERC_GreenHeight
        bFBLogin.frame.size.width = screenWidth - 2 * PERC_BlackWidth
        bFBLogin.frame.size.height = ivFBLogin.frame.size.width / 6
        bFBLogin.frame.origin.x = PERC_BlackWidth
        bFBLogin.frame.origin.y = CGRectGetMaxY(lSignIn.frame) + PERC_GreenHeight
        
        //Blue placeholder
        let color : UIColor = GrayPlaceholder//UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
        tfName.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: color])
        tfPass.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: color])
        
        //Placing form
        let textFieldsWidth = screenWidth - PERC_BlackWidth * 2
        let vSpace = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        let vSpaceb = UIView(frame: CGRect(x: 0.0, y: 0.0, width: PERC_BlackWidth, height: 1.0))
        
        tfName.frame.origin.x = PERC_BlackWidth
        tfName.frame.origin.y = CGRectGetMaxY(bFBLogin.frame) + PERC_PurpleHeight
        tfName.frame.size.width = textFieldsWidth
        tfName.frame.size.height = PERC_TextFieldHeight
        tfName.leftViewMode = UITextFieldViewMode.Always
        tfName.leftView = vSpace
        tfName.delegate = self
        tfPass.frame.origin.x = PERC_BlackWidth
        tfPass.frame.origin.y = CGRectGetMaxY(tfName.frame) + PERC_OrangeHeight
        tfPass.frame.size.width = textFieldsWidth
        tfPass.frame.size.height = PERC_TextFieldHeight
        tfPass.leftViewMode = UITextFieldViewMode.Always
        tfPass.leftView = vSpaceb
        tfPass.delegate = self
        
        bForgottenPassword.frame.origin = CGPoint(x: 3 * PERC_BlackWidth, y: CGRectGetMaxY(tfPass.frame))
        bForgottenPassword.sizeToFit()
        
        lOrBy.frame.origin.x = PERC_BlackWidth
        lOrBy.frame.origin.y = CGRectGetMinY(tfName.frame) - lOrBy.frame.height - PERC_OrangeHeight
        
        bLogin.frame.origin.y = screenHeight - bLogin.frame.size.height - PERC_BottomMarginNextButton//PERC_OrangeVomiHeight
        bLogin.center.x = halfScreenWidth
        
    }
    
    @IBAction func forgottenPassClicked(sender : UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("forgottenpassword")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backToAppStart(sender : UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func loginReleased(sender : UIButton){
        sender.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1)
    }
    
    @IBAction func loginClicked(sender : UIButton){
        let name = tfName.text, password = tfPass.text
        if name!.isEmpty || password!.isEmpty {
            let alert = UIAlertController(title: "Log In", message: "You did not fill each field", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            addActivityIndicator()
            PFUser.logInWithUsernameInBackground(name!, password:password!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    if let didEnterPreferences = user!.objectForKey("didEnterPreferences") as? Bool {
                        if didEnterPreferences {
                            self.removeActivityIndicator()
                            print("user logged in and has completed the questionnaire")
                            if let didEnterCustomInfos = user?.objectForKey("didEnterCustomInfos") as? Bool {
                                mustLaunchEditProfile = !didEnterCustomInfos
                            } else {
                                mustLaunchEditProfile = true
                            }
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("navcontroller")
                            self.presentViewController(vc, animated: true, completion: nil)
                        } else {
                            self.removeActivityIndicator()
                            print("User logged in but did not complete the questionnaire")
                            self.pushQuestionnaireFromBottom()
                            //self.presentViewController(vc, animated: true, completion: nil)
                        }
                    } else {
                        self.removeActivityIndicator()
                        print("User logged in but did not complete the questionnaire")
                        self.pushQuestionnaireFromBottom()
                        //self.presentViewController(vc, animated: true, completion: nil)
                    }
                    
                    print("login successfull")
                    //self.pushQuestionnaireFromBottom()
                    self.removeActivityIndicator()
                    //self.presentViewController(vc, animated: true, completion: nil)
                } else {
                    self.removeActivityIndicator()
                    let alert = UIAlertController(title: "Log in", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                    print(error)
                }
            }
        }
    }
    
    @IBAction func fbloginClicked(sender : UIButton){

        self.addActivityIndicator()


        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email", "user_friends"], block: {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    //User is new so he goes directly to the questionnaire
                    self.removeActivityIndicator()
                    print("User signed up and logged in through Facebook!")
                    self.pushQuestionnaireFromBottom()
                } else {
                    //User may already have answered the questionnaire
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
                            //self.presentViewController(vc, animated: true, completion: nil)
                        }
                    } else {
                        self.removeActivityIndicator()
                        print("User logged in via facebook, he is a returning user but did not complete the questionnaire")
                        self.pushQuestionnaireFromBottom()
                        //self.presentViewController(vc, animated: true, completion: nil)
                    }
                }
            } else {
                self.removeActivityIndicator()
                print("Uh oh. The user cancelled the Facebook login : ")
                print(error)
            }
        })

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

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(tf: UITextField) -> Bool {
        if tf == self.tfName {
            tfPass.becomeFirstResponder()
        } else {
            tf.resignFirstResponder()
        }
        return true
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
}
