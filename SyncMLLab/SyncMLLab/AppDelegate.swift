//
//  AppDelegate.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/20.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        let reachability = Reachability(hostName: mainHost)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        reachability.startNotifier()
        
        return true
    }

    func reachabilityChanged(notification: NSNotification) {
        let reachability = notification.object as! Reachability
        if reachability.isReachable() == false {
            let alertController = UIAlertController(title: "网络不可用", message: "请检查您的网络连接！", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            return;
        }
        if reachability.isReachableViaWiFi() == false {
            let alertController = UIAlertController(title: "当前是非Wi-Fi环境", message: "使用上传功能将耗费大量流量！", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if TGCFileManager.defaultManager.fileInformations != nil {
            TGCFileManager.defaultManager.fileInformations.writeToFile(TGCFileManager.libraryDirectory.path!+"/"+syncStatusFile, atomically: true)
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if TGCFileManager.defaultManager.fileInformations != nil {
            TGCFileManager.defaultManager.fileInformations.writeToFile(TGCFileManager.libraryDirectory.path!+"/"+syncStatusFile, atomically: true)
        }
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        return true
    }

}

