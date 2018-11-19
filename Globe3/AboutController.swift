//
//  AboutController.swift
//  Globe3
//
//  Created by Charles Masson on 27/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import MessageUI
import Parse

class AboutController : UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var scMain : UIScrollView!
    @IBOutlet var bMission : UIButton!
    @IBOutlet var lMission : UILabel!
    @IBOutlet var vMission : UIView!
    @IBOutlet var bHow : UIButton!
    @IBOutlet var lHow : UILabel!
    @IBOutlet var vHow : UIView!
    @IBOutlet var bTerms : UIButton!
    @IBOutlet var lTerms : UILabel!
    @IBOutlet var vTerms : UIView!
    @IBOutlet var bPolicy : UIButton!
    @IBOutlet var lPolicy : UILabel!
    @IBOutlet var vPolicy : UIView!
    @IBOutlet var bContact : UIButton!
    @IBOutlet var lContact : UILabel!
    @IBOutlet var vContact : UIView!
    @IBOutlet var vLabelMission : UIView!
    @IBOutlet var vLabelHow : UIView!
    
    var missionShowed = false
    var howShowed = false
    /*var termsShowed = false
     var policyShowed = false
     var contactShowed = false*/
    
    var usernameLoaded = false
    var namesLoaded = false
    var fromEmail = ""
    var fromUser = ""
    
    var firstname = ""
    var lastname = ""
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        
        let user = PFUser.currentUser()
        //Mail
        if let uMail = user?.objectForKey("email") as? String {
            self.fromEmail = uMail
        } else {
            self.fromEmail = ""
        }
        if let uName = user?.objectForKey("username") as? String {
            self.fromUser = uName
            usernameLoaded = true
        } else {
            self.fromUser = ""
        }
        if let uFName = user?.objectForKey("firstname") as? String {
            self.firstname = uFName
        } else {
            self.firstname = ""
        }
        if let uLName = user?.objectForKey("lastname") as? String {
            self.lastname = uLName
            namesLoaded = true
        } else {
            self.lastname = ""
        }
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        
        let onePxHeight = 1/UIScreen.mainScreen().scale
        
        bMission.frame.origin.x = PERC_BlackWidth
        bMission.frame.origin.y = PERC_BlueHeight
        bMission.sizeToFit()
        
        let txtMission = "The more we read, the brighter our future becomes. At globe we aim to turn that brightness up to its full potential by promoting greater readership and spreading the magic of the written word. \n\nFrom bestselling novels to iconic memoirs, to groundbreaking journals and soul-stirring poetry, we believe that the stories we read can truly enrich our lives for the better."
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.Justified
        paraStyle.lineSpacing = 1.5
        let asMission = NSAttributedString(string: txtMission, attributes: [NSParagraphStyleAttributeName: paraStyle,
            NSBaselineOffsetAttributeName: NSNumber(float: 0)])
        
        lMission.attributedText = asMission
        lMission.sizeToFit()
        lMission.frame.size.width = AlmostFullWidth
        lMission.frame.origin.y = 0.0
        lMission.frame.origin.x = 0.0
        vLabelMission.frame.origin.x = PERC_BlackWidth
        vLabelMission.frame.size.width = AlmostFullWidth
        vLabelMission.frame.origin.y = CGRectGetMaxY(bMission.frame) + PERC_RedHeight
        vLabelMission.frame.size.height = lMission.frame.size.height
        
        
        vMission.frame.size.width = AlmostFullWidth
        vMission.frame.size.height = onePxHeight
        vMission.frame.origin.x = PERC_BlackWidth
        vMission.frame.origin.y = CGRectGetMaxY(vLabelMission.frame) + PERC_BlueHeight
        
        bHow.frame.origin.x = PERC_BlackWidth
        bHow.frame.origin.y = CGRectGetMaxY(vMission.frame) + PERC_BlueHeight
        bHow.sizeToFit()
        
        let txtHow = "Reading should be a right, not a privilege. If you agree then you’re in good company. At globe we think everyone should have access to great stories – stories that make us laugh, make us cry, break our hearts and make us fall in love all over again. But we also believe authors should be paid fairly for their work.\n\nWe’re building a platform that works for everyone – one where you can support your favourite authors simply by reading their work. The more books you read, the more support they receive, helping them to write more of what you like. It’s as simple as that.\n\nAs we set out on our mission, remember to regularly check in on us for new titles."
        /*let txtHow = "You walk into a Library, you take a book off the shelf, and you start reading.\n\n" +
            
            "That’s the simplicity of globe, giving you open access to all titles on our reading app. Whether classic or contemporary, fiction or non-fiction, thriller or sci-fi, you can stop trying to decide which one to pick and simply read them all.\n\n" +
            
            "1. Sign up for an account.\n" +
            "2. Browse our Library or choose from our curated collections on the globe Feed. You can even Search for a book.\n" +
            "3. Save to your private Wish List or start reading straight away.\n\n" +
            
            "That’s it!\n\n" +
            
        "There are no costs, no fees and no monthly subscriptions, just great books waiting to be read by you."*/
        
        let asHow = NSAttributedString(string: txtHow, attributes: [NSParagraphStyleAttributeName: paraStyle,
            NSBaselineOffsetAttributeName: NSNumber(float: 0)])
        
        lHow.attributedText = asHow
        lHow.sizeToFit()
        lHow.frame.size.width = AlmostFullWidth
        lHow.frame.origin.y = 0.0
        lHow.frame.origin.x = 0.0
        vLabelHow.frame.origin.x = PERC_BlackWidth
        vLabelHow.frame.size.width = AlmostFullWidth
        vLabelHow.frame.origin.y = CGRectGetMaxY(bHow.frame) + PERC_RedHeight
        vLabelHow.frame.size.height = lHow.frame.size.height
        
        vHow.frame.size.width = AlmostFullWidth
        vHow.frame.size.height = onePxHeight
        vHow.frame.origin.x = PERC_BlackWidth
        vHow.frame.origin.y = CGRectGetMaxY(vLabelHow.frame) + PERC_BlueHeight
        
        //In the views below, the labels are not visible when user launch the page
        
        bTerms.frame.origin.x = PERC_BlackWidth
        bTerms.frame.origin.y = CGRectGetMaxY(vHow.frame) //+ PERC_BlueHeight
        bTerms.sizeToFit()
        bTerms.frame.size.height = PERC_PurpleHeight
        
        /*var txtTerms = ""
         var asTerms = NSAttributedString(string: txtTerms, attributes: [NSParagraphStyleAttributeName: paraStyle,
         NSBaselineOffsetAttributeName: NSNumber(float: 0)]).length
         lTerms.frame.size.width = AlmostFullWidth
         lTerms.frame.origin.y = CGRectGetMaxY(bTerms.frame) + PERC_BlueHeight
         lTerms.frame.origin.x = PERC_BlackWidth
         lTerms.frame.size.height = 0*/
        
        vTerms.frame.size.width = AlmostFullWidth
        vTerms.frame.size.height = onePxHeight
        vTerms.frame.origin.x = PERC_BlackWidth
        //vTerms.frame.origin.y = CGRectGetMaxY(lTerms.frame) + PERC_BlueHeight
        vTerms.frame.origin.y = CGRectGetMaxY(bTerms.frame)
        
        
        bPolicy.frame.origin.x = PERC_BlackWidth
        bPolicy.frame.origin.y = CGRectGetMaxY(vTerms.frame) //+ PERC_BlueHeight
        bPolicy.sizeToFit()
        bPolicy.frame.size.height = PERC_PurpleHeight
        
        /*var txtPolicy = "We are committed to safeguarding the privacy of our users; this policy sets out how we will treat your personal information.\n\n(1) What information do we collect?:\n\nWe may collect, store and use the following kinds of personal information:\n\ninformation about your computer and about your visits to and use of this app (including your IP address, geographical location, application type and version, operating system, referral source, length of visit, page views and app navigation paths);\n\n(b) information relating to any use you may make of our free legal notices;\n\n(c) information that you provide to us for the purpose of registering with us;\n\n(d) information that you provide to us for the purpose of subscribing to our app services; and\n\n(e) any other information that you choose to send to us.\n\n(2) Cookies:\n\nA cookie consists of a piece of text sent by a web server to a web application, and stored by the application. The information is then sent back to the server each time the application requests a page from the server. This enables the web server to identify and track the web application.\n\nWe use both “session” cookies and “persistent” cookies on the app. We will use the cookies to keep track of you whilst you navigate the app and to enable our app to recognise you when you visit.\n\nSession cookies will be deleted from your computer when you close your application. Persistent cookies will remain stored on your computer until deleted, or until they reach a specified expiry date.\n\nWe use Google Analytics to analyse the use of this app. Google Analytics generates statistical and other information about app use by means of cookies, which are stored on users’ computers. The information generated relating to our app is used to create reports about the use of the app. Google will store this information. Google’s privacy policy is available at: http://www.google.com/privacypolicy.html.\n\nMost applications allow you to reject all cookies, whilst some applications allow you to reject just third party cookies. For example, in Internet Explorer you can refuse all cookies by clicking “Tools”, “Internet Options”, “Privacy”, and selecting “Block all cookies” using the sliding selector. Blocking all cookies will, however, have a negative impact upon the usability of many apps, including this one.\n\n(3) Using your personal information:\n\nPersonal information submitted to us via this app will be used for the purposes specified in this privacy policy or in relevant parts of the app.\n\nWe may use your personal information to:\n\nadminister the app;\n\n(b) improve your browsing experience by personalising the app;\n\n(c) enable your use of the services available on the app;\n\n(d) send you non-marketing commercial communications;\n\n(e) send you email notifications which you have specifically requested;\n\n(f) send to you marketing communications relating to our business or the businesses of carefully-selected third parties which we think may be of interest to you by post or, where you have specifically agreed to this, by email or similar technology (you can inform us at any time if you no longer require marketing communications);\n\n(g) provide third parties with statistical information about our users – but this information will not be used to identify any individual user; and\n\n(h) deal with enquiries and complaints made by or about you relating to the app.\n\nWhere you submit personal information for publication on our app, we will publish and otherwise use that information in accordance with the license you grant to us.\n\n\n(4) Disclosures:\n\nWe may disclose information about you to any of our employees, officers, agents, suppliers or subcontractors insofar as reasonably necessary for the purposes as set out in this privacy policy.\n\nIn addition, we may disclose your personal information:\n\nto the extent that we are required to do so by law;\n\n(b) in connection with any legal proceedings or prospective legal proceedings\n\n(c) in order to establish, exercise or defend our legal rights (including providing information to others for the purposes of fraud prevention and reducing credit risk);\n\n(d) to the purchaser (or prospective purchaser) of any business or asset that we are (or are contemplating) selling; and\n\n(e) to any person who we reasonably believe may apply to a court or other competent authority for disclosure of that personal information where, in our reasonable opinion, such court or authority would be reasonably likely to order disclosure of that personal information.\n\nExcept as provided in this privacy policy, we will not provide your information to third parties.\n\n\n(5) International data transfers:\n\nInformation that we collect may be stored and processed in and transferred between any of the countries in which we operate in order to enable us to use the information in accordance with this privacy policy.\n\nInformation which you provide may be transferred to countries which do not have data protection laws equivalent to those in force in the European Economic Area.\n\nIn addition, personal information that you submit for publication on the app will be published on the internet and may be available, via the internet, around the world. We cannot prevent the use or misuse of such information by others.\n\nYou expressly agree to such transfers of personal information.\n\n\n(6) Security of your personal information:\n\nWe will take reasonable technical and organisational precautions to prevent the loss, misuse or alteration of your personal information.\n\nWe will store all the personal information you provide on our hosting provider’s secure (password and firewall protected) servers.\nOf course, data transmission over the internet is inherently insecure, and we cannot guarantee the security of data sent over the internet.\n\nYou are responsible for keeping your password and user details confidential. We will not ask you for your password (except when you log in to the app).\n\n\n(7) Policy amendments:\n\nWe may update this privacy policy from time-to-time by posting a new version on our app. You should check this page occasionally to ensure you are happy with any changes.\n\n\n(8) Your rights:\n\nYou may instruct us to provide you with any personal information we hold about you. Provision of such information will be subject to:\n\nthe payment of a fee (currently fixed at £10.00); and\n\n\n(b) the supply of appropriate evidence of your identity (for this purpose, we will usually accept a photocopy of your passport certified by a lawyer or bank plus an original copy of a utility bill showing your current address).\n\nWe may withhold such personal information to the extent permitted by law.\n\nYou may instruct us not to process your personal information for marketing purposes, by sending an email to us. In practice, you will usually either expressly agree in advance to our use of your personal information for marketing purposes, or we will provide you with an opportunity to opt-out of the use of your personal information for marketing purposes.\n\n\n(9) Third party apps:\n\nThe app contains links to other apps. We are not responsible for the privacy policies or practices of third party apps.\n\n\n(10) Updating information:\n\nPlease let us know if the personal information which we hold about you needs to be corrected or updated.\n\n\n(11) Contact:\n\nIf you have any questions about this privacy policy or our treatment of your personal information, please write to us by email or by post.\n\n\n(12) Data controller:\n\nThe data controller responsible in respect of the information collected on this app is SEQ Legal LLP. Our data protection registration number is Z9812061."
         var asPolicy = NSAttributedString(string: txtPolicy, attributes: [NSParagraphStyleAttributeName: paraStyle,
         NSBaselineOffsetAttributeName: NSNumber(float: 0)])
         lPolicy.attributedText = asPolicy
         lPolicy.sizeToFit()
         lPolicy.frame.size.width = AlmostFullWidth
         lPolicy.frame.origin.y = CGRectGetMaxY(bPolicy.frame) + PERC_BlueHeight
         lPolicy.frame.origin.x = PERC_BlackWidth
         lPolicy.frame.size.height = 0*/
        
        vPolicy.frame.size.width = AlmostFullWidth
        vPolicy.frame.size.height = onePxHeight
        vPolicy.frame.origin.x = PERC_BlackWidth
        //vPolicy.frame.origin.y = CGRectGetMaxY(lPolicy.frame) + PERC_BlueHeight
        vPolicy.frame.origin.y = CGRectGetMaxY(bPolicy.frame)
        
        bContact.frame.origin.x = PERC_BlackWidth
        bContact.frame.origin.y = CGRectGetMaxY(vPolicy.frame) //+ PERC_BlueHeight
        bContact.sizeToFit()
        bContact.frame.size.height = PERC_PurpleHeight
        
        vContact.frame.size.width = AlmostFullWidth
        vContact.frame.size.height = onePxHeight
        vContact.frame.origin.x = PERC_BlackWidth
        vContact.frame.origin.y = CGRectGetMaxY(bContact.frame)
        
        //EDIT Our mission and How it works must not be expanded
        self.bMission.frame.size.height = PERC_PurpleHeight
        self.vLabelMission.frame.size.height = 0
        self.vMission.frame.origin.y = CGRectGetMaxY(self.bMission.frame)
        self.bHow.frame.size.height = PERC_PurpleHeight
        self.bHow.frame.origin.y = CGRectGetMaxY(self.vMission.frame)
        self.vLabelHow.frame.size.height = 0
        self.vHow.frame.origin.y = CGRectGetMaxY(self.bHow.frame)
        self.vLabelHow.frame.origin.y = CGRectGetMaxY(self.bHow.frame) + PERC_RedHeight
        self.bTerms.frame.origin.y = CGRectGetMaxY(self.vHow.frame)
        self.vTerms.frame.origin.y = CGRectGetMaxY(self.bTerms.frame)
        self.bPolicy.frame.origin.y = CGRectGetMaxY(self.vTerms.frame)
        self.vPolicy.frame.origin.y = CGRectGetMaxY(self.bPolicy.frame)
        self.bContact.frame.origin.y = CGRectGetMaxY(self.vPolicy.frame)
        self.vContact.frame.origin.y = CGRectGetMaxY(self.bContact.frame)
        //END EDIT
        
        scMain.frame.origin.x = 0.0
        scMain.frame.origin.y = 0
        scMain.frame.size.width = screenWidth
        scMain.frame.size.height = screenHeight
        scMain.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(self.vContact.frame) + 10.0)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showMission(sender : UIButton){
        if missionShowed {
            UIView.animateWithDuration(0.4, animations: {
                self.bMission.frame.size.height = PERC_PurpleHeight
                self.vLabelMission.frame.size.height = 0
                self.vMission.frame.origin.y = CGRectGetMaxY(self.bMission.frame)
                
                self.bHow.frame.origin.y = CGRectGetMaxY(self.vMission.frame)
                self.vLabelHow.frame.origin.y = CGRectGetMaxY(self.bHow.frame)
                self.vHow.frame.origin.y = CGRectGetMaxY(self.vLabelHow.frame)
                self.bTerms.frame.origin.y = CGRectGetMaxY(self.vHow.frame)
                self.vTerms.frame.origin.y = CGRectGetMaxY(self.bTerms.frame)
                self.bPolicy.frame.origin.y = CGRectGetMaxY(self.vTerms.frame)
                self.vPolicy.frame.origin.y = CGRectGetMaxY(self.bPolicy.frame)
                self.bContact.frame.origin.y = CGRectGetMaxY(self.vPolicy.frame)
                self.vContact.frame.origin.y = CGRectGetMaxY(self.bContact.frame)
            })
            missionShowed = false
        } else {
            UIView.animateWithDuration(0.4, animations: {
                //self.bMission.sizeToFit()
                self.vLabelMission.frame.size.height = self.lMission.frame.size.height
                self.vMission.frame.origin.y = CGRectGetMaxY(self.vLabelMission.frame) + PERC_BlueHeight
                
                self.bHow.frame.origin.y = CGRectGetMaxY(self.vMission.frame)// + PERC_BlueHeight
                self.vLabelHow.frame.origin.y = CGRectGetMaxY(self.bHow.frame)// + PERC_RedHeight
                self.vHow.frame.origin.y = CGRectGetMaxY(self.vLabelHow.frame)// + PERC_BlueHeight
                self.bTerms.frame.origin.y = CGRectGetMaxY(self.vHow.frame)
                self.vTerms.frame.origin.y = CGRectGetMaxY(self.bTerms.frame)
                self.bPolicy.frame.origin.y = CGRectGetMaxY(self.vTerms.frame)
                self.vPolicy.frame.origin.y = CGRectGetMaxY(self.bPolicy.frame)
                self.bContact.frame.origin.y = CGRectGetMaxY(self.vPolicy.frame)
                self.vContact.frame.origin.y = CGRectGetMaxY(self.bContact.frame)
            })
            missionShowed = true
        }
        scMain.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(self.vContact.frame) + 10.0)
    }
    
    @IBAction func showHow(sender : UIButton){
        if howShowed {
            UIView.animateWithDuration(0.4, animations: {
                self.bHow.frame.size.height = PERC_PurpleHeight
                self.bHow.frame.origin.y = CGRectGetMaxY(self.vMission.frame)
                self.vLabelHow.frame.size.height = 0
                self.vHow.frame.origin.y = CGRectGetMaxY(self.bHow.frame)
                
                self.bTerms.frame.origin.y = CGRectGetMaxY(self.vHow.frame)
                self.vTerms.frame.origin.y = CGRectGetMaxY(self.bTerms.frame)
                self.bPolicy.frame.origin.y = CGRectGetMaxY(self.vTerms.frame)
                self.vPolicy.frame.origin.y = CGRectGetMaxY(self.bPolicy.frame)
                self.bContact.frame.origin.y = CGRectGetMaxY(self.vPolicy.frame)
                self.vContact.frame.origin.y = CGRectGetMaxY(self.bContact.frame)
            })
            howShowed = false
        } else {
            UIView.animateWithDuration(0.4, animations: {
                //self.bHow.sizeToFit() UPDATE 17/11
                self.vLabelHow.frame.size.height = self.lHow.frame.size.height
                self.vHow.frame.origin.y = CGRectGetMaxY(self.vLabelHow.frame) + PERC_BlueHeight
                
                self.bTerms.frame.origin.y = CGRectGetMaxY(self.vHow.frame)
                self.vTerms.frame.origin.y = CGRectGetMaxY(self.bTerms.frame)
                self.bPolicy.frame.origin.y = CGRectGetMaxY(self.vTerms.frame)
                self.vPolicy.frame.origin.y = CGRectGetMaxY(self.bPolicy.frame)
                self.bContact.frame.origin.y = CGRectGetMaxY(self.vPolicy.frame)
                self.vContact.frame.origin.y = CGRectGetMaxY(self.bContact.frame)
            })
            howShowed = true
        }
        scMain.contentSize = CGSize(width: screenWidth, height: CGRectGetMaxY(self.vContact.frame) + 10.0)
    }
    
    @IBAction func showTerms(sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myCollec : TermsController = storyboard.instantiateViewControllerWithIdentifier("terms") as! TermsController
        self.navigationController?.pushViewController(myCollec, animated: true)
    }
    
    @IBAction func showPolicy(sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myCollec : PolicyController = storyboard.instantiateViewControllerWithIdentifier("policy") as! PolicyController
        self.navigationController?.pushViewController(myCollec, animated: true)
    }
    
    // Configure the mail composer
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        if namesLoaded {
            mailComposerVC.setToRecipients(["info@getglobe.co"])
            mailComposerVC.setSubject("A message for the globe team - \(self.firstname) \(self.lastname)")
            mailComposerVC.setMessageBody("Hi, I've been using globe on iOS and I just want to say... \n\nFrom \(self.firstname) \(self.lastname)", isHTML: false)
        } else if usernameLoaded {
            mailComposerVC.setToRecipients(["info@getglobe.co"])
            mailComposerVC.setSubject("A message for the globe team - \(self.fromUser)")
            mailComposerVC.setMessageBody("Hi, I've been using globe on iOS and I just want to say... \n\nFrom \(self.fromUser)", isHTML: false)
        }
        return mailComposerVC
    }
    
    @IBAction func showContact(sender : UIButton){
        let mailComposeViewController = configuredMailComposeViewController()
        
        // Can the app send mail?
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            let sendMailErrorAlert = UIAlertView(title: "Oops! Something went wrong.", message: "We had some trouble sending your email. Please check your connection and email configuration.", delegate: self, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()
        }
    }
}
