//
//  MenuButton.swift
//  Globe3
//
//  Created by Charles Masson on 21/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class MenuButton : UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    init(text : String, originY : CGFloat) {
        super.init(frame: CGRect(x: PERC_BlackWidth * 2, y: originY, width: separatorWidth, height: PERC_BeigeHeight))
        contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        setTitle(text, forState: UIControlState.Normal)
        setTitleColor(menuColor, forState: UIControlState.Normal)
        titleLabel!.font = menuFont
    }
}