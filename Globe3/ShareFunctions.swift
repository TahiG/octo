//
//  ShareFunctions.swift
//  Globe
//
//  Created by Charles Masson on 16/02/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import Foundation
import Social
import MessageUI

class ShareFunctions {
    class func fbShareFromParent(controller : UIViewController, bookTitle : String) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let cvc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            cvc.setInitialText("I just finished \(bookTitle) on globe! Check it out!")
            controller.presentViewController(cvc, animated: true, completion: nil)
        }
    }
    
    class func twittShareFromParent(controller : UIViewController, bookTitle : String) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let cvc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            cvc.setInitialText("I just finished \(bookTitle) on globe! Check it out! @go_globe")
            controller.presentViewController(cvc, animated: true, completion: nil)
        }
    }
}
