//
//  BookEndView.swift
//  Globe
//
//  Created by Charles Masson on 13/01/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit
import MessageUI
import Social

class BookEndView : UIView {
    
    @IBOutlet var lCongrats : UILabel!
    @IBOutlet var lFinished : UILabel!
    @IBOutlet var lBookTitle : UILabel!
    @IBOutlet var lAuthor : UILabel!
    @IBOutlet var lTell : UILabel!
    @IBOutlet var ivShareFacebook : UIImageView!
    @IBOutlet var ivShareTwitter : UIImageView!
    @IBOutlet var ivShareEmail : UIImageView!
    
    var bookTitle = ""
    var vc : ReadingWithBannerController!
    
    var shareDelegate : ShareAndEmailDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let xOriginShare = screenWidth / 30
        let widthShare = screenWidth - 2 * xOriginShare
        let heightShare = widthShare / 6
        
        lCongrats.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_LightBrownHeight)
        lFinished.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lCongrats.frame) + PERC_RedHeight)
        lBookTitle.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lFinished.frame) + PERC_RedHeight)
        lAuthor.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lBookTitle.frame) + PERC_RedHeight)
        lTell.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lAuthor.frame) + PERC_RedHeight)
        lCongrats.sizeToFit()
        lFinished.sizeToFit()
        lBookTitle.sizeToFit()
        lAuthor.sizeToFit()
        lTell.sizeToFit()
        
        ivShareFacebook.frame = CGRect(x: xOriginShare, y: CGRectGetMaxY(lTell.frame) + PERC_DarkPurpleHeight, width: widthShare, height: heightShare)
        ivShareTwitter.frame = CGRect(x: xOriginShare, y: CGRectGetMaxY(ivShareFacebook.frame) + PERC_BlueHeight, width: widthShare, height: heightShare)
        ivShareEmail.frame = CGRect(x: xOriginShare, y: CGRectGetMaxY(ivShareTwitter.frame) + PERC_BlueHeight, width: widthShare, height: heightShare)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let xOriginShare = screenWidth / 30
        let widthShare = screenWidth - 2 * xOriginShare
        let heightShare = widthShare / 6
        
        lCongrats.frame.origin = CGPoint(x: PERC_BlackWidth, y: PERC_LightBrownHeight)
        lFinished.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lCongrats.frame) + PERC_RedHeight)
        lBookTitle.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lFinished.frame) + PERC_RedHeight)
        lAuthor.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lBookTitle.frame) + PERC_RedHeight)
        lTell.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(lAuthor.frame) + PERC_RedHeight)
        lCongrats.sizeToFit()
        lFinished.sizeToFit()
        lBookTitle.sizeToFit()
        lAuthor.sizeToFit()
        lTell.sizeToFit()
        
        ivShareFacebook.frame = CGRect(x: xOriginShare, y: CGRectGetMaxY(lTell.frame) + PERC_DarkPurpleHeight, width: widthShare, height: heightShare)
        ivShareTwitter.frame = CGRect(x: xOriginShare, y: CGRectGetMaxY(ivShareFacebook.frame) + PERC_BlueHeight, width: widthShare, height: heightShare)
        ivShareEmail.frame = CGRect(x: xOriginShare, y: CGRectGetMaxY(ivShareTwitter.frame) + PERC_BlueHeight, width: widthShare, height: heightShare)
    }
    
    @IBAction func fbShare(sender : UITapGestureRecognizer) {
        shareDelegate.fbShareFromParent()
    }
    
    @IBAction func twittShare(sender : UITapGestureRecognizer) {
        shareDelegate.twittShareFromParent()
    }
    
    @IBAction func mailShare(sender : UITapGestureRecognizer) {
        shareDelegate.mailShareFromParent()
    }
}



protocol ShareAndEmailDelegate {
    func fbShareFromParent()
    func twittShareFromParent()
    func mailShareFromParent()
}
