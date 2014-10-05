//
//  tweetsViewControllerTableViewController.swift
//  twitterclient
//
//  Created by Jesse Smith on 9/27/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

class tweetsViewController: UITableViewController {

    var tweets: [Tweet]?
    var displayedTweet: Tweet?
    
    var refreshControlItem: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControlItem = UIRefreshControl()
        self.refreshControlItem.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControlItem)
        
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil,
            completion: { (tweets, error) in
                if error != nil {
                    println(error)
                    return
                }
                self.tweets = tweets
                println("Got \(self.tweets!.count) tweets")
                self.tableView.reloadData()
            }
        )

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func onRefresh() {
        println("refreshing!")
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil,
            completion: { (tweets, error) in
                if error != nil {
                    println(error)
                    return
                }
                self.tweets = tweets
                println("Got \(self.tweets!.count) tweets")
                self.tableView.reloadData()
                self.refreshControlItem.endRefreshing()
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
//        if tweets != nil {
//            return tweets!.count
//        }
        // return 0
        //Use this section to cache tweets to save api calls during dev
        return 20
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //Use this section to cache tweets to save api calls during dev
//        displayedTweet = tweets![indexPath.row]
        displayedTweet = tweets![0]
        return indexPath
    }
    
//    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) {
//    }
    
    
    @IBAction func signOut(sender: AnyObject) {
        User.currentUser!.logout()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as TweetCell

        // Configure the cell...
        //Use this section to cache tweets to save api calls during dev
//        var tweet = self.tweets![indexPath.row]
        var tweet = self.tweets![0]
        cell.tweetText.text = tweet.text
        cell.userImage.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!))
        
        cell.nameLabel.text = tweet.user?.name
        cell.handleLabel.text = "@\(tweet.user!.screenname!)"
        cell.timestampLabel.text = tweet.createdAt?.prettyTimestampSinceNow()

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
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
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
