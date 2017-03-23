//
//  SupportChatTests.swift
//  SupportChatTests
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import XCTest
@testable import SupportChat

class SupportChatTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDispatcher() {
        let dispatcher = ZSCDispatcher()
        let callbackExpectation = self.expectationWithDescription("Callback was called back")
        
        dispatcher.register({ClosureType in
            NSLog(ClosureType)
            callbackExpectation.fulfill()
        })
        
        dispatcher.dispatch("Callback")
        
    
        waitForExpectationsWithTimeout(1) { error in
            //
        }
    }
}
