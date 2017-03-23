//
//  UIActionCreator.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/16/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation

class UIActionCreator {
    let dispatcher: ZSCDispatcher
    
    init(dispatcher: ZSCDispatcher) {
        self.dispatcher = dispatcher
    }
    
    func receivedUserMessage(_ message: String) {
        let uiAction = UIAction(message: message)
        dispatcher.dispatch(uiAction)
    }
}
