//
//  PasswordResettedController.swift
//  Globe
//
//  Created by Charles Masson on 12/01/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class PasswordResettedController : UIViewController, MFMailComposeViewControllerDelegate  {
    
    @IBOutlet var lText : UILabel!
    @IBOutlet var bResend : ButtonDoneContinue!
    @IBOutlet var bProblem : UIButton!
    @IBOutlet var bContact : UIButton!
    @IBOutlet var vContactUnder : UIView!
    
    var activityIndicator : UIActivityIndicatorView!
    
    var mail : String!
    
    override func viewDidLoad() {
        navigationItem.title = "Reset your password"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrow"), style: .Plain, target: self, action: #selector(PasswordResettedController.backToAppStart(_:)))
        
        lText.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_GreenHeight + PERC_YellowHeight + 64)
        lText.sizeToFit()
        lText.frame.size.width = AlmostFullWidth
        bResend.frame.origin.y = screenHeight - bResend.frame.size.height - PERC_BottomMarginNextButton
        bResend.center.x = halfScreenWidth
        
        bProblem.sizeToFit()
        bProblem.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_BlueHeight + CGRectGetMaxY(bResend.frame))
        bContact.sizeToFit()
        bContact.center.y = bProblem.center.y
        bContact.frame.origin.x = CGRectGetMaxX(bProblem.frame) + 10
        vContactUnder.frame = CGRect(x: bContact.frame.origin.x, y: CGRectGetMaxY(bProblem.frame) - 5, width: bContact.frame.size.width, height: 1)
    }
    
    @IBAction func resend(sender : ButtonDoneContinue) {
        if mail == nil {
            let alert = UIAlertController(title: "Reset", message: "There was an issue with your email adress. Please go back", preferredStyle: UIAlertControllerStyle.Alert)
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
                    let alert = UIAlertController(title: "Reset", message: "Please check your emails", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func backToAppStart(sender : UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func contactUs(sender : UIButton) {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setToRecipients(["info@getglobe.co"])
        mc.setSubject("")
        mc.setMessageBody("Hi Globe Team,\n\n", isHTML: false)
        self.presentViewController(mc, animated: true, completion: nil)
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
