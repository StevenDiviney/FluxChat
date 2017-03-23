//
//  ZSCDispatcher.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation

//public typealias Dispatch_Token = String
//public typealias Payload = Action
public typealias ClosureType = (Action) -> ()

open class ZSCDispatcher: NSObject {
    
    var callbacks = [ClosureType]()
    
    
    /**
     Register a store callback to be invoked by an action
     
     - parameter callback: Callback to be registered
     
     - returns: Index of the callback
     */
    open func register(_ callback: @escaping ClosureType) -> Int{
        callbacks.append(callback)
        return callbacks.count - 1
    }
    
    open func dispatch(_ payload: Action) {
        callbacks.forEach { closure in
            
        }
        
        for closure in callbacks {
            closure(payload)
        }
        
    }
    
    
}
