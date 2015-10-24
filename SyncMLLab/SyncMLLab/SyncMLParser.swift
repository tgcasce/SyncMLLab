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
    
    var statuses: [AEXMLElement]? {
        return XMLDocument!.root["SyncBody"]["Status"].all
    }
    
    var syncHdrStatus: [String : String]? {
        for status in statuses! {
            if status["Cmd"].stringValue == "SyncHdr" {
                return ["CmdID":status["CmdID"].stringValue, "Data":status["Data"].stringValue]
            }
        }
        return nil
    }
    
    var alertStatus: [String : String]? {
        for status in statuses! {
            if status["Cmd"].stringValue == "Alert" {
                return ["CmdID":status["CmdID"].stringValue, "Data":status["Data"].stringValue, "Next":status["Item"]["Data"]["Anchor"]["Next"].stringValue]
            }
        }
        return nil
    }
    
    var syncStatus: [String : String]? {
        for status in statuses! {
            if status["Cmd"].stringValue == "Sync" {
                return ["CmdID":status["CmdID"].stringValue, "Data":status["Data"].stringValue]
            }
        }
        return nil
    }
    
    var commandStatus: [String : String]? {
        if let status = XMLDocument?.root["SyncBody"].children.last {
            return ["CmdID":status["CmdID"].stringValue, "Cmd":status["Cmd"].stringValue, "Data":status["Data"].stringValue]
        }
        return nil
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
