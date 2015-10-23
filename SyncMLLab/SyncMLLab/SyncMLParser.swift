//
//  SyncMLParser.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/23.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit
import AEXML

class SyncMLParser: NSObject {

    var XMLDocument: AEXMLDocument? = nil
    var readableString: String? {
        return XMLDocument?.xmlString
    }
    
    init?(XMLdata data: NSData) {
        super.init()
        do {
            XMLDocument = try AEXMLDocument(xmlData: data)
        } catch {
            print(error)
            return nil
        }
    }
}
