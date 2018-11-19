//
//  DashedBorderView.swift
//  Globe3
//
//  Created by Charles Masson on 17/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class DashedBorderView : UIView {
    
    var bord: CAShapeLayer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        bord = CAShapeLayer();
        
        bord.strokeColor = UIColor.blueColor().CGColor;
        bord.fillColor = nil;
        bord.lineDashPattern = [4, 2];
        self.layer.addSublayer(bord);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        /*bord = CAShapeLayer();
        
        bord.strokeColor = UIColor.blueColor().CGColor;
        bord.fillColor = nil;
        bord.lineDashPattern = [4, 4];
        self.layer.addSublayer(bord);*/
    }
    
   /* override func layoutSubviews() {
        super.layoutSubviews()
        bord.path = UIBezierPath(roundedRect: self.bounds, cornerRadius:0).CGPath;
        bord.frame = self.bounds;
    }*/
}
