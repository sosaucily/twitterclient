//
//  TwitteClient.swift
//  twitterclient
//
//  Created by Jesse Smith on 9/27/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit

let cacheStuff = false

let tweetsKey = "tweetsKey"
let mentionsKey = "mentionsKey"

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
    
    func tweet(message: NSString) {
        var params = ["status":message]
        
        POST("1.1/statuses/update.json", parameters: params, success: { (operation, response) -> Void in
                println("you tweeted!")
        }, { (operation, error) -> Void in
            println("error tweeting")
            println(error)
        })
    }

    func reply(message: NSString, tweetId: Int) {
        var params = ["status":message, "in_reply_to_status_id":tweetId]
        
        POST("1.1/statuses/update.json", parameters: params, success: { (operation, response) -> Void in
            println("you replied!")
            }, { (operation, error) -> Void in
                println("error replying")
                println(error)
        })
    }
    
    func retweet(tweetId: Int) {
        var params = ["id":tweetId]
        
        POST("1.1/statuses/retweet/\(tweetId).json", parameters: params, success: { (operation, response) -> Void in
            println("you retweeted!")
            }, { (operation, error) -> Void in
                println("error retweeting")
                println(error)
        })
    }
    
    func favorite(tweetId: Int) {
        var params = ["id":tweetId]
        
        POST("1.1/favorites/create.json", parameters: params, success: { (operation, response) -> Void in
            println("you favorited!")
            }, { (operation, error) -> Void in
                println("error favoriting")
                println(error)
        })
    }
    
    func getUser(screen_name: String, completion: (userData: NSDictionary) -> ()) {
        var params = ["screen_name":screen_name]
        
        GET("1.1/users/show.json", parameters: params, success: { (operation, response) -> Void in
                println("fetch info for user \(screen_name)!")
                completion(userData: response as NSDictionary)
            }, { (operation, error) -> Void in
                println("error getting info for user")
                println(error)
        })
    }
    
    
    func homeTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {

        //Use this section to cache tweets to save api calls during dev
        if (cacheStuff) {
            var _tweetData = NSUserDefaults.standardUserDefaults().objectForKey(tweetsKey) as? NSData
            if _tweetData != nil {
                var _tweet = NSJSONSerialization.JSONObjectWithData(_tweetData!, options: nil, error: nil) as? NSDictionary
                var tweets = Tweet.tweetsWithArray([_tweet!])
                completion(tweets: tweets, error: nil)
                return
            }
        }
        
        GET("1.1/statuses/home_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println("received home timeline")

                var tweets = Tweet.tweetsWithArray(response as [NSDictionary])
            
                        //Use this section to cache tweets to save api calls during dev
                if (cacheStuff) {
                    var serializedTweets = NSJSONSerialization.dataWithJSONObject(response[0], options: nil, error: nil)
                    NSUserDefaults.standardUserDefaults().setObject(serializedTweets, forKey: tweetsKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                completion(tweets: tweets, error: nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting home timeline")
                completion(tweets: nil, error: error)
            }
        )
    }
    
    
    func mentionTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        
        //Use this section to cache tweets to save api calls during dev
        if (cacheStuff) {
            var _tweetData = NSUserDefaults.standardUserDefaults().objectForKey(mentionsKey) as? NSData
            if _tweetData != nil {
                var _tweet = NSJSONSerialization.JSONObjectWithData(_tweetData!, options: nil, error: nil) as? NSDictionary
                var tweets = Tweet.tweetsWithArray([_tweet!])
                completion(tweets: tweets, error: nil)
                return
            }
        }
        
        GET("1.1/statuses/mentions_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println("received mentions timeline")
                
                var tweets = Tweet.tweetsWithArray(response as [NSDictionary])
                
                //Use this section to cache tweets to save api calls during dev
                if (cacheStuff) {
                    var serializedTweets = NSJSONSerialization.dataWithJSONObject(response[0], options: nil, error: nil)
                    NSUserDefaults.standardUserDefaults().setObject(serializedTweets, forKey: mentionsKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                completion(tweets: tweets, error: nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting mentions timeline")
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
