//
//  IncomingMessageStore.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation

public let IncomingMessageStoreEvent = "IncomingMessageStoreEvent"


class IncomingMessageStore {
    var messages: [Action] = []
    
    init(dispatcher: ZSCDispatcher) {
        dispatcher.register({action in
            self.handleAction(action)
        })
    }
    
    func handleAction(_ action: Action) {
        //NSLog("\(self) got: \(action.action) with: \(action.message)")
        if (action.type == Actions.chatAction || action.type == Actions.supportAction) {
            messages.append(action)
            NotificationCenter.default.post(name: Notification.Name(rawValue: IncomingMessageStoreEvent), object: nil)
        }
    }

}
