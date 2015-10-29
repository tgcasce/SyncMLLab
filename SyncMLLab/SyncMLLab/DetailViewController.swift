//
//  DetailViewController.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/20.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var currentPath: String = TGCFileManager.documentDirectory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureView() {
        
    }
    
    
    //MARK: - UITableViewDataSource, UITableViewDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell", forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "文件夹"
        } else {
            return "文件"
        }
    }
    
    
    func request(sender: AnyObject) {
        
//        TGCFileManager.defaultManager.scanCurrentPath()
//        for URL in TGCFileManager.defaultManager.currentDirectories {
//            print(TGCFileManager.defaultManager.getNameBy(URL))
//        }
//        TGCFileManager.defaultManager.uploadFileInBackupAreaWith(filePath: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!+"/transfer_xml.php")

//        TGCFileManager.defaultManager.putFileFromBackupToSyncArea(filePath: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!+"/transfer_xml.php")
        
//        TGCFileManager.defaultManager.deleteFile(withPath: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!+"/transfer_xml.php")
    }

}


