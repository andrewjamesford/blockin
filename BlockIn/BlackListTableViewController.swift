//
//  BlackListTableViewController.swift
//  BlockIn
//
//  Created by Andrew Ford on 27/09/15.
//  Copyright © 2015 Andrew Ford. All rights reserved.
//

import UIKit
import SafariServices

class BlackListTableViewController: UITableViewController {
    
    var blockListArray = []
    let fileBlockList = "blockerList.json"
    let whiteListTemplate: String = ""
    let defaults = NSUserDefaults.standardUserDefaults()
    let blockListKey = "BlacklistUrls"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blockListArray = getBlockListArray()
        //blockListArray = ["daringfireball.net","imore.com","loopinsight.com"]
        self.tableView.reloadData()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blockListArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("BlackListCell", forIndexPath: indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BlackListCell") as! BlackListTableViewCell

        let site = blockListArray[indexPath.row] as! String
        
        // Configure the cell...
        cell.configureCell(site)

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - JSON/NSUserDefault classes
    func refreshBlockList() {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("andrewford.com.BlockIn.ContentBlocker",
            completionHandler:{(error: NSError?) in
                print ("SFContentBlockerManager.reloadContentBlockerWithIdentifier")
                print (error?.localizedDescription)
        })
    }
    
    
    func writeFile() {
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileBlockList);
            
            //writing
            do {
                let jsonString = buildRulesJson()
                try jsonString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
                /* error handling here */
                print("An error occured")
            }
        }
    }
    
    func buildRulesJson() -> String {
        
        let blockListArray = getBlockListArray()
        var stringOfJson = ""
        
        // For loop for array
        for url:String in blockListArray {
            // use template and append
            stringOfJson += "{\"action\": {\"type\": \"block\"}, \"trigger\": {\"url-filter\": \".*\", \"resource-type\": [\"script\"], \"load-type\": [\"third-party\"], \"if-domain\": [\"*\(url)\"] } }"
        }
        
        // prefix of [
        stringOfJson = "[" + stringOfJson
        
        // suffix of ]
        stringOfJson = stringOfJson + "]"
        
        return stringOfJson
    }
    
    func saveBlockListUrl(url:String) {
        
        var currentArry = getBlockListArray()
        
        currentArry.append(url)
        
        // Set arrary to NSDefaults
        defaults.setObject(currentArry, forKey: blockListKey)
    }
    
    func getBlockListArray() -> Array<String> {
        
        return defaults.objectForKey(blockListKey) as? [String] ?? [String]()
        
    }

    
}
