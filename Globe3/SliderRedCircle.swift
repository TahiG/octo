//
//  SliderRedCircle.swift
//  Globe
//
//  Created by Charles Masson on 07/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class SliderRedCircle : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let halfWidth = frame.size.width / 2
        self.layer.cornerRadius = halfWidth
        self.layer.masksToBounds = true;
        //self.backgroundColor = UIColor.redColor()
        self.backgroundColor = UIColor(red: 175/255, green: 173/255, blue: 173/255, alpha: 1)
        /*var vBlanc = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width - 2, height: frame.size.width - 2))
        vBlanc.center = self.center
        vBlanc.layer.cornerRadius = vBlanc.frame.size.width / 2
        vBlanc.layer.masksToBounds = true;
        vBlanc.backgroundColor = UIColor.whiteColor()*/
        
        //self.addSubview(vBlanc)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
    }
    
}
