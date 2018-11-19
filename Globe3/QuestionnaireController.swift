//
//  QuestionnaireController.swift
//  Globe
//
//  Created by Charles Masson on 07/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import Foundation
import UIKit
import Parse


class QuestionnaireController : UIViewController {
    
    @IBOutlet var lTitle1 : UILabel!
    @IBOutlet var lTitle2 : UILabel!
    @IBOutlet var lFiction : UILabel!
    @IBOutlet var lNonFiction : UILabel!
    @IBOutlet var lClassic : UILabel!
    @IBOutlet var lCont : UILabel!
    @IBOutlet var lShort : UILabel!
    @IBOutlet var lLong : UILabel!
    @IBOutlet var slFiction : UISlider!
    @IBOutlet var slClassic : UISlider!
    @IBOutlet var slShort : UISlider!
    @IBOutlet var bNext : ButtonDoneContinue!
    @IBOutlet var ivBottom : UIImageView!
    
    override func viewDidLoad() {
        
        navigationItem.title = "About You"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrowup"), style: .Plain, target: self, action: #selector(QuestionnaireController.backToPrevious(_:)))
        navigationController?.navigationBarHidden = false
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(QuestionnaireController.backToPreviousPage(_:)))
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
        
        lFiction.sizeToFit()
        lFiction.frame.origin.y = CGRectGetMaxY(lTitle2.frame) + PERC_PurpleHeight
        lFiction.frame.origin.x = PERC_BlackWidth
        
        lNonFiction.sizeToFit()
        lNonFiction.frame.origin.y = lFiction.frame.origin.y
        lNonFiction.frame.origin.x = screenWidth - lNonFiction.frame.size.width - PERC_BlackWidth
        
        let sliderWidth = screenWidth - 2 * PERC_BlackWidth
        slFiction.frame.size.width = sliderWidth
        slFiction.frame.origin.x = PERC_BlackWidth
        slFiction.frame.origin.y = CGRectGetMaxY(lFiction.frame)//+ PERC_YellowHeight
        
        let trackRect = slFiction.trackRectForBounds(slFiction.bounds)
        let thumbRect = slFiction.thumbRectForBounds(slFiction.bounds, trackRect: trackRect, value: 0)
        let slThumbWidth = thumbRect.size.width
        
        let thImage = UIImage(named: "slider-thumb-centered")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: slThumbWidth, height: slThumbWidth), false, 0.0)
        thImage?.drawInRect(CGRectMake(0, 0, slThumbWidth, slThumbWidth))
        let scaledThImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slFiction.setThumbImage(scaledThImage, forState: UIControlState.Normal)
        
        slFiction.frame.origin.x = PERC_BlackWidth
        slFiction.frame.size.width = sliderWidth
        
        let labelLeftOrigin = PERC_BlackWidth + (slThumbWidth/* - PERC_TealHeight*/) / 2
        lFiction.frame.origin.x = labelLeftOrigin
        lNonFiction.frame.origin.x = screenWidth - lNonFiction.frame.size.width - labelLeftOrigin
        
        let sliderTrack = UIImage()
        //Transparent track
        slFiction.setMinimumTrackImage(sliderTrack, forState: UIControlState.Normal)
        slFiction.setMaximumTrackImage(sliderTrack, forState: UIControlState.Normal)
        
        //Track constants
        let vLine0 = UIView()
        let vLineWidth = slFiction.frame.size.width - slThumbWidth
        let vLineHeight = PERC_TealHeight
        let vLineColor = UIColor.whiteColor()
        
        //Setting blue track
        vLine0.frame.size.width = vLineWidth
        vLine0.frame.size.height = vLineHeight
        vLine0.center = slFiction.center
        vLine0.backgroundColor = vLineColor
        vLine0.layer.cornerRadius = PERC_TealHeight / 2
        
        self.view.addSubview(vLine0)
        
        for i in 0  ..< 5 {
            let circle = SliderRedCircle(frame: CGRect(x: 0.0, y: 0.0, width: PERC_TealHeight, height: PERC_TealHeight))
            circle.frame.origin.x = (CGFloat(i) / 4) * (vLineWidth - PERC_TealHeight) + PERC_BlackWidth + slThumbWidth / 2// - PERC_TealHeight / 2
            circle.frame.origin.y = vLine0.frame.origin.y
            self.view.addSubview(circle)
        }
        self.view.bringSubviewToFront(slFiction)
        
        lClassic.sizeToFit()
        lClassic.frame.origin.x = labelLeftOrigin
        lClassic.frame.origin.y = CGRectGetMaxY(slFiction.frame) + PERC_PurpleHeight
        
        lCont.sizeToFit()
        lCont.frame.origin.x = screenWidth - lCont.frame.size.width - labelLeftOrigin
        lCont.frame.origin.y = lClassic.frame.origin.y
        
        slClassic.frame.size.width = sliderWidth
        slClassic.frame.origin.x = PERC_BlackWidth
        slClassic.frame.origin.y = CGRectGetMaxY(lClassic.frame)// + PERC_YellowHeight
        
        slClassic.setThumbImage(scaledThImage, forState: UIControlState.Normal)
        
        //Transparent track
        slClassic.setMinimumTrackImage(sliderTrack, forState: UIControlState.Normal)
        slClassic.setMaximumTrackImage(sliderTrack, forState: UIControlState.Normal)
        
        //Setting blue track
        let vLine1 = UIView()
        
        vLine1.frame.size.width = vLineWidth
        vLine1.frame.size.height = vLineHeight
        vLine1.center = slClassic.center
        vLine1.backgroundColor = vLineColor
        vLine1.layer.cornerRadius = PERC_TealHeight / 2
        
        self.view.addSubview(vLine1)
        
        for i in 0  ..< 5 {
            let circle = SliderRedCircle(frame: CGRect(x: 0.0, y: 0.0, width: PERC_TealHeight, height: PERC_TealHeight))
            circle.frame.origin.x = (CGFloat(i) / 4) * (vLineWidth - PERC_TealHeight) + PERC_BlackWidth + slThumbWidth / 2
            circle.frame.origin.y = vLine1.frame.origin.y
            self.view.addSubview(circle)
        }
        self.view.bringSubviewToFront(slClassic)
        
        lShort.sizeToFit()
        lShort.frame.origin.x = labelLeftOrigin
        lShort.frame.origin.y = CGRectGetMaxY(slClassic.frame) + PERC_PurpleHeight
        
        lLong.sizeToFit()
        lLong.frame.origin.x = screenWidth - lLong.frame.size.width - labelLeftOrigin
        lLong.frame.origin.y = lShort.frame.origin.y
        
        slShort.frame.size.width = sliderWidth
        slShort.frame.origin.x = PERC_BlackWidth
        slShort.frame.origin.y = CGRectGetMaxY(lShort.frame)// + PERC_YellowHeight
        
        slShort.setThumbImage(scaledThImage, forState: UIControlState.Normal)
        
        //Transparent track
        slShort.setMinimumTrackImage(sliderTrack, forState: UIControlState.Normal)
        slShort.setMaximumTrackImage(sliderTrack, forState: UIControlState.Normal)
        
        //Setting blue track
        let vLine2 = UIView()
        
        vLine2.frame.size.width = vLineWidth
        vLine2.frame.size.height = vLineHeight
        vLine2.center = slShort.center
        vLine2.backgroundColor = vLineColor
        vLine2.layer.cornerRadius = PERC_TealHeight / 2
        
        self.view.addSubview(vLine2)
        
        for i in 0  ..< 5 {
            let circle = SliderRedCircle(frame: CGRect(x: 0.0, y: 0.0, width: PERC_TealHeight, height: PERC_TealHeight))
            circle.frame.origin.x = (CGFloat(i) / 4) * (vLineWidth - PERC_TealHeight) + PERC_BlackWidth + slThumbWidth / 2
            circle.frame.origin.y = vLine2.frame.origin.y
            self.view.addSubview(circle)
        }
        self.view.bringSubviewToFront(slShort)
        
        bNext.frame.origin.y = screenHeight - bNext.frame.size.height - PERC_BottomMarginNextButton//PERC_OrangeVomiHeight
        bNext.center.x = self.view.center.x
        
        ivBottom.frame.size.height = PERC_TealHeight
        ivBottom.contentMode = UIViewContentMode.ScaleAspectFit
        ivBottom.frame.origin.y = CGRectGetMaxY(bNext.frame) + PERC_BlueHeight
        ivBottom.center.x = self.view.center.x
        
        let tapSlider = UITapGestureRecognizer(target: self, action: #selector(QuestionnaireController.sliderTapped(_:)))
        let tapSliderS = UITapGestureRecognizer(target: self, action: #selector(QuestionnaireController.sliderTapped(_:)))
        let tapSliderC = UITapGestureRecognizer(target: self, action: #selector(QuestionnaireController.sliderTapped(_:)))
        
        slFiction.addGestureRecognizer(tapSlider)
        slShort.addGestureRecognizer(tapSliderS)
        slClassic.addGestureRecognizer(tapSliderC)
    }
    
    override func viewDidAppear(animated: Bool) {
        bNext.backgroundColor = MainOrangeColor
    }
    
    @IBAction func sliderThumbReleased(sender : UISlider){
        let val = sender.value
        let roundedVal : Int = Int(round(val))
        if val > Float(roundedVal){
            smoothLeftThumbTranslation(roundedVal, currentValue: val, slider: sender)
        } else {
            smoothRightThumbTranslation(roundedVal, slider: sender)
        }
    }
    
    @IBAction func sliderTapped(sender : UITapGestureRecognizer) {
        let slider = sender.view as! UISlider
        let x = sender.locationInView(slider).x
        let perc = x / slider.frame.size.width
        let offset = perc * CGFloat(slider.maximumValue - slider.minimumValue)
        let val = offset + CGFloat(slider.minimumValue)
        let intVal = Int(round(val))
        slider.setValue(Float(intVal), animated: true)
    }
    
    @IBAction func nextClicked(sender : UIButton){
        let user = PFUser.currentUser()
        if user != nil {
            user?.setObject((round(slFiction.value)), forKey: "nonFictionMark")
            user?.setObject((round(slClassic.value)), forKey: "contemporaryMark")
            user?.setObject((round(slShort.value)), forKey: "longMark")
            user?.saveInBackground()
        }
        sender.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        next()
    }
    
    func next() {
        let trans = CATransition()
        trans.duration = 0.5
        trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        trans.type = kCATransitionMoveIn
        trans.subtype = kCATransitionFromTop
        navigationController!.view.layer.addAnimation(trans, forKey: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("secondquestionnaire")
        navigationController?.pushViewController(vc, animated: false)
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
    
    func smoothLeftThumbTranslation(valueToReach: Int, currentValue: Float, slider: UISlider){
        var val = slider.value
        if val > Float(valueToReach) {
            val -= 0.05
            slider.value = val
            let delai : Double = Double(0.05 * (val - Float(valueToReach)))
            delay(delai){
                self.smoothLeftThumbTranslation(valueToReach, currentValue: val, slider: slider)
            }
        } else {
            slider.value = Float(valueToReach)
        }
    }
    
    func smoothRightThumbTranslation(valueToReach: Int, slider: UISlider){
        var val = slider.value
        if val < Float(valueToReach) {
            val += 0.05
            slider.value = val
            let delai : Double = Double(0.05 * (Float(valueToReach) - val))
            delay(delai){
                self.smoothRightThumbTranslation(valueToReach, slider: slider)
            }
        } else {
            slider.value = Float(valueToReach)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /*override func prefersStatusBarHidden() -> Bool {
        return true
    }*/
}