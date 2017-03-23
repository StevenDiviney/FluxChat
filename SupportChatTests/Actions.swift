//
//  Actions.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//




/**


Actions shouldnt be this fat, move the fat up


*/


import Foundation
import ZendeskProviderSDK

enum Actions {
    case uiAction
    case chatAction
    case supportAction
}

//Might make these structs, hence the redundant type variable
open class Action {
    let type: Actions
    var message: String?
    var time: Date?
    var name: String?
    var isAgent: Bool?
    
    
    init(type: Actions) {
        self.type = type
    }
}

open class ChatAction: Action {
    //var chatEventType: ZDCChatEventType? //Should I use this or create my own version?
    //For the moment only have two events because it's easier to ignore shit than redo my fundamental modeling assumptions

    init(chatEvent: ZDCChatEvent) {
        super.init(type: Actions.chatAction)
        
        if (chatEvent.timestamp != nil) {
        
            let timeInterval = TimeInterval(chatEvent.timestamp)
            let timestamp = NSDate(timeIntervalSince1970: timeInterval)
            super.message = chatEvent.message
            super.time = timestamp as Date
            super.name = chatEvent.displayName
            //chatEventType = chatEvent.type
            if(chatEvent.type == ZDCChatEventType.visitorMessage) {
                super.isAgent = false
            } else { //All other events come as if they are agent events. See above comment about redoing shit
                super.isAgent = true
            }
                
        }
    }
}

open class UIAction: Action {
    init(message: String) {
        super.init(type: Actions.uiAction)
        super.message = message
    }
}

open class SupportAction: Action {
    init(comment: ZDKComment, isAgent: Bool) {
        super.init(type: Actions.supportAction)
        super.message = comment.body
        super.time = comment.createdAt
        //super.name = comment.authorId
    }
}

