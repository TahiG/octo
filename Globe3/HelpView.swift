//
//  HelpView.swift
//  Globe
//
//  Created by Charles Masson on 28/02/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit


let helpFontBold = UIFont(name: "MuseoSans-700", size: 18)
let helpFont = UIFont(name: "MuseoSans-300", size: 18)


class HelpView: UIView {
    
    var text : String!
    var hiding = false
    var attrText : NSMutableAttributedString!
    
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(text : String) {
        super.init(frame: CGRect(x: PERC_BlackWidth, y: 0, width: AlmostFullWidth, height: 0))
        
        self.text = text
        self.backgroundColor = UIColor.whiteColor()
        addLabel()
        
        self.layer.cornerRadius = 6
        self.layer.borderColor = UIColor(red: 175 / 255, green: 173 / 255, blue: 173 / 255, alpha: 1).CGColor
        self.layer.borderWidth = 1
    }
    
    init(text : String, arrow : Bool, origin : CGFloat) {
        super.init(frame: CGRect())
        
        self.text = text
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        addLabel()
        
        self.frame.origin.y = origin
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 6, 10.0)
        CGPathAddLineToPoint(path, nil, self.center.x - 10, 10)
        CGPathAddLineToPoint(path, nil, self.center.x, 0)
        CGPathAddLineToPoint(path, nil, self.center.x + 10, 10)
        CGPathAddLineToPoint(path, nil, self.frame.size.width - 6, 10)
        CGPathAddArcToPoint(path, nil, self.frame.size.width, 10, self.frame.size.width, 16, 6)
        CGPathAddLineToPoint(path, nil, self.frame.size.width, self.frame.size.height - 6)
        CGPathAddArcToPoint(path, nil, self.frame.size.width, self.frame.size.height, self.frame.size.width - 6, self.frame.size.height, 6)
        CGPathAddLineToPoint(path, nil, 6, self.frame.size.height)
        CGPathAddArcToPoint(path, nil, 0, self.frame.size.height, 0, self.frame.size.height - 6, 6)
        CGPathAddLineToPoint(path, nil, 0, 16)
        CGPathAddArcToPoint(path, nil, 0, 10, 6, 10, 6)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayer.position = CGPoint(x: 0.0, y: 0.0)
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        shapeLayer.strokeColor = UIColor(red: 175 / 255, green: 173 / 255, blue: 173 / 255, alpha: 1).CGColor
        shapeLayer.fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).CGColor
        self.layer.addSublayer(shapeLayer)
        self.bringSubviewToFront(label)
    }
    
    func addLabel() {
        attrText = NSMutableAttributedString(string: text)
        attrText.beginEditing()
        attrText.addAttribute(kCTFontAttributeName as String, value: helpFont!, range: NSMakeRange(0, attrText.length))
        label.frame.origin = CGPoint(x: PERC_DarkRedWidth, y: PERC_DarkRedWidth + 10)
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.attributedText = attrText
        label.frame.size.width = AlmostFullWidth - 2 * PERC_DarkRedWidth
        label.sizeToFit()
        
        self.frame.size = CGSize(width: AlmostFullWidth, height: label.frame.size.height + 2 * PERC_BlackWidth)
        label.center = CGPoint(x: AlmostFullWidth / 2, y: self.frame.size.height / 2)
        self.addSubview(label)
    }
    
    func setBold(range : NSRange) {
        attrText.beginEditing()
        attrText.addAttribute(kCTFontAttributeName as String, value: helpFontBold!, range: range)
        attrText.endEditing()
        label.attributedText = attrText
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        disappear()
    }
    
    func disappear() {
        if !self.hiding {
            hiding = true
            
            UIView.animateWithDuration(0.2, animations: {
                self.alpha = 0
                }, completion: { _ in
                    self.hidden = true
            })
        }
    }
}
