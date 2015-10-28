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
    
    let transferQueue = NSOperationQueue()
    var currentPath: String = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!.absoluteString
    var currentDirectories = [NSURL]()
    var currentFiles = [NSURL]()
    
    func scanCurrentPath() {
        self.scanPath(self.currentPath)
    }
    
    func scanPath(path: String) {
        if self.currentPath != path {
            self.currentPath = path
        }
        
        self.currentDirectories.removeAll()
        self.currentFiles.removeAll()
        
        let fileManager = NSFileManager.defaultManager()
        if let fileEnum = fileManager.enumeratorAtURL(NSURL(string: path)!, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: [NSDirectoryEnumerationOptions.SkipsPackageDescendants, NSDirectoryEnumerationOptions.SkipsHiddenFiles, NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants], errorHandler: nil) {
            for fileURL in fileEnum {
                do {
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
    
    func uploadFileInBackupAreaWith(fileURL URL: NSURL, userInfo: [String : AnyObject]?) {
        let uploadXML = SyncMLGenerator.generateAddCommandWith(syncType: AlertCommandTypes.BackupSync.rawValue, anchor: NSDate().description, fileTarget: mainHost+backupArea, fileSource: "")
        let xmlPath = uploadXML.saveAsXMLFile(NSTemporaryDirectory())
        self.uploadFileRequestWith(filePath: xmlPath!, userInfo: userInfo)
    }
    
    func uploadFileInSyncArea(fileURL URL: NSURL, userInfo: [String : AnyObject]?) {
        let uploadXML = SyncMLGenerator.generateAddCommandWith(syncType: AlertCommandTypes.TwoWay.rawValue, anchor: NSDate().description, fileTarget: mainHost+backupArea, fileSource: "")
        let xmlPath = uploadXML.saveAsXMLFile(NSTemporaryDirectory())
        self.uploadFileRequestWith(filePath: xmlPath!, userInfo: userInfo)
    }
    
    private func uploadFileRequestWith(filePath path: String, userInfo: [String : AnyObject]?) {
        let postRequestURL = NSURL(string: mainHost+transferHandlerFile)!
        let formRequest = ASIFormDataRequest.requestWithURL(postRequestURL) as! ASIFormDataRequest
        formRequest.setFile(path, forKey: "file")
        formRequest.delegate = self
        if userInfo != nil {
            formRequest.userInfo = userInfo
        }
        self.transferQueue.addOperation(formRequest)
    }
    
    func putFileFromBackupToSyncArea() {
        
    }
    
    func deleteFile() {
        
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
    }
    
    func requestFailed(request: ASIHTTPRequest!) {
        print("failed.")
    }
    
    func requestRedirected(request: ASIHTTPRequest!) {
        print("redirected.")
    }
    
    func request(request: ASIHTTPRequest!, didReceiveData data: NSData!) {
        let parser = SyncMLParser(XMLdata: data)
        print(parser?.syncHdrStatus)
        print(parser?.alertStatus)
        print(parser?.syncStatus)
        print(parser?.commandStatus)
    }
}
