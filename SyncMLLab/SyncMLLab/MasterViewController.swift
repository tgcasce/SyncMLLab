//
//  MasterViewController.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/20.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var fileWatcher: DirectoryWatcher! = nil
    var detailViewController: DetailViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fileWatcher = DirectoryWatcher.watchFolderWithPath(TGCFileManager.documentDirectory, delegate: self)

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers.last as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
        if segue.identifier == "showBackupArea" {
            controller.areaType = AreaType.BackupArea
        } else if segue.identifier == "showSyncArea" {
            controller.areaType = AreaType.SyncArea
        } else if segue.identifier == "showLocalArea" {
            
        }
    }


}

extension MasterViewController: DirectoryWatcherDelegate {
    func directoryDidChange(folderWatcher: DirectoryWatcher!) {
        
    }
}

extension MasterViewController {
    func documentDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!
    }
}