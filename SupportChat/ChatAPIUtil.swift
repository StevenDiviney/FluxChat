//
//  ChatAPIUtil.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation


class ChatAPIUtil: NSObject {
    var chat: ZDCChatAPI
    var chatActionCreator: ChatActionCreator
    var outgoingMessageStore: OutgoingMessageStore
    var eventIDs: Set<String>
    var status: ZDCConnectionStatus
    
    
    init(actionCreator: ChatActionCreator, outgoingMessageStore: OutgoingMessageStore) {
 
        chat = ZDCChatAPI.instance()
        self.chatActionCreator = actionCreator
        self.outgoingMessageStore = outgoingMessageStore
        self.status = ZDCConnectionStatus.disconnected
        
        eventIDs = Set<String>()
        
        super.init()
        chat.addObserver(self, forChatLogEvents: #selector(ChatAPIUtil.chatLogEvent(_:)))
        chat.addObserver(self, forConnectionEvents: #selector(ChatAPIUtil.chatConnectionStateUpdated(_:)))
        
        chat.startChat(withAccountKey: Chat.accountKey)
        
        registerForEvents()

    }
    
    func registerForEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatAPIUtil.outgoingStoreHandler(_:)), name:NSNotification.Name(rawValue: OutgoingMessageStoreEvent) , object: nil)
    }
    
//Handler
    
    func outgoingStoreHandler(_ note: Notification) {
        //If currently using zopim chat. Should that really be controlled here?
        if (self.status == .connected) {
            if let message = outgoingMessageStore.message {
                chat.sendChatMessage(message)
            }
        }
    }
    

//Chat API stuff

    
    func chatLogEvent(_ note: Notification) {
        let events = chat.livechatLog!
        if let lastEvent = events.last {
            NSLog("Received chat event \(lastEvent.type.rawValue) with: \(lastEvent.message)")
            
            //Zopim seems to send the same event multiple times so filter that
            if eventIsDuplicate(lastEvent.eventId) {
                return
            }
        
            switch lastEvent.type {
                case ZDCChatEventType.memberLeave:
                    //Agent cannot end a chat so switch to ticketing when they leave
                    chat.endChat()
                    
                break
                default:
                    chatActionCreator.receiveCreatedMessage(lastEvent)
                
                break
            }
            
        }
    }
    
    func eventIsDuplicate(_ eventID: String) -> Bool {
        if eventIDs.contains(eventID) {
            return true
        } else {
            eventIDs.insert(eventID)
            return false
        }
    }
    
    func chatConnectionStateUpdated(_ note: Notification) {
        self.status = chat.connectionStatus
        NSLog("Chat connection status updated \(status.rawValue)")
        switch self.status {
            //Just a hack to get a chat started + events firing
        case ZDCConnectionStatus.connected:
            chat.sendChatMessage("Get shwifty")
            chat.uploadFile(with: "this is data".data(using: String.Encoding.utf8, allowLossyConversion: true), name:"audio.m4a" )
            if (chat.isAccountOnline) {
                //Show chat
            } else {
                //Show ticketing
            }
            
            default:
            
            break
        }
    }
    
    
    deinit {
        chat.endChat()
        chat.removeObserver(forAccountEvents: self)
        chat.removeObserver(forConnectionEvents: self)
        NotificationCenter.default .removeObserver(self)
    }

}
