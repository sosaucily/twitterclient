//
//  ViewController.swift
//  twitterclient
//
//  Created by Jesse Smith on 9/27/14.
//  Copyright (c) 2014 Jesse Smith. All rights reserved.
//

import UIKit
import MoPub

class ViewController: UIViewController, MPAdViewDelegate {
    var adView: MPAdView = MPAdView(adUnitId: "c73dd1e07c8c406e8fe758e462a79b85", size: MOPUB_BANNER_SIZE)


    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.adView.delegate = self
        self.adView.frame = CGRectMake(0, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height,
            MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)
        self.view.addSubview(self.adView)
        self.adView.loadAd()
        
        loginButton.layer.borderColor = UIColor.blueColor().CGColor
        
    }
    
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error:NSError?) in
            if user != nil {
                self.performSegueWithIdentifier("loginSegue", sender: self)
                //perform segue
            } else {
                //handle login error
            }
        }
    }

}

