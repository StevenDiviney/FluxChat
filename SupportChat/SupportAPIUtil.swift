//
//  SupportAPIUtil.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/16/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import Foundation
import ZendeskProviderSDK

class SupportAPIUtil: NSObject {
    var outgoingMessageStore: OutgoingMessageStore
    var actionCreator: SupportActionCreator
    var currentRequest: ZDKRequest?
    
    var userStore: [NSNumber: ZDKUser]
    var commentIDs: Set<NSNumber>
    
    init(actionCreator: SupportActionCreator, outgoingMessageStore: OutgoingMessageStore) {
        self.outgoingMessageStore = outgoingMessageStore
        self.actionCreator =  actionCreator
        self.userStore = [NSNumber: ZDKUser]()
        commentIDs = Set<NSNumber>()
        super.init()
        initSDK()
        
        registerForEvents()
    }
    
    func initSDK() {
        let user = "testSDKMergeJosl@example.com"
        
        ZDCChat.updateVisitor { (visitor) -> Void in
            visitor!.email = user
        }
        
        let sdkIdent = ZDKJwtIdentity(jwtUserIdentifier: user)
        ZDKConfig.instance().userIdentity = sdkIdent;
        
        
        ZDKConfig.instance().initialize(withAppId: Support.appId, zendeskUrl: Support.url, clientId: Support.clientId)
    }
    
    func registerForEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(SupportAPIUtil.outgoingStoreHandler(_:)), name:NSNotification.Name(rawValue: OutgoingMessageStoreEvent) , object: nil)
    }
    
    func outgoingStoreHandler(_ note: Notification) {
        //Check chat is offline or something here?
        
        if let message = outgoingMessageStore.message {
            self.addCommentToRequest(message, request: self.currentRequest)
        }
        
    }
    
    //NOTHING CAN GO WRONG HERE
    func pollForUpdates() {
        let provider = ZDKRequestProvider.init()
        //Don't bother checking if request is there because Lab Day
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5), execute: {
            provider.getCommentsWithRequestId(self.currentRequest!.requestId) { (comments, error) -> Void in
                if (error == nil) {
                    for commentWithUser in comments! {
                        let comment = (commentWithUser as! ZDKCommentWithUser).comment
                        self.createCommentEvent(comment!)
                    }
                    
                    //Memory is infinite right?
                    self.pollForUpdates()
                }
            }
        })
        
        
    }
    
    func createCommentEvent(_ comment: ZDKComment) {
        
        //Oh look, another point where I said fuck it
        if (comment.commentId != nil) {
            if (commentIDs.contains(comment.commentId)) {
                return
            } else {
                commentIDs.insert(comment.commentId)
            }
        }
        
        if ((self.userStore[comment.authorId]) != nil) {
            let user = self.userStore[comment.authorId]
            self.actionCreator.receivedSupportMessage(comment, isAgent: (user?.isAgent)!)
        } else {
            //How many nested network callbacks are too many? This many?
            ZDKUserProvider.init().getUser({ (user, error) -> Void in
                if (error == nil) {
                    self.userStore[comment.authorId] = user!
                    self.actionCreator.receivedSupportMessage(comment, isAgent: (user?.isAgent)!)
                }
            })
        }
        
    }
    
    //This is shit
    //So shit
    func addCommentToRequest(_ message: String, request: ZDKRequest?) {
        let provider = ZDKRequestProvider.init()
        
        let addCommentBlock = { (requests: [AnyObject?],error:  NSError?) -> Void in
            
            self.currentRequest = requests.last as? ZDKRequest //This is fucking shit
            
            provider.addComment(message, forRequestId: self.currentRequest!.requestId, attachments: nil, withCallback: { (comment, error) -> Void in
                //Do more stuff
                if ( error == nil ) {
                    self.createCommentEvent(comment!)
                    self.pollForUpdates()
                }
            })
        }
        

        if (request != nil) {
            addCommentBlock([request], nil)
        } else {
            provider.getAllRequests(callback: { (requests, error) -> Void in
                if (error == nil){
                   addCommentBlock(requests as! [AnyObject?], error as NSError?)
                }
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
