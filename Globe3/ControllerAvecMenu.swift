//
//  ControllerAvecMenu.swift
//  Globe
//
//  Created by Charles Masson on 08/07/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit

class ControllerAvecMenu : UIViewController {
    
    var vMenu : UIView!
    var vMenuIndicator : UIView!
    var menuShowed = false
    var blurView = UIVisualEffectView()
    
    override func viewDidLoad() {
        buildMenu()
        
        blurView.frame = self.view.bounds
        blurView.backgroundColor = UIColor.clearColor()
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(barButtonToSearch))
        searchButton.tintColor = UIColor.blackColor()
        navigationItem.rightBarButtonItem = searchButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sandwich"), style: .Plain, target: self, action: #selector(showMenu))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    func showMenu() {
        if menuShowed {
            view.bringSubviewToFront(vMenu)
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = -PERC_MenuWidth
                self.blurView.effect = nil
                }, completion: { _ in
                    self.blurView.removeFromSuperview()
            })
            menuShowed = false
        } else {
            self.view.addSubview(blurView)
            view.bringSubviewToFront(vMenu)
            UIView.animateWithDuration(0.5, animations: {
                self.vMenu.frame.origin.x = 0.0
                self.blurView.effect = UIBlurEffect(style: .Light)
                }, completion: nil)
            menuShowed = true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if menuShowed {
            showMenu()
        }
    }
    
    func buildMenu(){
        vMenu = UIView(frame: CGRect(x: -PERC_MenuWidth, y: 64, width: PERC_MenuWidth, height: screenHeight - 64))
        vMenu.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 0.8)
        
        let bMenuFeed = MenuButton(text: "GLOBE FEED", originY: PERC_LightBrownHeight - PERC_BeigeHeight)
        let vBelowFeed = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMenuFeed.frame), width: separatorWidth, height: 1))
        vBelowFeed.backgroundColor = menuColor
        bMenuFeed.addTarget(self, action: #selector(popToFeed), forControlEvents: .TouchUpInside)
        
        vMenuIndicator = UIView(frame: CGRect(x: 0.0, y: bMenuFeed.frame.origin.y, width: PERC_MenuIndicatorWidth, height: PERC_BeigeHeight))
        vMenuIndicator.backgroundColor = MainBlueColor
        vMenu.addSubview(vMenuIndicator)
        
        let bLibrary = MenuButton(text: "LIBRARY", originY: CGRectGetMaxY(vBelowFeed.frame))
        let vBelowLib = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bLibrary.frame), width: separatorWidth, height: 1))
        vBelowLib.backgroundColor = menuColor
        bLibrary.addTarget(self, action: #selector(goToLibrary), forControlEvents: .TouchUpInside)
        
        let bMenuSearch = MenuButton(text: "SEARCH", originY: CGRectGetMaxY(vBelowLib.frame))
        let vBelowSearch = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMenuSearch.frame), width: separatorWidth, height: 1))
        vBelowSearch.backgroundColor = menuColor
        bMenuSearch.addTarget(self, action: #selector(goToSearch), forControlEvents: .TouchUpInside)
        
        let bMyCollection = MenuButton(text: "MY COLLECTION", originY: CGRectGetMaxY(vBelowSearch.frame))
        let vBelowMy = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bMyCollection.frame), width: separatorWidth, height: 1))
        vBelowMy.backgroundColor = menuColor
        bMyCollection.addTarget(self, action: #selector(goToMyCollection), forControlEvents: .TouchUpInside)
        
        let bAbout = MenuButton(text: "ABOUT GLOBE", originY: CGRectGetMaxY(vBelowMy.frame))
        let vBelowAbout = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(bAbout.frame), width: separatorWidth, height: 1))
        vBelowAbout.backgroundColor = menuColor
        bAbout.addTarget(self, action: #selector(goToAbout), forControlEvents: .TouchUpInside)
        
        vMenu.addSubview(bMenuFeed)
        vMenu.addSubview(vBelowFeed)
        vMenu.addSubview(bLibrary)
        vMenu.addSubview(vBelowLib)
        vMenu.addSubview(bMenuSearch)
        vMenu.addSubview(vBelowSearch)
        vMenu.addSubview(bMyCollection)
        vMenu.addSubview(vBelowMy)
        vMenu.addSubview(bAbout)
        vMenu.addSubview(vBelowAbout)
        self.view.addSubview(vMenu)
    }
    
    func barButtonToSearch(sender : UIBarButtonItem){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("search") as! SearchController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToSearch(sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("search") as! SearchController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToLibrary(sender : UIButton){
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y += PERC_BeigeHeight + 1
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("librarycontroller") as! LibraryController
                self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func goToMyCollection(sender : UIButton){
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y += (PERC_BeigeHeight + 1) * 3
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myCollec = storyboard.instantiateViewControllerWithIdentifier("mycollectioncontroller") as! MyCollectionController
                let trans = CATransition()
                trans.duration = 0.5
                trans.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                trans.type = kCATransitionMoveIn
                trans.subtype = kCATransitionFromLeft
                self.navigationController!.view.layer.addAnimation(trans, forKey: nil)
                self.navigationController?.pushViewController(myCollec, animated: false)
        })
    }
    
    func popToFeed(sender : UIButton) {
        
    }
    
    func goToAbout(sender : UIButton){
        UIView.animateWithDuration(0.5, animations: {
            self.vMenuIndicator.frame.origin.y += (PERC_BeigeHeight + 1) * 4
            }, completion: { _ in
                if self.menuShowed {
                    self.showMenu()
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : AboutController = storyboard.instantiateViewControllerWithIdentifier("aboutcontroller") as! AboutController
                self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}
