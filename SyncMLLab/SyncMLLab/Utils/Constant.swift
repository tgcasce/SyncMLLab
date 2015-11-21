//
//  Constant.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/28.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import Foundation

let mainHost = "http://localhost/~maulyn/SyncServer/"

let transferHandlerFile = "transfer_xml.php"
let syncUploadHandlerFile = "sync_upload.php"
let backupUploadHandlerFile = "backup_upload.php"

let syncArea = "SyncArea/"
let backupArea = "BackupArea/"

let syncStatusFile = ".SyncStatus"

let DirectoryDidChangeNotification = "directoryDidChangeNotification"

var beginTime = NSDate()
var endTime = NSDate()