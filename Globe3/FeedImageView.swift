//
//  FeedImageView.swift
//  Globe3
//
//  Created by Charles Masson on 17/10/15.
//  Copyright (c) 2015 Charles Masson. All rights reserved.
//

import UIKit

class FeedImageView : UIImageView {
    
    var tbeganY : CGFloat!
    var tendY : CGFloat!
    
    var id : Int!
    
    required init(coder : NSCoder){
        super.init(coder : coder)!
    }
    
    override init(image: UIImage!) {
        super.init(image: image)
    }
    
    init(image: UIImage!, id: Int) {
        super.init(image: image)
        self.id = id
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        let touch = touches.first
        tbeganY = touch!.locationInView(self).y
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if tbeganY != nil {
            let touch = touches.first
            tendY = touch!.locationInView(self).y
            
        }
    }
}
