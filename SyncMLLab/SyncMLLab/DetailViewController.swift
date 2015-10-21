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
//        let request = NSURLRequest(URL: NSURL(string: "http://localhost/~maulyn/SyncServer")!)
//        let _ = NSURLConnection(request: request, delegate: self)
        
        let postRequestURL = NSURL(string: "http://localhost/~maulyn/do_upload.php")!
        let formRequest = ASIFormDataRequest.requestWithURL(postRequestURL) as! ASIFormDataRequest
        formRequest.setFile(NSBundle.mainBundle().pathForResource("DSC_2122", ofType: "JPG")!, forKey: "file")
        formRequest.delegate = self
        formRequest.startAsynchronous()
    }

}

extension DetailViewController: NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        print(response)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding))
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
    }
}

extension DetailViewController: ASIHTTPRequestDelegate {
    func requestStarted(request: ASIHTTPRequest!) {
        print("request:\(request)")
    }

    func request(request: ASIHTTPRequest!, didReceiveResponseHeaders responseHeaders: [NSObject : AnyObject]!) {
        print("response:\(responseHeaders)")
    }
    
    func request(request: ASIHTTPRequest!, willRedirectToURL newURL: NSURL!) {
        print("newURL\(newURL)")
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
        print(NSString(data: data, encoding: NSUTF8StringEncoding))
    }
}