//
//  TwitteClient.swift
//  twitterclient
//
//  Created by Jesse Smith on 9/27/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

let tweetsKey = "tweetsKey"

let twitterConsumerKey = "vSayfCizaCV18XwUjI0KssH6o"
let twitterConsumerSecret = "2RkNWN6Gx4U8wZAKKUAqXBXbXQm5tI77yrNy9mKQv0eSAZlKyg"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
            
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        //Fetch request token and redirect to twitter auth page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "cptwitterdemo://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuthToken!) -> Void in
                var authUrl = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(authUrl)
            },
            failure: { (error: NSError!) -> Void in
                println("Error fetching token!")
                self.loginCompletion?(user: nil, error: error)
            }
        )
    }
    
    func homeTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {

        var _tweetData = NSUserDefaults.standardUserDefaults().objectForKey(tweetsKey) as? NSData
        if _tweetData != nil {
            var _tweet = NSJSONSerialization.JSONObjectWithData(_tweetData!, options: nil, error: nil) as? NSDictionary
            var tweets = Tweet.tweetsWithArray([_tweet!])
            completion(tweets: tweets, error: nil)
            return
        }
        
        GET("1.1/statuses/home_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println("received home timeline")

                var tweets = Tweet.tweetsWithArray(response as [NSDictionary])
            
                var serializedTweets = NSJSONSerialization.dataWithJSONObject(response[0], options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(serializedTweets, forKey: tweetsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                completion(tweets: tweets, error: nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting home timeline")
                completion(tweets: nil, error: error)
            }
        )
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath(
            "oauth/access_token",
            method: "POST",
            requestToken: BDBOAuthToken(queryString: url.query),
            success: { (accessToken: BDBOAuthToken!) -> Void in
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                
                TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json",
                    parameters: nil,
                    success: { (operation: AFHTTPRequestOperation!,
                        response: AnyObject!) -> Void in
                        var user = User(dictionary: response as NSDictionary)
                        User.currentUser = user
                        self.loginCompletion?(user: user, error: nil)
                    },
                    failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        println("error getting current user")
                        self.loginCompletion?(user: nil, error: error)
                    }
                )
            },
            failure: { (error: NSError!) -> Void in
                println("Failed to get access token")
            }
        )
    }

}
