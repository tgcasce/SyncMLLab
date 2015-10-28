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
        
        TGCFileManager.defaultManager.scanCurrentPath()
        for URL in TGCFileManager.defaultManager.currentDirectories {
            print(TGCFileManager.defaultManager.getNameBy(URL))
        }
        
        TGCFileManager.defaultManager.uploadFileInBackupArea()

    }

}


