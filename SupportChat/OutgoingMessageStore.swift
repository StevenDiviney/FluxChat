//
//  OutgoingMessageStore.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/16/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation

public let OutgoingMessageStoreEvent = "OutgoingMessageStoreEvent"

class OutgoingMessageStore{
    
    fileprivate var _message: String?

    var message: String? {
        let temp = _message
        _message = nil
        return temp
    }
    
    init(dispatcher: ZSCDispatcher) {
        dispatcher.register({action in
            self.handleAction(action)
        })
    }
    
    
    func handleAction(_ action: Action) {
        if (action.type == Actions.uiAction) {
            _message = action.message
            NotificationCenter.default.post(name: Notification.Name(rawValue: OutgoingMessageStoreEvent), object: nil)
        }
    }
}
