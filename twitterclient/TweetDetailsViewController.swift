//
//  TweetDetails.swift
//  twitterclient
//
//  Created by Jesse Smith on 9/27/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweenButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    var tweet: Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tweet = getTweetFromNavStack()
        
        displayDataFromTweet()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func getTweetFromNavStack() -> Tweet? {
//        var vcs = self.navigationController?.viewControllers
//        var vc = vcs?[0] as? tweetsViewController
//        return vc?.displayedTweet
//    }
    
    func displayDataFromTweet() {
        var imageUrl: String = tweet!.user!.profileImageUrl!
        
        userImage?.setImageWithURL(NSURL(string: imageUrl))

        nameLabel.text = tweet!.user!.name
        handleLabel.text = "@\(tweet!.user!.screenname!)"
        tweetText.text = tweet!.text
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy',' hh:mm a"
        var dateString = formatter.stringFromDate(tweet!.createdAt!)
        timestampLabel.text = dateString
        
        retweetsLabel.text = "\(tweet!.retweetCount!) RETWEETS \(tweet!.favoriteCount!) FAVORITES"
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        println("favorite!")
        TwitterClient.sharedInstance.favorite(self.tweet!.id!)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        println("retweet!")
        TwitterClient.sharedInstance.retweet(self.tweet!.id!)
    }
    
    @IBAction func onReply(sender: AnyObject) {
        println("reply!")
        self.performSegueWithIdentifier("replySegue", sender: self)
//        TwitterClient.sharedInstance.reply(, tweetId: <#Int#>)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        var dest_vc = segue.destinationViewController as ComposeViewController
        dest_vc.baseTweetText = "@\(tweet!.user!.screenname!)"
    }
}
