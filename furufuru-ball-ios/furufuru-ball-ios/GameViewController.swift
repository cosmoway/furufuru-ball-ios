//
//  GameViewController.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

var banner:GADBannerView!

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            scene.size.width = self.view.frame.width
            scene.size.height = self.view.frame.height
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        showAd()
    }
    
    func showAd() {
        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.frame.origin = CGPointMake(0, self.view.frame.size.height - banner.frame.height)
        banner.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        banner.delegate = self
        banner.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        banner.loadRequest(gadRequest)
        self.view.addSubview(banner)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    func adViewDidReceiveAd(adView: GADBannerView){
        print("adViewDidReceiveAd:\(adView)")
    }
    func adView(adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError){
        print("error:\(error)")
    }
    func adViewWillPresentScreen(adView: GADBannerView){
        print("adViewWillPresentScreen")
    }
    func adViewWillDismissScreen(adView: GADBannerView){
        print("adViewWillDismissScreen")
    }
    func adViewDidDismissScreen(adView: GADBannerView){
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(adView: GADBannerView){
        print("adViewWillLeaveApplication")
    }
}
