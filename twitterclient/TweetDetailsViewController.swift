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
    
    
    var tweetDelegate: Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetDelegate = getTweetFromNavStack()
        
        displayDataFromTweet()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTweetFromNavStack() -> Tweet? {
        var vcs = self.navigationController?.viewControllers
        var vc = vcs?[0] as? tweetsViewController
        return vc?.displayedTweet
    }
    
    func displayDataFromTweet() {
        var imageUrl: String = tweetDelegate!.user!.profileImageUrl!
        
        userImage?.setImageWithURL(NSURL(string: imageUrl))

        nameLabel.text = tweetDelegate!.user!.name
        handleLabel.text = "@\(tweetDelegate!.user!.screenname!)"
        tweetText.text = tweetDelegate!.text
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy',' hh:mm a"
        var dateString = formatter.stringFromDate(tweetDelegate!.createdAt!)
        timestampLabel.text = dateString
        
        retweetsLabel.text = "\(tweetDelegate!.retweetCount!) RETWEETS \(tweetDelegate!.favoriteCount!) FAVORITES"
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
