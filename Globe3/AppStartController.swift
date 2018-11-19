//
//  AppStart.swift
//  Globe
//
//  Created by Charles Masson on 06/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//  If you have any question, any suggestion, contact me at charles.massonlenoir@gmail.com
//

import UIKit
import Parse

let screenWidth = UIScreen.mainScreen().bounds.width, screenHeight = UIScreen.mainScreen().bounds.height

let halfScreenWidth = screenWidth / 2, halfScreenHeight = screenHeight / 2

let PERC_RedWidth : CGFloat = 0.0067 * screenWidth
let PERC_OrangeWidth : CGFloat = 0.0213 * screenWidth
let PERC_YellowWidth : CGFloat = 0.048 * screenWidth
let PERC_BlackWidth : CGFloat = 0.048 * screenWidth
let PERC_GreenWidth : CGFloat = 0.08 * screenWidth
let PERC_PurpleWidth : CGFloat = 0.146667 * screenWidth
let PERC_DarkGreenWidth : CGFloat = 0.18133 * screenWidth
let PERC_BrownWidth : CGFloat = 0.152 * screenWidth
let PERC_BrownPukeWidth : CGFloat = 0.0733333 * screenWidth
let PERC_DarkRedWidth : CGFloat = 0.034667 * screenWidth
let PERC_RedHeight : CGFloat = 0.00375 * screenHeight
let PERC_OrangeHeight : CGFloat = 0.0112 * screenHeight
let PERC_BlueHeight : CGFloat = 0.02699 * screenHeight
let PERC_YellowHeight : CGFloat = 0.011994 * screenHeight
let PERC_GreenHeight : CGFloat = 0.045 * screenHeight
let PERC_PurpleHeight : CGFloat = 0.08246 * screenHeight
let PERC_DarkGreenHeight : CGFloat = 0.102 * screenHeight
let PERC_BrownHeight : CGFloat = 0.085457 * screenHeight
let PERC_OrangeVomiHeight : CGFloat = 0.80952 * screenHeight
let PERC_TealHeight : CGFloat = 0.0145 * screenHeight
let PERC_BeigeHeight : CGFloat = 0.09145 * screenHeight
let PERC_DarkTealHeight : CGFloat = 0.05247 * screenHeight
let PERC_LightBrownHeight : CGFloat = 0.14243 * screenHeight
let PERC_LightTealHeight : CGFloat = 0.135 * screenHeight
let PERC_DarkPurpleHeight : CGFloat = 0.033733 * screenHeight
//let PERC_DarkRedHeight : CGFloat = 0.01949 * screenHeight Dark red is square

let PERC_TextFieldHeight : CGFloat = 0.085457 * screenHeight
let PERC_TitlePurpleHeight : CGFloat = 0.04498 * screenHeight
let PERC_ButtonDoneContinue : CGFloat = 0.0727 * screenHeight
let secondColOriginY = halfScreenWidth + PERC_BlackWidth / 2
let borderColorNormal = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1).CGColor
let PERC_ButtonQuestionnaire : CGFloat = 0.05997 * screenHeight//0.09745 * screenHeight RE UPDATE January 2016 //0.05997 * screenHeight // UPDATE 20/11
let PERC_ButtonFont : CGFloat = 0.05997 * screenHeight
let PERC_CoteProfilePicture : CGFloat = 0.149925 * screenHeight
let PERC_CoteIconPicture : CGFloat = 0.02999 * screenHeight
let PERC_EditTextFieldHeight : CGFloat = 2.8 * PERC_BlueHeight
let PERC_SmallEditTextFieldHeight : CGFloat = 2.3 * PERC_BlueHeight
let PERC_FeedImageHeight : CGFloat = 0.855 * screenHeight
let PERC_CoverWidth : CGFloat = (screenWidth - 2 * PERC_BlackWidth - 4 * PERC_DarkRedWidth) / 3
let PERC_LibHeaderHeight : CGFloat = 0.1639344 * screenHeight
let PERC_LibCoverHeight : CGFloat = 0.19715 * screenHeight
let PERC_LibCoverWidth : CGFloat = (171 / 263) * PERC_LibCoverHeight
let PERC_MenuIndicatorWidth : CGFloat = 0.0213333 * screenWidth
let PERC_DarkRedHeight : CGFloat = 0.01949 * screenHeight
let PERC_DarkGreenPukeHeight : CGFloat = 0.2009 * screenHeight
let PERC_BottomMarginNextButton : CGFloat = 0.13343 * screenHeight
//Search page
let PERC_SearchWidth : CGFloat = 0.9333333 * screenWidth
let PERC_SearchMargin : CGFloat = 0.03333333 * screenWidth
let PERC_SearchHeight : CGFloat = 35
let PERC_ButtonBelowSearchHeight : CGFloat = 25
let PERC_SearchCoverHeight : CGFloat = 0.142435 * screenHeight
let PERC_SearchCoverWidth : CGFloat = 0.166667 * screenWidth
//Collection
let PERC_CollectionCoverWidth : CGFloat = 0.25333 * screenWidth
let PERC_CollectionCoverHeight : CGFloat = 0.22114 * screenHeight
//Reading
let PERC_ReadingPageHeight : CGFloat = 0.81859 * screenHeight
let PERC_ReadingPageHeightWithBanner : CGFloat = 0.7736 * screenHeight

let PERC_MenuWidth : CGFloat = 0.731 * screenWidth
let menuColor : UIColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 1)
let separatorWidth : CGFloat = PERC_MenuWidth - 2 * PERC_BlackWidth
let menuFont = UIFont(name: "MuseoSans-700", size: 17.5)

let AlmostFullWidth : CGFloat = screenWidth - 2 * PERC_BlackWidth
let HalfScreenButtonWidth : CGFloat = halfScreenWidth - (3 * PERC_BlackWidth / 2)

let MainBlueColor = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1.0)
let MainOrangeColor = UIColor(red: 1, green: 60 / 255, blue: 0, alpha: 1)
let GrayPlaceholder = UIColor(red: 175 / 255, green: 173 / 255, blue: 173 / 255, alpha: 1)

var mustLaunchEditProfile = false

class AppStartController : UIViewController {
    
    @IBOutlet var bSignUp : ButtonDoneContinue!
    @IBOutlet var bLogIn : ButtonDoneContinue!
    @IBOutlet var lTitle1 : UILabel!
    @IBOutlet var lTitle2 : UILabel!
    @IBOutlet var lBrand : UILabel!
    @IBOutlet var ivLogo : UIImageView!
    
    var screenWidth = UIScreen.mainScreen().bounds.width, screenHeight = UIScreen.mainScreen().bounds.height
    var activityIndicator : UIActivityIndicatorView!
    
    @IBAction func clickLogin(sender: ButtonDoneContinue){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("logincontroller")
        self.navigationController?.pushViewController(vc, animated: true)
        //self.presentViewController(vc, animated: true, completion: nil) UPDATE 10 january navbar for login & signup
    }
    
    @IBAction func clickSignup(sender: ButtonDoneContinue){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("signupcontroller")
        self.navigationController?.pushViewController(vc, animated: true)
        //self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        //Hide navbar for this one
        navigationController?.navigationBarHidden = true
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        //Background image
        let im = UIImage(named: "splash")
        let ivBackground = UIImageView(image: im)
        ivBackground.frame = self.view.frame
        ivBackground.contentMode = UIViewContentMode.ScaleAspectFill
        //ivBackground.contentMode = UIViewContentMode.Top
        self.view.insertSubview(ivBackground, atIndex: 0)
        
        bLogIn.frame.origin.y = screenHeight - bSignUp.frame.height - PERC_PurpleHeight
        bLogIn.frame.origin.x = PERC_BlackWidth
        bLogIn.backgroundColor = UIColor(red: 91/255, green: 89/255, blue: 89/255, alpha: 1)
        
        bSignUp.frame.origin.y = screenHeight - bSignUp.frame.height - PERC_PurpleHeight
        bSignUp.frame.origin.x = halfScreenWidth + PERC_BlackWidth / 2
        bSignUp.frame.size.width = HalfScreenButtonWidth
        
        lTitle1.frame.origin.y = PERC_GreenHeight
        lTitle1.center.x = halfScreenWidth
        
        ivLogo.contentMode = UIViewContentMode.ScaleAspectFill
        ivLogo.frame.origin.y = screenHeight * 0.192
        ivLogo.frame.size = CGSize(width: 0.22 / 0.632 * screenHeight, height: 0.22 * screenHeight)
        ivLogo.center.x = screenWidth / 2
        
        lBrand.sizeToFit()
        lBrand.frame.origin.x = screenWidth - (lBrand.frame.size.width + 10)
        lBrand.frame.origin.y = screenHeight - (lBrand.frame.size.height + 10)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Hide navbar for this one
        navigationController?.navigationBarHidden = true
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            addActivityIndicator()
            if let didEnterPreferences = currentUser?.objectForKey("didEnterPreferences") as? Bool {
                if didEnterPreferences {
                    if let didEnterCustomInfos = currentUser?.objectForKey("didEnterCustomInfos") as? Bool {
                        mustLaunchEditProfile = !didEnterCustomInfos
                    } else {
                        mustLaunchEditProfile = true
                    }
                    //All good, we go to feed page
                    removeActivityIndicator()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("navcontroller")
                    self.presentViewController(vc, animated: true, completion: nil)
                } else {
                    //User signed up but did not enter his prefereces
                    removeActivityIndicator()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("firstquestionnaire")
                    self.navigationController?.pushViewController(vc, animated: true)
                    //self.presentViewController(vc, animated: true, completion: nil)
                }
            } else {
                removeActivityIndicator()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("firstquestionnaire")
                self.navigationController?.pushViewController(vc, animated: true)
                //self.presentViewController(vc, animated: true, completion: nil)
            }
        } else {
            
            bLogIn.addTarget(self, action: #selector(AppStartController.clickLogin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            bLogIn.frame.origin.y = screenHeight - bSignUp.frame.height - PERC_PurpleHeight
            bLogIn.frame.origin.x = PERC_BlackWidth
            bLogIn.backgroundColor = UIColor(red: 91/255, green: 89/255, blue: 89/255, alpha: 1)
            
            bSignUp.frame.origin.y = screenHeight - bSignUp.frame.height - PERC_PurpleHeight
            bSignUp.frame.origin.x = halfScreenWidth + PERC_BlackWidth / 2
            bSignUp.frame.size.width = HalfScreenButtonWidth
            
            lTitle1.frame.origin.y = PERC_GreenHeight
            lTitle1.center.x = halfScreenWidth
            
            ivLogo.contentMode = UIViewContentMode.ScaleAspectFill
            ivLogo.frame.origin.y = screenHeight * 0.192
            ivLogo.frame.size = CGSize(width: 0.22 / 0.632 * screenHeight, height: 0.22 * screenHeight)
            ivLogo.center.x = screenWidth / 2
            
            lBrand.sizeToFit()
            lBrand.frame.origin.x = screenWidth - (lBrand.frame.size.width + 10)
            lBrand.frame.origin.y = screenHeight - (lBrand.frame.size.height + 10)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension NSString {
    func contains(find: String) -> Bool {
        return self.rangeOfString(find).location != NSNotFound
    }
}

extension String {
    
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }
    
    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).stringByDeletingLastPathComponent
        }
    }
    
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    
    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathExtension(ext)
    }
    
    func contains(find: String) -> Bool {
        return self.rangeOfString(find) != nil
    }
}

