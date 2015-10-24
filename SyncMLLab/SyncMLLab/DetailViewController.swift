//
//  DetailViewController.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/20.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func request(sender: AnyObject) {
        
        let XML = SyncMLGenerator(messageNumber: 1)
        XML.addStatusElementForSyncBody(1, cmdRef: 0, cmd: MessageContainerElements.SyncHdr.rawValue, targetRef: "unknow", sourceRef: "unknow", data: "200", nextSyncAnchor: NSDate().description)
        XML.addAlertElementForSyncBody("211", target: "http://localhost/~maulyn/SyncServer/present_xml.php", source: "file.file", lastSyncAnchor: NSDate().dateByAddingTimeInterval(-10000).description)
        XML.addSyncElementForSyncBody("", source: "", lastSyncAnchor: "2015-10-23")
        XML.addElementForSyncCommand("Add")
        let xmlPath = XML.saveAsXMLFile()
        
        print(xmlPath)
        
        let postRequestURL = NSURL(string: "http://localhost/~maulyn/SyncServer/transfer_xml.php")!
        let formRequest = ASIFormDataRequest.requestWithURL(postRequestURL) as! ASIFormDataRequest
        formRequest.setFile(xmlPath, forKey: "file")
        formRequest.delegate = self
        formRequest.startAsynchronous()
    }

}

extension DetailViewController: ASIHTTPRequestDelegate {
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
