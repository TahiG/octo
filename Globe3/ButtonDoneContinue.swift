//
//  ButtonDoneContinue.swift
//  Globe3
//
//  Created by Charles Masson on 11/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class ButtonDoneContinue : UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 9.0
        self.backgroundColor = UIColor(red: 255/255, green: 60/255, blue: 0, alpha: 1)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.frame.size.height = PERC_ButtonDoneContinue
        self.frame.size.width = HalfScreenButtonWidth
    }
}
