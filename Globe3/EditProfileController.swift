//
//  EditProfilController.swift
//  Globe3
//
//  Created by Charles Masson on 15/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit
import Parse
import ActionSheetPicker_3_0
import GoogleMaps
import GooglePlaces

class EditProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,
        GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet var tfFirstName : UITextField!
    @IBOutlet var vUnderFirstName : UIView!
    @IBOutlet var tfName : UITextField!
    @IBOutlet var vUnderName : UIView!
    @IBOutlet var tfLocation : UITextField!
    @IBOutlet var vUnderLocation : UIView!
    @IBOutlet var tfAge : UITextField!
    @IBOutlet var vUnderAge : UIView!
    @IBOutlet var tfGender : UITextField!
    @IBOutlet var vUnderGender : UIView!
    @IBOutlet var tfMail : UITextField!
    @IBOutlet var vUnderMail : UIView!
    @IBOutlet var ivProfile : UIImageView!
    @IBOutlet var ivNameIcon : UIImageView!
    @IBOutlet var ivLocation : UIImageView!
    @IBOutlet var ivAge : UIImageView!
    @IBOutlet var ivGender : UIImageView!
    @IBOutlet var ivMail : UIImageView!
    @IBOutlet var ivFacebookIcon : UIImageView!
    @IBOutlet var ivFacebookConnect : UIImageView!
    @IBOutlet var bFacebookConnect : UIButton!
    @IBOutlet var vUnderFacebook : UIView!
    @IBOutlet var bLogOut : UIButton!
    @IBOutlet var ivLogout : UIImageView!
    @IBOutlet var vUnderLogout : UIView!
    @IBOutlet var bSave : ButtonDoneContinue!
    @IBOutlet var bChangePhoto : UIButton!
    
    var profilePicture : UIImage!
    var isImageSet : Bool!
    var firstName : String!
    var name : String!
    var location : String!
    var age : String!
    var gender : String!
    var mail : String!
    
    var activityIndicator : UIActivityIndicatorView!
    
    let user = PFUser.currentUser()
    
    var ageSelected : Int!
    
    
    var imgDelegate : ImageBackDelegate?
    
    var hv : HelpView!
    
    override func viewDidLoad() {
        
        //Blue placeholder
        let color : UIColor = UIColor(red: 0, green: 0, blue: 117/255, alpha: 0.6)
        

        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileController.backPressed(_:)))
        ivProfile.frame.origin.x = PERC_BlackWidth
        ivProfile.frame.origin.y = PERC_BlueHeight + 64
        ivProfile.frame.size = CGSize(width: PERC_CoteProfilePicture, height: PERC_CoteProfilePicture)
        ivProfile.layer.cornerRadius = PERC_CoteProfilePicture / 2
        ivProfile.clipsToBounds = true
        ivProfile.contentMode = UIViewContentMode.ScaleAspectFill
        bChangePhoto.frame = ivProfile.frame


        /*if profilePicture != nil {
            ivProfile.image = profilePicture
        }*/
        ivProfile.image = UIImage(named: "ivprofile_placeholder")
        ivProfile.backgroundColor = UIColor.grayColor()
        
        ivNameIcon.frame.origin.x = CGRectGetMaxX(ivProfile.frame) + PERC_BlackWidth
        ivNameIcon.frame.origin.y = 2 * PERC_BlueHeight + 64
        ivNameIcon.frame.size = CGSize(width: PERC_CoteIconPicture, height: PERC_CoteIconPicture)
        
        let twoFirstTFWidth = screenWidth - 4 * PERC_BlackWidth - PERC_CoteIconPicture - PERC_CoteProfilePicture
        if firstName != nil {
            tfFirstName.text = firstName
        }

        tfFirstName.attributedPlaceholder = NSAttributedString(string: "First name", attributes: [NSForegroundColorAttributeName: color])
        tfFirstName.frame.size.width = twoFirstTFWidth
        tfFirstName.frame.size.height = PERC_EditTextFieldHeight
        tfFirstName.frame.origin.x = CGRectGetMaxX(ivNameIcon.frame) + PERC_BlackWidth
        tfFirstName.frame.origin.y = PERC_BlueHeight + 64
        tfFirstName.delegate = self
        
        vUnderFirstName.frame.size.width = tfFirstName.frame.size.width
        vUnderFirstName.frame.size.height = 1
        vUnderFirstName.frame.origin.x = CGRectGetMaxX(ivNameIcon.frame) + PERC_BlackWidth
        vUnderFirstName.frame.origin.y = CGRectGetMaxY(tfFirstName.frame)
        
        if name != nil {
            tfName.text = name
        }
        tfName.attributedPlaceholder = NSAttributedString(string: "Last name", attributes: [NSForegroundColorAttributeName: color])

        tfName.frame.size.width = twoFirstTFWidth
        tfName.frame.size.height = PERC_EditTextFieldHeight
        tfName.frame.origin.x = CGRectGetMaxX(ivNameIcon.frame) + PERC_BlackWidth
        tfName.frame.origin.y = CGRectGetMaxY(vUnderFirstName.frame)
        tfName.delegate = self
        tfName.autocapitalizationType = UITextAutocapitalizationType.Words
        
        vUnderName.frame.size.width = tfFirstName.frame.size.width
        vUnderName.frame.size.height = 1
        vUnderName.frame.origin.x = CGRectGetMaxX(ivNameIcon.frame) + PERC_BlackWidth
        vUnderName.frame.origin.y = CGRectGetMaxY(tfName.frame)
        
        let otherTFWidth = screenWidth - 3 * PERC_BlackWidth - PERC_CoteIconPicture
        //let otherTFOriginX = CGRectGetMaxX(ivProfile.frame) + PERC_BlackWidth

        ivMail.frame.size = CGSize(width: PERC_CoteIconPicture, height: PERC_CoteIconPicture)
        ivMail.frame.origin.x = PERC_BlackWidth
        ivMail.frame.origin.y = CGRectGetMaxY(vUnderName.frame) + PERC_DarkRedWidth//PERC_BlueHeight
        self.tfMail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: color])

        if user != nil {
            tfMail.text = user?.email
        }

        let vUnderMailX = CGRectGetMinX(ivProfile.frame) + PERC_BlackWidth + 20

        tfMail.frame.size.width = otherTFWidth
        tfMail.frame.size.height = PERC_SmallEditTextFieldHeight//PERC_EditTextFieldHeight
        tfMail.frame.origin.x = vUnderMailX
        tfMail.frame.origin.y = CGRectGetMinY(ivMail.frame) - PERC_DarkRedWidth//PERC_BlueHeight
        tfMail.delegate = self


        vUnderMail.frame.size.width = otherTFWidth
        vUnderMail.frame.size.height = 1
        vUnderMail.frame.origin.x = vUnderMailX
        vUnderMail.frame.origin.y = CGRectGetMaxY(tfMail.frame)

        ivLogout.frame.size = CGSize(width: PERC_CoteIconPicture, height: PERC_CoteIconPicture)
        ivLogout.frame.origin.x = PERC_BlackWidth

        bLogOut.sizeToFit()
        bLogOut.frame.origin.x = vUnderMailX
        bLogOut.frame.origin.y = CGRectGetMaxY(vUnderMail.frame) + 5
        ivLogout.center.y = bLogOut.center.y
        
        vUnderLogout.frame.size.width = otherTFWidth//screenWidth - 2 * PERC_BlackWidth
        vUnderLogout.frame.size.height = 1
        vUnderLogout.frame.origin.x = vUnderMailX
        vUnderLogout.frame.origin.y = CGRectGetMaxY(bLogOut.frame)
        vUnderLogout.frame.origin.y += 5
        
        bSave.frame.size.width = HalfScreenButtonWidth
        bSave.frame.origin.y = PERC_OrangeVomiHeight
        bSave.center.x = self.view.center.x
        
        let ud = NSUserDefaults.standardUserDefaults()
        if let firstTime = ud.objectForKey("FIRSTTIME_EDITPROFILE") as? Bool {
            if firstTime {
                makeHV(ud)
            }
        } else {
            makeHV(ud)
        }
        //ud.setObject(wvFont, forKey: "PREFERRED_FONTFAMILY")
        //ud.synchronize()
    }
    
    
    
    func makeHV(ud : NSUserDefaults) {
        hv = HelpView(text: "Edit your profile here.")
        hv.center = self.view.center
        self.view.addSubview(hv)
        ud.setBool(false, forKey: "FIRSTTIME_EDITPROFILE")
        ud.synchronize()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditProfileController.backPressed(_:)))
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        hvDisappear()
        view.endEditing(true)
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
            message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo", style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing", style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) -> Void in }
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func logOutClicked(sender : UIButton){
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to Log Out?", preferredStyle: UIAlertControllerStyle.Alert)
        let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { _ in
            PFUser.logOut()
            self.presentingViewController?.navigationController?.popToRootViewControllerAnimated(false)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let no = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(sender : UIButton){
        addActivityIndicator()
        //let user = PFUser.currentUser()
        if user != nil {
            var allPreferencesSet = true

            
            if tfName.text != nil && tfName.text != "" {
                user?.setObject(tfName.text!, forKey: "lastname")
            } else { allPreferencesSet = false }
            
            if tfFirstName.text != nil && tfFirstName.text != "" {
                user?.setObject(tfFirstName.text!, forKey: "firstname")
            } else { allPreferencesSet = false }

            
            if tfMail.text != nil && tfMail.text != "" {
                if Functions.isValidEmail(tfMail.text!) {
                    user?.setObject(tfMail.text!, forKey: "email")
                } else {
                    removeActivityIndicator()
                    let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email adress", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else { allPreferencesSet = false }
            
            if self.profilePicture != nil {
                imgDelegate?.sendImageBack(self.profilePicture)
                let dat = UIImageJPEGRepresentation(self.profilePicture, 0.5)
                if dat != nil {
                    let imgFile = PFFile(data: dat!)
                    imgFile!.saveInBackgroundWithBlock{(success, error) -> Void in
                        if error == nil {
                            if success {
                                self.user?.setObject(imgFile!, forKey: "profilePicture")
                                self.user?.saveInBackground()
                            }
                        } else {
                            print(error)
                        }
                    }
                }
            }
            if allPreferencesSet {}
            
            //if allPreferencesSet { user?.setObject(true, forKey: "didEnterCustomInfos") }
            user?.setObject(true, forKey: "didEnterCustomInfos")
            
            mustLaunchEditProfile = false
            let task = user?.saveInBackground()
            print (task)
        } else {
            PFUser.logOut()
        }
        removeActivityIndicator()
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromBottom
        self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backPressed(sender : UIBarButtonItem){
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromBottom
        self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.ivProfile.image = selectedPhoto
            self.profilePicture = selectedPhoto
            removeActivityIndicator()
            dismissViewControllerAnimated(true, completion: {})
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
    
    func textFieldDidBeginEditing(tf: UITextField) {
        tfGoesUp(tf)
    }
    
    func textFieldDidEndEditing(tf: UITextField) {
        tfGoesDown(tf)
    }
    
    func tfGoesUp(tf: UITextField){
        if tf != tfName && tf != tfFirstName && tf != tfLocation && tf != tfAge {
            UIView.beginAnimations("tfGoesUp", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            self.view.frame = CGRectOffset(self.view.frame, 0, -80)
            UIView.commitAnimations()
        }
    }
    
    func tfGoesDown(tf: UITextField){
        if tf != tfName && tf != tfFirstName && tf != tfLocation && tf != tfAge {
            UIView.beginAnimations("tfGoesDown", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            self.view.frame = CGRectOffset(self.view.frame, 0, 80)
            UIView.commitAnimations()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        hvDisappear()
    }
    
    func hvDisappear() {
        if hv != nil {
            hv.disappear()
        }
    }
    
    func textFieldShouldReturn(tf: UITextField) -> Bool {
        if tf == self.tfFirstName {
            self.tfName.becomeFirstResponder()
        } else if tf == self.tfName {
            self.tfLocation.becomeFirstResponder()
        } else if tf == self.tfLocation {
            self.tfAge.becomeFirstResponder()
        } else if tf == self.tfAge {
            self.tfGender.becomeFirstResponder()
        } else if tf == self.tfGender {
            self.tfMail.becomeFirstResponder()
        } else {
            tf.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(tf: UITextField) -> Bool {
        hvDisappear()
//        if tf == tfAge {
//            let arrAge = NSMutableArray()
//            for i in 0  ..< 7  {
//                arrAge.addObject(Functions.getAgeCarouselText(i))
//            }
//            ActionSheetStringPicker.showPickerWithTitle("Slect your age", rows: arrAge as [AnyObject], initialSelection: 0, doneBlock: {
//                picker, index, value in
//                self.tfAge.text = (value as! String)
//                self.ageSelected = index
//                return
//                }, cancelBlock: { ActionStringCancelBlock in return }, origin: self.view)
//            
//        } else if tf == tfGender {
//            let arrGender = ["Male", "Female", "Other"]
//            ActionSheetStringPicker.showPickerWithTitle("Slect your gender", rows: arrGender as [AnyObject], initialSelection: 0, doneBlock: {
//                picker, index, value in
//                self.tfGender.text = (value as! String)
//                return
//                }, cancelBlock: { ActionStringCancelBlock in return }, origin: self.view)
//        } else if tf == tfLocation {
//            let autocompleteController = GMSAutocompleteViewController()
//            autocompleteController.delegate = self
//            let filter = GMSAutocompleteFilter()
//            filter.type = .City
//            autocompleteController.autocompleteFilter = filter
//            self.presentViewController(autocompleteController, animated: true, completion: nil)
//        }

        return true //tf == tfMail
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        tfLocation.text = place.formattedAddress
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        print("Error: ", error.description)
    }
    
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

protocol ImageBackDelegate {
    func sendImageBack(image : UIImage)
    func sendLocation(loc : String)
    func sendAge(age : String)
    func sendGender(gender : String)
}
