//
//  CuratedCollectionController.swift
//  Globe
//
//  Created by Charles Masson on 03/03/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit
import Parse

class CuratedCollectionController : UIViewController {
    
    @IBOutlet var scMain : UIScrollView!
    @IBOutlet var vTitle : UIView!
    @IBOutlet var lTitle : UILabel!
    @IBOutlet var vContainer : UIView!
    @IBOutlet var lDescription : UILabel!
    @IBOutlet var scBooks : UIScrollView!
    
    var bonusCatId : Int!
    var bonusCatName : String!
    var bonusCatDescription : String!
    
    var query : PFQuery!
    var bookCounter = 0
    
    override func viewDidLoad() {
        
        self.navigationItem.title = "Curated Collection"
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        
        let ivHeader = UIImageView()
        setImageHeader(ivHeader)
        ivHeader.frame.origin.x = 0.0
        ivHeader.frame.origin.y = 0.0
        ivHeader.frame.size.width = screenWidth
        ivHeader.frame.size.height = PERC_LibHeaderHeight
        ivHeader.contentMode = UIViewContentMode.ScaleAspectFill
        ivHeader.clipsToBounds = true
        scMain.addSubview(ivHeader)
        
        vTitle.frame = CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(ivHeader.frame) + PERC_BlueHeight, width: AlmostFullWidth, height: PERC_TitlePurpleHeight)
        
        lTitle.text = bonusCatName
        lTitle.sizeToFit()
        lTitle.frame.origin.x = 10
        lTitle.center.y = vTitle.frame.size.height / 2
        
        vContainer.frame.origin = CGPoint(x: PERC_BlackWidth, y: CGRectGetMaxY(vTitle.frame))
        vContainer.frame.size.width = AlmostFullWidth
        
        //let fontColor = UIColor(red: 88 / 255, green: 91 / 255, blue: 1, alpha: 1)
        lDescription.text = bonusCatDescription
        lDescription.sizeToFit()
        //lDescription.textColor = fontColor
        lDescription.frame.size.width = AlmostFullWidth - 2 * PERC_BlackWidth
        lDescription.frame.origin.y = PERC_GreenHeight
        
        scBooks.frame.size.height = PERC_LibCoverHeight
        scBooks.frame.size.width = AlmostFullWidth
        scBooks.frame.origin.y = PERC_DarkPurpleHeight + CGRectGetMaxY(lDescription.frame)
        scBooks.frame.origin.x = 0
        searchBooks()
        
        vContainer.frame.size.height = CGRectGetMaxY(scBooks.frame) + PERC_DarkRedHeight
        scMain.frame.size.height = screenHeight
        scMain.frame.size.width = screenWidth
        scMain.contentSize.height = CGRectGetMaxY(vContainer.frame) + PERC_DarkRedHeight
    }
    
    func setImageHeader(iv : UIImageView) {
        let q = PFQuery(className: "Images")
        q.whereKey("imageId", equalTo: "libraryheader")
        q.getFirstObjectInBackgroundWithBlock{(o: PFObject?, error: NSError?) -> Void in
            if error == nil {
                if o != nil {
                    if let i = o!.objectForKey("image") as? PFFile {
                        i.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    let img = UIImage(data: data!)
                                    iv.image = img
                                    print("img set")
                                })
                            } else {
                                print(error)
                            }
                        })
                    }
                }
            } else { print(error) }
        }
    }
    
    func searchBooks(){
        query = PFQuery(className:"Book")
        query.whereKey("category", containsString: "bonuscategory\(bonusCatId)")
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) books from category")
                
                if let objects = objects {
                    for object in objects {
                        print(object.objectId)
                        //We create a view for each book
                        let ivCover = UIImageView(frame: CGRect(x: PERC_DarkRedWidth + CGFloat(self.bookCounter) * (PERC_DarkRedWidth + PERC_LibCoverWidth), y: 0.0, width: PERC_LibCoverWidth, height: PERC_LibCoverHeight))
                        
                        let bId = UIButton(frame: ivCover.frame)
                        bId.frame.origin = CGPoint(x: 0.0, y: 0.0)
                        if let uProfilePict = object.objectForKey("covermini") as? PFFile {
                            uProfilePict.getDataInBackgroundWithBlock({(data: NSData?, error: NSError?) -> Void in
                                if error == nil {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let img = UIImage(data: data!)
                                        ivCover.image = img
                                    })
                                } else {
                                    print(error)
                                }
                            })
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            //The id of the book
                            bId.setTitle(object.objectId, forState: UIControlState.Normal)
                            bId.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0), forState: UIControlState.Normal)
                            bId.addTarget(self, action: #selector(CuratedCollectionController.bookClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                            self.scBooks.addSubview(ivCover)
                            ivCover.addSubview(bId)
                            ivCover.userInteractionEnabled = true
                            self.scBooks.contentSize = CGSize(width: CGRectGetMaxX(ivCover.frame) + PERC_DarkRedWidth, height: self.scBooks.frame.size.height)
                        })
                        self.bookCounter += 1
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    @IBAction func bookClicked(sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : BookDescriptionController = storyboard.instantiateViewControllerWithIdentifier("bookdescription") as! BookDescriptionController
        
        let iv = sender.superview as! UIImageView
        if iv.image != nil {
            vc.bookCover = iv.image!
        }
        vc.bookId = sender.titleLabel?.text
        var backText = bonusCatName!
        if backText.characters.count > 12 {
            backText = (backText as NSString).substringToIndex(12)
            backText += "..."
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: backText, style: .Plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
