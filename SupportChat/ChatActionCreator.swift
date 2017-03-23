//
//  ChatActionCreator.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation


class ChatActionCreator {
    let dispatcher: ZSCDispatcher
    
    init(dispatcher: ZSCDispatcher) {
        self.dispatcher = dispatcher
    }

    //I'm not sure if it's ok to use the SDK event or if I should unwrap it as soon as I get it
    func receiveCreatedMessage(_ event: ZDCChatEvent) {
        let chatAction = ChatAction(chatEvent: event)
        dispatcher.dispatch(chatAction)
    }
    
}
