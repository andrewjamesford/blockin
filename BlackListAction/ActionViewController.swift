//
//  ActionViewController.swift
//  BlackListAction
//
//  Created by Andrew Ford on 29/09/15.
//  Copyright © 2015 Andrew Ford. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    let defaults = NSUserDefaults.init(suiteName: "group.andrewford.com.BlockIn")
    let blockListKey = "BlacklistUrls"
    let lastListUpdated = "LastListUpdated"
    
    @IBOutlet weak var lblUrl: UILabel!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var imgCross: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgCheck.hidden = true
        imgCross.hidden = true
        btnComplete.backgroundColor = UIColor.cyanColor()
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var urlFound = false
        lblUrl.text = "Loading"
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {

                    itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            if let myUrl = url {
                                let unwrappedUrl:String = "\(myUrl)"
                                print(unwrappedUrl)

                                // Get the URL to get only the domain
                                let myNSUrl : NSURL? = NSURL(string: unwrappedUrl)
                                let host = myNSUrl?.host
                                print(host)
                                
                                self.lblUrl.text = host
                                
                                // Check item doesn't already exist
                                if (!self.checkUrlInBlockList(host!)) {
                                    
                                    // Save the url
                                    self.saveBlockListUrl(host!)

                                    self.imgCheck.hidden = false
                                }
                                else {
                                    self.imgCross.hidden = false
                                }
                                
                            }
                        }
                    })
                    
                    urlFound = true
                    break
                }
            }
            
            if (urlFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(sender: AnyObject) {
    
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func saveBlockListUrl(url:String) {
        
        var currentArry = getBlockListArray()
        
        currentArry.append(url)
        
        // Set arrary to NSDefaults
        defaults!.setObject(currentArry, forKey: blockListKey)
        
        // Set last update
        let currentDate = NSDate()
        defaults!.setObject(currentDate, forKey: lastListUpdated)
    }
    
    func checkUrlInBlockList(url:String) -> Bool {
        let currentArray = getBlockListArray()
        
        if currentArray.contains(url) {
            print("yes")
            return true
        }
        
        return false
    }
    
    func getBlockListArray() -> Array<String> {
        
        return defaults!.objectForKey(blockListKey) as? [String] ?? [String]()
        
    }

}
