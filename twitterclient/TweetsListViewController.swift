//
//  TweetsListViewController.swift
//  twitterclient
//
//  Created by Jesse Smith on 10/5/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

class TweetsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var cacheStuff = false
    
    var tweets: [Tweet]?
    var mentions: [Tweet]?
    var displayedTweet: Tweet?
    var refreshControlItem: UIRefreshControl!
    var mentionRefreshControlItem: UIRefreshControl!
    
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
    
    
    //Mentions View Stuff
    @IBOutlet weak var mentionsTable: UITableView!
    
    
    //Profile View Stuff
    @IBOutlet weak var ProfileBackgroundImage: UIImageView!
    @IBOutlet weak var profileStats: UILabel!
    
    func tapTweetOwnerImage(sender: UITapGestureRecognizer) {

        var cell = sender.view as TweetCell
        var location = sender.locationInView(cell)
        if (cell.userImage.pointInside(location, withEvent: nil))
        {
            println("clicked image")
            var handle = cell.handleLabel.text
    
            fetchProfileAndShow(handle!)
        } else {
            displayedTweet = cell.theTweet
            performSegueWithIdentifier("showTweetSegue", sender: self)
        }
    }
    
    @IBAction func SidebarClick(sender: UIButton) {
        if (sender == profileButton) {
            showProfileView()
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
    
    func showProfileView() {
        profileViewCenterXConstraint.constant = 0
        tableViewCenterXConstraint.constant = -1000
        mentionsViewCenterXConstraint.constant = -1000
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
        
        self.containerViewCenterXConstraint.constant = 0
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.mentionsTable.estimatedRowHeight = 200
        self.mentionsTable.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControlItem = UIRefreshControl()
        self.refreshControlItem.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControlItem)

        self.mentionRefreshControlItem = UIRefreshControl()
        self.mentionRefreshControlItem.addTarget(self, action: "onMentionRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.mentionsTable.addSubview(mentionRefreshControlItem)
        
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

        TwitterClient.sharedInstance.mentionTimelineWithCompletion(nil,
            completion: { (tweets, error) in
                if error != nil {
                    println(error)
                    return
                }
                self.mentions = tweets
                println("Got \(self.mentions!.count) mentions")
                self.mentionsTable.reloadData()
            }
        )
        
        setupProfileView()
        
           // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchProfileAndShow(handle: String) {
        println("got handle \(handle)")
        
        TwitterClient.sharedInstance.getUser(handle, completion: {(userData: NSDictionary) in
                println("got data for user \(userData)")
                self.setupProfileView(pUser: User(dictionary: userData))
                self.showProfileView()
            }
        )
    }
    
    func setupProfileView(pUser: User? = nil) {
        var user = pUser
        if (pUser == nil){
            user = User.currentUser!
        }
        if (user!.profileBannerUrl != nil){
            ProfileBackgroundImage.setImageWithURL(NSURL(string: user!.profileBannerUrl!))
        }
        let tweets = user!.numTweets!
        let followers = user!.numFollowers!
        let following = user!.numFollowing!
        profileStats.text = "\(tweets) Tweets - \(followers) Followers - \(following) Following"
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
        if (cacheStuff) {
            return 20
        }
        if (tableView == self.tableView) {
            if tweets != nil {
                return tweets!.count
            }
        }
        if (tableView == self.mentionsTable) {
            if mentions != nil {
                return mentions!.count
            }
        }
        return 0
    }
    
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        //Use this section to cache tweets to save api calls during dev
//        if (cacheStuff) {
//            if (tableView == self.tableView) {
//                displayedTweet = tweets![0]
//            }
//            if (tableView == mentionsTable) {
//                displayedTweet = mentions![0]
//            }
//            return indexPath
//        }
//
//        if (tableView == self.tableView) {
//            displayedTweet = tweets![indexPath.row]
//        }
//        if (tableView == self.mentionsTable) {
//            displayedTweet = mentions![indexPath.row]
//        }
//        
//        return indexPath
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as TweetCell
        
        // Configure the cell...
        //Use this section to cache tweets to save api calls during dev
        //        var tweet = self.tweets![indexPath.row]
        var index = 0
        
        if (!cacheStuff) {
            index = indexPath.row
        }
        
        var tweet: Tweet?
        
        if (tableView == self.tableView) {
            tweet = self.tweets![index]
        }
        if (tableView == mentionsTable) {
            tweet = self.mentions![index]
        }
        cell.theTweet = tweet
        
        cell.tweetText.text = tweet!.text
        cell.userImage.setImageWithURL(NSURL(string: tweet!.user!.profileImageUrl!))
        
        cell.nameLabel.text = tweet!.user?.name
        cell.handleLabel.text = "@\(tweet!.user!.screenname!)"
        cell.timestampLabel.text = tweet!.createdAt?.prettyTimestampSinceNow()
        
        let gr = UITapGestureRecognizer(target: self, action: "tapTweetOwnerImage:")
//        cell.userInteractionEnabled = true
        cell.addGestureRecognizer(gr)
        return cell
    }
    
    func onRefresh() {
        println("refreshing tweets")
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
    
    func onMentionRefresh() {
        println("refreshing mentions")
        TwitterClient.sharedInstance.mentionTimelineWithCompletion(nil,
            completion: { (tweets, error) in
                if error != nil {
                    println(error)
                    return
                }
                self.mentions = tweets
                println("Got \(self.mentions!.count) mentions")
                self.mentionsTable.reloadData()
                self.mentionRefreshControlItem.endRefreshing()
            }
        )
    }
}
