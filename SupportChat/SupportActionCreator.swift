//
//  SupportActionCreator.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/16/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation
import ZendeskProviderSDK

class SupportActionCreator {
    let dispatcher: ZSCDispatcher
    
    init(dispatcher: ZSCDispatcher) {
        self.dispatcher = dispatcher
    }
    
    func receivedSupportMessage(_ comment: ZDKComment, isAgent: Bool) {
        let supportAction = SupportAction(comment: comment, isAgent: isAgent)
        dispatcher.dispatch(supportAction)
    }
}
