//
//  DetailViewController.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/20.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit

enum AreaType: Int {
    case LocalArea = 0
    case BackupArea = 1
    case SyncArea = 2
}

class DetailViewController: UITableViewController {

    var shouldPerformSegue = false
    var currentPath: String = TGCFileManager.documentDirectory
    var areaType = AreaType.LocalArea
    var currentDirectories = [NSURL]()
    var currentFiles = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = (self.currentPath as NSString).lastPathComponent
        self.configureView()
        TGCFileManager.defaultManager.transferCompletionHandler = { () -> Void in
            self.currentDirectories.removeAll()
            self.currentFiles.removeAll()
            for directoryURL in TGCFileManager.defaultManager.currentDirectories {
                if let syncStatus = TGCFileManager.defaultManager.fileInformations[directoryURL.path!] {
                    if syncStatus as! String == String(self.areaType.rawValue) {
                        self.currentDirectories.append(directoryURL)
                    }
                }
            }
            for fileURL in TGCFileManager.defaultManager.currentFiles {
                if let syncStatus = TGCFileManager.defaultManager.fileInformations[fileURL.path!] {
                    if syncStatus as! String == String(self.areaType.rawValue) {
                        self.currentFiles.append(fileURL)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureView() {
        self.currentDirectories.removeAll()
        self.currentFiles.removeAll()
        TGCFileManager.defaultManager.scanPath(currentPath) { () -> Void in
            for directoryURL in TGCFileManager.defaultManager.currentDirectories {
                if let syncStatus = TGCFileManager.defaultManager.fileInformations[directoryURL.path!] {
                    if syncStatus as! String == String(self.areaType.rawValue) {
                        self.currentDirectories.append(directoryURL)
                    }
                }
            }
            for fileURL in TGCFileManager.defaultManager.currentFiles {
                if let syncStatus = TGCFileManager.defaultManager.fileInformations[fileURL.path!] {
                    if syncStatus as! String == String(self.areaType.rawValue) {
                        self.currentFiles.append(fileURL)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: - UITableViewDataSource, UITableViewDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.currentDirectories.count
        } else {
            return self.currentFiles.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell", forIndexPath: indexPath)
        var name: String?
        if indexPath.section == 0 {
            name = TGCFileManager.defaultManager.getNameBy(self.currentDirectories[indexPath.row])
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            name = TGCFileManager.defaultManager.getNameBy(self.currentFiles[indexPath.row])
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.textLabel?.text = name
        if self.areaType != AreaType.LocalArea && indexPath.section != 0 {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "文件夹"
        } else {
            return "文件"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController = self.configureAlertControllerWith(selectedIndexPath: indexPath)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func configureAlertControllerWith(selectedIndexPath indexPath: NSIndexPath) -> UIAlertController {
        var operationPath = ""
        if indexPath.section == 0 {
            operationPath = self.currentDirectories[indexPath.row].path!
        } else {
            operationPath = self.currentFiles[indexPath.row].path!
        }
        let alertController = UIAlertController(title: "请选择操作", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let openAction = UIAlertAction(title: "打开", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.shouldPerformSegue = true
            self.performSegueWithIdentifier("showDocumentContent", sender: self)
        }
        let deleteAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive) { (alertAction) -> Void in
            TGCFileManager.defaultManager.deleteFile(withPath: operationPath)
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        switch self.areaType {
        case .LocalArea:
            if indexPath.section == 0 {
                alertController.addAction(openAction)
                let uploadAction = UIAlertAction(title: "上传", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    TGCFileManager.defaultManager.uploadDocumentInBackupAreaWith(filePath: operationPath)
                }
                alertController.addAction(uploadAction)
            } else {
                let uploadAction = UIAlertAction(title: "上传", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    TGCFileManager.defaultManager.uploadFileInBackupAreaWith(filePath: operationPath)
                }
                alertController.addAction(uploadAction)
            }
            alertController.addAction(deleteAction)
        case .BackupArea:
            if indexPath.section == 0 {
                alertController.addAction(openAction)
            } else {
                let moveAction = UIAlertAction(title: "移到同步区", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    TGCFileManager.defaultManager.putFileFromBackupToSyncArea(filePath: operationPath)
                }
                alertController.addAction(moveAction)
            }
        case .SyncArea:
            if indexPath.section == 0 {
                alertController.addAction(openAction)
                let uploadAction = UIAlertAction(title: "同步", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    TGCFileManager.defaultManager.uploadDocumentInSyncAreaWith(documentPath: operationPath)
                }
                alertController.addAction(uploadAction)
            } else {
                let uploadAction = UIAlertAction(title: "同步", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    TGCFileManager.defaultManager.commonSyncWith(syncCommand: ProtocolCommandElements.Add, filePath: operationPath)
                }
                alertController.addAction(uploadAction)
                let moveAction = UIAlertAction(title: "移到久驻区", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    TGCFileManager.defaultManager.uploadFileInBackupAreaWith(filePath: operationPath)
                }
                alertController.addAction(moveAction)
            }
            let deleteSyncAreaAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.Destructive) { (alertAction) -> Void in
                TGCFileManager.defaultManager.commonSyncWith(syncCommand: ProtocolCommandElements.Delete, filePath: operationPath)
            }
            alertController.addAction(deleteSyncAreaAction)
        }
        alertController.addAction(cancelAction)
        return alertController
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.shouldPerformSegue == false {
            return;
        }
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if indexPath.section == 0 {
                self.shouldPerformSegue = false
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.areaType = self.areaType
                controller.currentPath = self.currentDirectories[indexPath.row].path!
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.shouldPerformSegue {
            return true
        }
        return false
    }

}


