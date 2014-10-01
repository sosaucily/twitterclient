//
//  ComposeViewController.swift
//  twitterclient
//
//  Created by Jesse Smith on 9/27/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    var baseTweetText = ""

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetTextArea: UITextView!
    @IBOutlet weak var textFieldBottomContraint: NSLayoutConstraint!

    var tweetButton: UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = User.currentUser?.name
        handleLabel.text = User.currentUser?.screenname
        userImage.setImageWithURL(NSURL(string: User.currentUser!.profileImageUrl!))
        
        tweetTextArea.text = baseTweetText
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                let value = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
                let rect = value.CGRectValue()
                self.textFieldBottomContraint.constant = rect.size.height
                return ()
        }
    }

    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doTweet(sender: AnyObject) {
        println("tweeeeet")
        TwitterClient.sharedInstance.tweet(self.tweetTextArea.text)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
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
