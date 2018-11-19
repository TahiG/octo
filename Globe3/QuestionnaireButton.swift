//
//  QuestionnaireButton.swift
//  Globe3
//
//  Created by Charles Masson on 21/11/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class QuestionnaireButton : UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        titleLabel?.textAlignment = NSTextAlignment.Center
        layer.borderColor = borderColorNormal
        frame.size = CGSize(width: AlmostFullWidth, height: PERC_ButtonQuestionnaire)
        frame.origin.x = PERC_BlackWidth
    }
    
    init(originY : CGFloat, firstColumn : Bool) {
        if firstColumn {
            super.init(frame: CGRect(x: PERC_BlackWidth, y: originY, width: HalfScreenButtonWidth, height: PERC_ButtonQuestionnaire))
        } else {
            super.init(frame: CGRect(x: secondColOriginY, y: originY, width: HalfScreenButtonWidth, height: PERC_ButtonQuestionnaire))
        }
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        titleLabel?.textAlignment = NSTextAlignment.Center
        layer.borderColor = borderColorNormal
    }
}