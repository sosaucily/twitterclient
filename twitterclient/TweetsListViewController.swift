//
//  TweetsListViewController.swift
//  twitterclient
//
//  Created by Jesse Smith on 10/5/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

class TweetsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tweets: [Tweet]?
    var displayedTweet: Tweet?
    var refreshControlItem: UIRefreshControl!
    
    var currentView: UIView?

    @IBOutlet weak var composeButton: UIButton!
    @IBOutlet weak var tableView: TweetsUITableView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var timelineButton: UIButton!
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var mentionsButton: UIButton!
    @IBOutlet weak var containerViewCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileViewCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mentionsViewCenterXConstraint: NSLayoutConstraint!
    
    var vcs: [UIViewController] = [UIViewController(), UIViewController()]
    var currentVC: UIViewController?
    
    @IBAction func SidebarClick(sender: UIButton) {
        if (sender == profileButton) {
            profileViewCenterXConstraint.constant = 0
            tableViewCenterXConstraint.constant = -1000
            mentionsViewCenterXConstraint.constant = -1000
        }
        if (sender == timelineButton) {
            tableViewCenterXConstraint.constant = 0
            profileViewCenterXConstraint.constant = -1000
            mentionsViewCenterXConstraint.constant = -1000
        }
        if (sender == mentionsButton) {
            mentionsViewCenterXConstraint.constant = 0
            profileViewCenterXConstraint.constant = -1000
            tableViewCenterXConstraint.constant = -1000
        }
        
        self.containerViewCenterXConstraint.constant = 0
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == UISwipeGestureRecognizerDirection.Right) {
            if sender.state == .Ended {
                self.containerViewCenterXConstraint.constant = -165
            }
        }
        
        if (sender.direction == UISwipeGestureRecognizerDirection.Left) {
            if sender.state == .Ended {
                self.containerViewCenterXConstraint.constant = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcs[0].view = tableView
        vcs[1].view = profileView
        
        self.containerViewCenterXConstraint.constant = 0
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControlItem = UIRefreshControl()
        self.refreshControlItem.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControlItem)
//        
//        if (currentView == nil) {
//            currentView = tableView
//            currentVC = vcs[0]
//        }
        
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if(sender as? NSObject != composeButton) {
            var detailViewController = segue.destinationViewController as TweetDetailsViewController
            detailViewController.tweet = displayedTweet
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        //        if tweets != nil {
        //            return tweets!.count
        //        }
        // return 0
        //Use this section to cache tweets to save api calls during dev
        return 20
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //Use this section to cache tweets to save api calls during dev
        //        displayedTweet = tweets![indexPath.row]
        displayedTweet = tweets![0]
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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

}
