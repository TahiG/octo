//
//  Functions.swift
//  Globe
//
//  Created by Charles Masson on 16/02/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import Foundation

class Functions {
    
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    class func getAgeCarouselText(id : Int) -> String {
            switch id {
            case 0: return "12 - 17"
            case 1: return "18 - 24"
            case 2: return "25 - 34"
            case 3: return "35 - 44"
            case 4: return "45 - 54"
            case 5: return "55 - 64"
            case 6: return "65+"
            default: return ""
            }
    }
    
    class func getAgeCarouselId(text : String) -> Int {
        switch text {
        case "12 - 17": return 0
        case "18 - 24": return 1
        case "25 - 34": return 2
        case "35 - 44": return 3
        case "45 - 54": return 4
        case "55 - 64": return 5
        case "65+": return 6
        default: return -1
        }
    }
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}