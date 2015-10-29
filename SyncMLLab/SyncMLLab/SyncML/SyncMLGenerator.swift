//
//  SyncMLGenerator.swift
//  SyncMLLab
//
//  Created by DonMaulyn on 15/10/23.
//  Copyright © 2015年 MaulynTang. All rights reserved.
//

import UIKit
import AEXML

enum CommonUseElements: String {
    case Archive = "Archive", Chal = "Chal", Cmd = "Cmd", CmdID = "CmdID", CmdRef = "CmdRef", Cred = "Cred", Final = "Final", Lang = "Lang", LocName = "LocName", LocURI = "LocURI", MoreData = "MoreData", MsgID = "MsgID", MsgRef = "MsgRef", NoResp = "NoResp", NoResults = "NoResults", NumberOfChanges = "NumberOfChanges", RespURI = "RespURI", SessionID = "SessionID", SftDel = "SftDel", Source = "Source", SourceRef = "SourceRef", Target = "Target", TargetRef = "TargetRef", VerDTD = "VerDTD", VerProto = "VerProto"
}

enum MessageContainerElements: String {
    case SyncML = "SyncML", SyncHdr = "SyncHdr", SyncBody = "SyncBody"
}

enum DataDescriptionElements: String {
    case Data = "Data", Item = "Item", Meta = "Meta"
}

enum ProtocolManagementElements: String {
    case Status = "Status"
}

enum ProtocolCommandElements: String {
    case Add = "Add", Alert = "Alert", Atomic = "Atomic", Copy = "Copy", Delete = "Delete", Exec = "Exec", Get = "Get", Map = "Map", MapItem = "MapItem", Put = "Put", Replace = "Replace", Results = "Results", Search = "Search", Sequence = "Sequence", Sync = "Sync"
}

enum AlertCommandTypes: Int {
    case TwoWay = 200
    case SlowWay = 201
    case OneWayFromClient = 202
    case RefreshFromClient = 203
    case OneWayFromServer = 204
    case RefreshFromServer = 205
    case BackupSync = 211
}

class SyncMLGenerator: NSObject {

    let XMLDocument = AEXMLDocument()
    let syncBodyElement: AEXMLElement!
    var syncCommand: AEXMLElement? = nil
    var syncBodyCommandNumber: Int = 0
    
    init(messageNumber number: Int) {
        let syncMLElement = XMLDocument.addChild(name: MessageContainerElements.SyncML.rawValue)
        
        let syncHdrElement = syncMLElement.addChild(name: MessageContainerElements.SyncHdr.rawValue)
        syncHdrElement.addChild(name: CommonUseElements.VerDTD.rawValue, value: "1.1")
        syncHdrElement.addChild(name: CommonUseElements.VerProto.rawValue, value: "SyncML/1.2")
        syncHdrElement.addChild(name: CommonUseElements.SessionID.rawValue, value: "1")
        syncHdrElement.addChild(name: CommonUseElements.MsgID.rawValue, value: String(number))
        syncHdrElement.addChild(name: CommonUseElements.Target.rawValue).addChild(name: CommonUseElements.LocURI.rawValue, value: mainHost)
        syncHdrElement.addChild(name: CommonUseElements.Source.rawValue).addChild(name: CommonUseElements.LocURI.rawValue, value: UIDevice.currentDevice().identifierForVendor?.UUIDString)
        
        syncBodyElement = syncMLElement.addChild(name: MessageContainerElements.SyncBody.rawValue)
    }
    
    func addStatusElementForSyncBody(msgRef: Int, cmdRef: Int, cmd: String, targetRef: String, sourceRef: String, data: String, nextSyncAnchor: String?) -> AEXMLElement {
        syncBodyCommandNumber++
        let statusElement = syncBodyElement.addChild(name: ProtocolManagementElements.Status.rawValue)
        statusElement.addChild(name: CommonUseElements.CmdID.rawValue, value: String(syncBodyCommandNumber))
        statusElement.addChild(name: CommonUseElements.MsgRef.rawValue, value: String(msgRef))
        statusElement.addChild(name: CommonUseElements.CmdRef.rawValue, value: String(cmdRef))
        statusElement.addChild(name: CommonUseElements.Cmd.rawValue, value: cmd)
        statusElement.addChild(name: CommonUseElements.TargetRef.rawValue, value: targetRef)
        statusElement.addChild(name: CommonUseElements.SourceRef.rawValue, value: sourceRef)
        statusElement.addChild(name: DataDescriptionElements.Data.rawValue, value: data)
        if nextSyncAnchor != nil {
            let anchorElement = statusElement.addChild(name: DataDescriptionElements.Item.rawValue).addChild(name: DataDescriptionElements.Data.rawValue).addChild(name: "Anchor", attributes: ["xmlns" : "syncml:metinf"])
            anchorElement.addChild(name: "Next", value: nextSyncAnchor)
        }
        
        return statusElement
    }
    
    func addAlertElementForSyncBody(data: String, target: String, source: String, lastSyncAnchor: String) -> AEXMLElement {
        syncBodyCommandNumber++
        let alertElement = syncBodyElement.addChild(name: ProtocolCommandElements.Alert.rawValue)
        alertElement.addChild(name: CommonUseElements.CmdID.rawValue, value: String(syncBodyCommandNumber))
        alertElement.addChild(name: DataDescriptionElements.Data.rawValue, value: data)
        
        let itemElement = alertElement.addChild(name: DataDescriptionElements.Item.rawValue)
        itemElement.addChild(name: CommonUseElements.Target.rawValue).addChild(name: CommonUseElements.LocURI.rawValue, value: target)
        itemElement.addChild(name: CommonUseElements.Source.rawValue).addChild(name: CommonUseElements.LocURI.rawValue, value: source)
        let anchorElement = itemElement.addChild(name: DataDescriptionElements.Meta.rawValue).addChild(name: "Anchor", attributes: ["xmlns" : "syncml:metinf"])
        anchorElement.addChild(name: "Last", value: lastSyncAnchor)
        anchorElement.addChild(name: "Next", value: NSDate().description)
        
        return alertElement
    }
    
    func addSyncElementForSyncBody(target: String, source: String, lastSyncAnchor: String) -> AEXMLElement {
        syncBodyCommandNumber++
        syncCommand = syncBodyElement.addChild(name: ProtocolCommandElements.Sync.rawValue)
        syncCommand!.addChild(name: CommonUseElements.CmdID.rawValue, value: String(syncBodyCommandNumber))
        syncCommand!.addChild(name: CommonUseElements.Target.rawValue).addChild(name: CommonUseElements.LocURI.rawValue, value: target)
        syncCommand!.addChild(name: CommonUseElements.Source.rawValue).addChild(name: CommonUseElements.LocURI.rawValue, value: source)
        
        return syncCommand!
    }
    
    func addElementForSyncCommand(element: String) -> AEXMLElement {
        syncBodyCommandNumber++
        let commandElement = syncCommand!.addChild(name: element)
        commandElement.addChild(name: CommonUseElements.CmdID.rawValue, value: String(syncBodyCommandNumber))
        
        return commandElement
    }
    
    func saveAsXMLFile(path: String) -> String? {
        let savePath = path + "\(NSDate().description).xml"
        do {
            try XMLDocument.xmlString.writeToFile(savePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print(error)
            return nil
        }
        return savePath
    }
}

//MARK: - File Transfer Command Usage

extension SyncMLGenerator {
    class func generateAddCommandWith(syncType type: Int, anchor: String, fileTarget: String, fileSource: String) -> SyncMLGenerator {
        let XML = SyncMLGenerator.generateOperationCommandWith(syncType: type, anchor: anchor, fileTarget: fileTarget, fileSource: fileSource)
        XML.addElementForSyncCommand("Add")
        
        return XML
    }
    
    class func generatePutCommandWith(syncType type: Int, anchor: String, fileTarget: String, fileSource: String) -> SyncMLGenerator {
        let XML = SyncMLGenerator.generateOperationCommandWith(syncType: type, anchor: anchor, fileTarget: fileTarget, fileSource: fileSource)
        XML.addElementForSyncCommand("Put")
        
        return XML
    }
    
    class func generateDeleteCommandWith(syncType type: Int, anchor: String, fileTarget: String, fileSource: String) -> SyncMLGenerator {
        let XML = SyncMLGenerator.generateOperationCommandWith(syncType: type, anchor: anchor, fileTarget: fileTarget, fileSource: fileSource)
        XML.addElementForSyncCommand("Delete")
        
        return XML
    }
    
    class func generateOperationCommandWith(syncType type: Int, anchor: String, fileTarget: String, fileSource: String) -> SyncMLGenerator {
        let XML = SyncMLGenerator(messageNumber: 1)
        XML.addAlertElementForSyncBody(String(type), target: mainHost+transferHandlerFile, source: fileSource, lastSyncAnchor: anchor)
        XML.addSyncElementForSyncBody(fileTarget, source: fileSource, lastSyncAnchor: anchor)
        
        return XML
    }
}
