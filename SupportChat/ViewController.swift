//
//  ViewController.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/15/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import UIKit

class ViewController: ZDUIViewController, UITableViewDataSource, UITableViewDelegate {
    //Todo: Cleanup what is needed here vs. what is setup here
    var dispatcher: ZSCDispatcher!
    
    var incomingMessageStore: IncomingMessageStore!
    var outgoingMessageStore: OutgoingMessageStore!


    var chatAPIUtil: ChatAPIUtil!
    var supportAPIUtil: SupportAPIUtil!
    
    
    var uiActionCreator: UIActionCreator!
    var chatActionCreator: ChatActionCreator!
    var supportActionCreator: SupportActionCreator!

    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textInput: UITextView!
    
    var data: [Action] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This can be refactored out
        dispatcher = ZSCDispatcher()
        incomingMessageStore = IncomingMessageStore(dispatcher: dispatcher)
        outgoingMessageStore = OutgoingMessageStore(dispatcher: dispatcher)
        chatActionCreator = ChatActionCreator(dispatcher: dispatcher)
        supportActionCreator = SupportActionCreator(dispatcher: dispatcher)

        uiActionCreator = UIActionCreator(dispatcher: dispatcher)
        
        chatAPIUtil = ChatAPIUtil(actionCreator: chatActionCreator, outgoingMessageStore: outgoingMessageStore)
        
        //At the moment this guy must be created AFTER ChatAPIUtil, until I refactor in a support and chat store.
        //The support store should wait on the chat store. Currently it works becuase the ChatUtil will respond
        //first to the outgoingStoreNotification
        supportAPIUtil = SupportAPIUtil(actionCreator: supportActionCreator, outgoingMessageStore: outgoingMessageStore)
        //end refactoring out
        
        
        //Subscribe for events this UI is intreseted in
        registerForEvents()
        
        
        //Small hack for text input color
        textInput.layer.borderColor = UIColor.lightText.cgColor
        
    }
    
    func registerForEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.incomingMessageHandler(_:)), name: NSNotification.Name(rawValue: IncomingMessageStoreEvent), object: nil)
    }
    
//Keyboard events
    
    override func keyboardWillHide(_ note: Notification) {
        super.keyboardWillHide(note)
        scrollToBottomOfTable()
    }
    
    override func keyboardWillShow(_ note: Notification) {
        super.keyboardWillShow(note)
        scrollToBottomOfTable()
    }

//Handlers
    func incomingMessageHandler(_ note: Notification) {
        data = incomingMessageStore.messages //"setState"
        tableView.reloadData()
        
        scrollToBottomOfTable()
    }
    

    @IBAction func sendMessage(_ sender: AnyObject) {
        let text = textInput!.text
        if (text != "") {
            //Send message
            //Use a proper action creator
            uiActionCreator.receivedUserMessage(text!)
            //clear
            textInput!.text = "" //This should really be another event
            //Get texview to expand later
        }
        
    }
    
//Tableview stuff
    func scrollToBottomOfTable() {
        //Fuck it
        if (data.count == 0) {
            return
        }
    
        let lastIndexPath = IndexPath(row: data.count-1, section: 0)
        tableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = data[(indexPath as NSIndexPath).row] 
        var cell: UserCell
        
        if (message.isAgent == true) {
            cell = tableView.dequeueReusableCell(withIdentifier: "agentCell", for: indexPath) as! UserCell
        } else { //Should be else if UserCell
            cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        }
        
        
        cell.body!.text = message.message

        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

