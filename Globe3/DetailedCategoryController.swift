//
//  DetailedCategoryController.swift
//  Globe
//
//  Created by Charles Masson on 05/03/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import UIKit
import Parse

class DetailedCategoryController: UIViewController {
    
    @IBOutlet var scMain : UIScrollView!
    var ivHeader : UIImageView!
    
    let titleFont = UIFont(name: "Interstate-Regular", size: 17)
    let colVContainer = UIColor(red: 245/255, green: 246/255, blue: 253/255, alpha: 1.0)
    let colClassicBlue = UIColor(red: 88/255, green: 91/255, blue: 229/255, alpha: 1.0)
    let colVRedContainer = UIColor(red: 255/255, green: 235/255, blue: 232/255, alpha: 1.0)
    let colClassicRed = UIColor(red: 255/255, green: 60/255, blue: 0/255, alpha: 1.0)
    let containerHeight = 2 * PERC_GreenHeight + 2 * PERC_LibCoverHeight + PERC_DarkRedWidth
    
    
    var subCategories : NSArray!
    var catTitle : String!
    
    var mainQueries = NSMutableArray()
    
    var nextColorIsBlue = true
    
    override func viewDidLoad() {
        
        self.navigationItem.title = catTitle
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        ivHeader = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: PERC_LibHeaderHeight))
        setImageHeader(ivHeader)
        ivHeader.contentMode = UIViewContentMode.ScaleAspectFill
        ivHeader.clipsToBounds = true
        scMain.addSubview(ivHeader)
        
        scMain.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        scMain.showsVerticalScrollIndicator = false
        var originY = CGRectGetMaxY(ivHeader.frame)
        for cat in subCategories {
            originY = buildScrollViews(cat as! String, originY: originY)
        }
        
        scMain.contentSize.height = originY + 10
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
    
    func buildScrollViews(cat : String, originY : CGFloat) -> CGFloat {
        let vLab = UIView(frame: CGRect(x: PERC_BlackWidth, y: PERC_BlueHeight + originY, width: AlmostFullWidth, height: PERC_TitlePurpleHeight))
        let lTitle = UILabel()
        lTitle.text = cat.uppercaseString
        lTitle.font = titleFont
        lTitle.sizeToFit()
        lTitle.frame.size.height = PERC_TitlePurpleHeight
        lTitle.frame.origin = CGPoint(x: 10, y: 0)
        lTitle.textColor = UIColor.whiteColor()
        vLab.addSubview(lTitle)
        scMain.addSubview(vLab)
        let vContainer = UIView(frame: CGRect(x: PERC_BlackWidth, y: CGRectGetMaxY(vLab.frame), width: AlmostFullWidth, height: containerHeight))
        let scFeatured = UIScrollView()
        scFeatured.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scFeatured.frame = CGRect(x: 0, y: PERC_GreenHeight, width: AlmostFullWidth, height: PERC_LibCoverHeight)
        searchBooks(cat, sv: scFeatured, latest: false)//GETTING THE BOOKS HERE
        vContainer.addSubview(scFeatured)
        let scLatest = UIScrollView()
        scLatest.showsHorizontalScrollIndicator = false   //Update 17/11 or so
        scLatest.frame = CGRect(x: 0, y: PERC_GreenHeight + CGRectGetMaxY(scFeatured.frame), width: AlmostFullWidth, height: PERC_LibCoverHeight)
        searchBooks(cat, sv: scLatest, latest: true)//GETTING THE BOOKS HERE
        vContainer.addSubview(scLatest)
        scMain.addSubview(vContainer)
        
        if nextColorIsBlue {
            //nextColorIsBlue = false
            vContainer.backgroundColor = colVContainer
            vLab.backgroundColor = colClassicBlue
        } else {
            nextColorIsBlue = true
            vContainer.backgroundColor = colVRedContainer
            vLab.backgroundColor = colClassicRed
        }
        
        return CGRectGetMaxY(vContainer.frame)
    }
    
    func searchBooks(cat : String, sv : UIScrollView, latest : Bool){
        //Query
        let query = PFQuery(className:"Book")
        query.whereKey("subcategory", containsString: cat)
        query.whereKey("latest", equalTo: latest)
        //To cancel the queries, we keep a reference of them
        self.mainQueries.addObject(query)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) books from \(cat) category")
                
                if let objects = objects {
                    var counter = 0
                    for object in objects {
                        print(object.objectId)
                        //We create a view for each book
                        let ivCover = UIImageView(frame: CGRect(x: PERC_DarkRedWidth + CGFloat(counter) * (PERC_DarkRedWidth + PERC_LibCoverWidth), y: 0.0, width: PERC_LibCoverWidth, height: PERC_LibCoverHeight))
                        
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
                            bId.addTarget(self, action: #selector(DetailedCategoryController.bookClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                            sv.addSubview(ivCover)
                            ivCover.addSubview(bId)
                            ivCover.userInteractionEnabled = true
                            sv.contentSize = CGSize(width: CGRectGetMaxX(ivCover.frame) + PERC_DarkRedWidth, height: sv.frame.size.height)
                        })
                        counter += 1
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
        var backText : String = catTitle
        
        if backText.characters.count > 12 {
            backText = (backText as NSString).substringToIndex(12)
            backText += "..."
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: backText, style: .Plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
