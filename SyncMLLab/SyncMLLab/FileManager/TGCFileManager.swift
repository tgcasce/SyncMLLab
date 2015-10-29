//
//  TGCFileManager.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/25.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit

class TGCFileManager: NSObject {

    static var defaultManager: TGCFileManager {
        return Inner.singleton
    }
    struct Inner {
        static let singleton: TGCFileManager = TGCFileManager()
    }
    
    static let libraryDirectory: NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!
    static let documentDirectory: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
    
    let transferQueue = NSOperationQueue()
    let scanFileQueue = NSOperationQueue()
    var currentPath: String = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!.absoluteString
    var currentDirectories = [NSURL]()
    var currentFiles = [NSURL]()
    lazy var fileInformations: NSMutableDictionary! = NSMutableDictionary(contentsOfURL: NSURL(string: syncStatusFile, relativeToURL: TGCFileManager.libraryDirectory)!)
    var transferCompletionHandler: (() -> Void)? //called when 'transferQueue' is empty
    
    func scanCurrentPath(completion: (() -> Void)?) {
        self.scanPath(self.currentPath, completion: completion)
    }
    
    func scanPath(path: String, completion: (() -> Void)?) {
        self.scanFileQueue.addOperationWithBlock { () -> Void in
            if self.currentPath != path {
                self.currentPath = path
            }
            
            self.currentDirectories.removeAll()
            self.currentFiles.removeAll()
            
            let fileManager = NSFileManager.defaultManager()
            if let fileEnum = fileManager.enumeratorAtURL(NSURL(string: path)!, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: [NSDirectoryEnumerationOptions.SkipsPackageDescendants, NSDirectoryEnumerationOptions.SkipsHiddenFiles, NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants], errorHandler: nil) {
                if self.fileInformations == nil {
                    self.fileInformations = NSMutableDictionary()
                }
                //删除不存在的文件的记录
                for key in self.fileInformations.allKeys {
                    if (key as! String).hasPrefix(path) {
                        var count = 0
                        for fileURL in fileEnum {
                            if key as! String == (fileURL as! NSURL).path! {
                                count++
                                break;
                            }
                        }
                        if count == 0 {
                            self.fileInformations.removeObjectForKey(key)
                        }
                    }
                }
                for fileURL in fileEnum {
                    do {
                        if self.fileInformations[(fileURL as! NSURL).path!] == nil {
                            self.fileInformations[(fileURL as! NSURL).path!] = "0"
                        }
                        var isDirectory: AnyObject?
                        try (fileURL as! NSURL).getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
                        if let isDirectoryBool = isDirectory as? NSNumber {
                            if isDirectoryBool.boolValue == true {
                                self.currentDirectories.append(fileURL as! NSURL)
                            } else {
                                self.currentFiles.append(fileURL as! NSURL)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if completion != nil {
                    completion!()
                }
            })
        }
    }
    
    func getNameBy(URL: NSURL) -> String? {
        do {
            var fileName: AnyObject?
            try URL.getResourceValue(&fileName, forKey: NSURLNameKey)
            if let name = fileName as? String {
                return name
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func uploadDocumentInSyncAreaWith(documentPath path: String) {
        let fileManager = NSFileManager.defaultManager()
        if let fileEnum = fileManager.enumeratorAtURL(NSURL(string: path)!, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: [NSDirectoryEnumerationOptions.SkipsPackageDescendants, NSDirectoryEnumerationOptions.SkipsHiddenFiles], errorHandler: nil) {
            for fileURL in fileEnum {
                do {
                    if self.fileInformations[(fileURL as! NSURL).path!] == nil {
                        self.fileInformations[(fileURL as! NSURL).path!] = "0"
                    }
                    var isDirectory: AnyObject?
                    try (fileURL as! NSURL).getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
                    if let isDirectoryBool = isDirectory as? NSNumber {
                        if isDirectoryBool.boolValue == false {
                            self.commonSyncWith(syncCommand: ProtocolCommandElements.Add, filePath: (fileURL as! NSURL).path!)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func commonSyncWith(syncCommand command: ProtocolCommandElements, filePath: String) {
        let uploadXML = SyncMLGenerator.generateOperationCommandWith(syncType: AlertCommandTypes.TwoWay.rawValue, anchor: NSDate().description, fileTarget: mainHost+syncArea, fileSource: filePath)
        uploadXML.addElementForSyncCommand(command.rawValue)
        let xmlPath = uploadXML.saveAsXMLFile(NSTemporaryDirectory())
        self.uploadFileRequestWith(transferHandlerFile, filePath: xmlPath!, userInfo: ["SyncType" : NSNumber(integer: AlertCommandTypes.TwoWay.rawValue)])
        if command == ProtocolCommandElements.Delete {
            if filePath.hasSuffix("/") {
                for key in self.fileInformations.allKeys {
                    if (key as! String).hasPrefix(filePath) {
                        self.fileInformations.removeObjectForKey(key)
                    }
                }
            } else {
                self.fileInformations.removeObjectForKey(filePath)
            }
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {
                print(error)
            }
        } else {
            self.fileInformations[filePath] = "2"
        }
    }
    
    func uploadDocumentInBackupAreaWith(filePath path: String) {
        let fileManager = NSFileManager.defaultManager()
        if let fileEnum = fileManager.enumeratorAtURL(NSURL(string: path)!, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: [NSDirectoryEnumerationOptions.SkipsPackageDescendants, NSDirectoryEnumerationOptions.SkipsHiddenFiles], errorHandler: nil) {
            for fileURL in fileEnum {
                do {
                    if self.fileInformations[(fileURL as! NSURL).path!] == nil {
                        self.fileInformations[(fileURL as! NSURL).path!] = "0"
                    }
                    var isDirectory: AnyObject?
                    try (fileURL as! NSURL).getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
                    if let isDirectoryBool = isDirectory as? NSNumber {
                        if isDirectoryBool.boolValue == false {
                            self.uploadFileInBackupAreaWith(filePath: (fileURL as! NSURL).path!)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func uploadFileInBackupAreaWith(filePath path: String) {
        let uploadXML = SyncMLGenerator.generateAddCommandWith(syncType: AlertCommandTypes.BackupSync.rawValue, anchor: NSDate().description, fileTarget: mainHost+backupArea, fileSource: path)
        let xmlPath = uploadXML.saveAsXMLFile(NSTemporaryDirectory())
        self.uploadFileRequestWith(transferHandlerFile, filePath: xmlPath!, userInfo: ["SyncType" : NSNumber(integer: AlertCommandTypes.BackupSync.rawValue)])
        self.fileInformations[path] = "1"
    }
    
    private func uploadFileRequestWith(serverFile: String, filePath path: String, userInfo: [String : AnyObject]?) {
        let postRequestURL = NSURL(string: mainHost+serverFile)!
        let formRequest = ASIFormDataRequest.requestWithURL(postRequestURL) as! ASIFormDataRequest
        formRequest.setFile(path, forKey: "file")
        if serverFile != transferHandlerFile {
            let relativePath = self.getDocumentsRelativePathAndDirectoryPathAndFileName(byPath: path)
            if relativePath.directoryPath != "" {
                formRequest.addPostValue(relativePath.directoryPath, forKey: "filePath")
                formRequest.addPostValue(relativePath.fileName, forKey: "fileName")
            } else {
                formRequest.addPostValue(relativePath.relativePath, forKey: "fileName")
            }
        }
        formRequest.delegate = self
        if userInfo != nil {
            formRequest.userInfo = userInfo
        }
        self.transferQueue.addOperation(formRequest)
    }
    
    func putFileFromBackupToSyncArea(filePath path: String) {
        let relativePath = self.getDocumentsRelativePathAndDirectoryPathAndFileName(byPath: path)
        let putXML = SyncMLGenerator.generatePutCommandWith(syncType: AlertCommandTypes.BackupSync.rawValue, anchor: NSDate().description, fileTarget: mainHost+syncArea, fileSource: relativePath.relativePath)
        let xmlPath = putXML.saveAsXMLFile(NSTemporaryDirectory())
        self.uploadFileRequestWith(transferHandlerFile, filePath: xmlPath!, userInfo: ["SyncType" : NSNumber(integer: AlertCommandTypes.BackupSync.rawValue)])
        self.fileInformations[path] = "2"
        do {
            try NSFileManager.defaultManager().moveItemAtPath(path, toPath: TGCFileManager.documentDirectory+"/"+relativePath.fileName)
        } catch {
            print(error)
        }
    }
    
    func deleteFile(withPath path: String) {
        let relativePath = self.getDocumentsRelativePathAndDirectoryPathAndFileName(byPath: path)
        let putXML = SyncMLGenerator.generateDeleteCommandWith(syncType: AlertCommandTypes.BackupSync.rawValue, anchor: NSDate().description, fileTarget: mainHost+backupArea, fileSource: relativePath.relativePath)
        let xmlPath = putXML.saveAsXMLFile(NSTemporaryDirectory())
        self.uploadFileRequestWith(transferHandlerFile, filePath: xmlPath!, userInfo: ["SyncType" : NSNumber(integer: AlertCommandTypes.BackupSync.rawValue)])
        if path.hasSuffix("/") {
            for key in self.fileInformations.allKeys {
                if (key as! String).hasPrefix(path) {
                    self.fileInformations.removeObjectForKey(key)
                }
            }
        } else {
            self.fileInformations.removeObjectForKey(path)
        }
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch {
            print(error)
        }
    }
    
    //将绝对路径分为以Documents文件夹的相对文件路径和文件名
    private func getDocumentsRelativePathAndDirectoryPathAndFileName(byPath path: String) -> (relativePath: String, directoryPath: String, fileName: String) {
        let range = (path as NSString).rangeOfString("Documents/")
        let cuttedString = (path as NSString).substringFromIndex(range.location + range.length)
        let backwardRange = (cuttedString as NSString).rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch)
        if backwardRange.location != NSNotFound {
            let filePath = (cuttedString as NSString).substringToIndex(backwardRange.location + backwardRange.length)
            let fileName = (cuttedString as NSString).substringFromIndex(backwardRange.location + backwardRange.length)
            return (cuttedString, filePath, fileName)
        } else {
            return (cuttedString, "", cuttedString)
        }
    }
}

extension TGCFileManager: ASIHTTPRequestDelegate {
    func requestStarted(request: ASIHTTPRequest!) {
        print("started.")
    }
    
    func request(request: ASIHTTPRequest!, didReceiveResponseHeaders responseHeaders: [NSObject : AnyObject]!) {
        print("request:\(request.requestHeaders)")
        print("status code: \(request.responseStatusCode), response:\(responseHeaders as NSDictionary)")
    }
    
    func request(request: ASIHTTPRequest!, willRedirectToURL newURL: NSURL!) {
        print("newURL:\(newURL)")
    }
    
    func requestFinished(request: ASIHTTPRequest!) {
        print("finished.")
        guard let userInfo = request.userInfo else {
            if self.transferQueue.operationCount == 0 {
                if self.transferCompletionHandler != nil {
                    self.transferCompletionHandler!()
                }
            }
            return;
        }
        if (userInfo["SyncType"] as! NSNumber).integerValue == AlertCommandTypes.TwoWay.rawValue {
            let XML = SyncMLParser(XMLdata: request.responseData())
            let respXML = SyncMLGenerator(messageNumber: 1)
            respXML.addStatusElementForSyncBody(1, cmdRef: 0, cmd: MessageContainerElements.SyncHdr.rawValue, targetRef: (XML?.XMLDocument!.root[MessageContainerElements.SyncHdr.rawValue][CommonUseElements.Target.rawValue][CommonUseElements.LocURI.rawValue].stringValue)!, sourceRef: (XML?.XMLDocument!.root[MessageContainerElements.SyncHdr.rawValue][CommonUseElements.Source.rawValue][CommonUseElements.LocURI.rawValue].stringValue)!, data: "200", nextSyncAnchor: nil)
            let xmlPath = respXML.saveAsXMLFile(NSTemporaryDirectory())
            self.uploadFileRequestWith(transferHandlerFile, filePath: xmlPath!, userInfo: nil)
        }
    }
    
    func requestFailed(request: ASIHTTPRequest!) {
        print("failed.")
    }
    
    func requestRedirected(request: ASIHTTPRequest!) {
        print("redirected.")
    }
    
    func request(request: ASIHTTPRequest!, didReceiveData data: NSData!) {
        if let parser = SyncMLParser(XMLdata: data) {
            if let commandStatus = parser.commandStatus {
                if commandStatus[CommonUseElements.Cmd.rawValue] == ProtocolCommandElements.Add.rawValue {
                    var serverFile = syncUploadHandlerFile
                    if let syncType = request.userInfo["SyncType"] {
                        if (syncType as! NSNumber).integerValue == AlertCommandTypes.BackupSync.rawValue {
                            serverFile = backupUploadHandlerFile
                        }
                    }
                    self.uploadFileRequestWith(serverFile, filePath: parser.syncStatus![CommonUseElements.SourceRef.rawValue]!, userInfo: nil)
                }
            }
        } else {
            print(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
    }
}
