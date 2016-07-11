//
//  ChatViewController.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/9/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController {
    
    let ref = FIRDatabase.database().referenceFromURL("https://chittychatty-e7534.firebaseio.com/Message")
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var withUser: BackendlessUser?
    var recent: NSDictionary?
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    
    
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    let incomingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = currentUser.objectId
        self.senderDisplayName = currentUser.name
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        //load firebase messages
        loadMessages()
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: JSQMessages dataSource functions
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == currentUser.objectId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId ==  currentUser.objectId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
        
    }
    
    //MARK: JSQMessages Delegate function
    
    override func didPressSendButton(sender: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if text != "" {
            sendMessage(text, date: date, picture: nil, location: nil)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("accessory button pressed")
    }
    
    //MARK: send Message
    
    func sendMessage(text: String?, date: NSDate, picture: UIImage?, location: String?) {
        
        var outgoingMessage = OutgoingMessage?()
        
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId!, senderName: currentUser.name!, date: date, status: "Delivered", type: "text")
            
        }
        
        //if pic 
        
        if let pic = picture {
            
        }
        
        //if location
        
        if let loc = location {
            
        }
        
        //play message sent sound 
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
        
    }
    
    //MARK: load messages
    
    func loadMessages() {
        
        ref.childByAppendingPath(chatRoomId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            //get dictionaries
            
            //create JSQ messages
            
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
            
            
            })
        
        ref.childByAppendingPath(chatRoomId).observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            if snapshot.exists() {
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {
                    
                    let incoming = self.insertMessage(item)
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                        
                    }
                    
                    self.finishSendingMessageAnimated(true)
                    
                    
                } else {
                    self.loaded.append(item)
                }
            }
        })
        
        ref.childByAppendingPath(chatRoomId).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            //updated message
        })
        
        ref.childByAppendingPath(chatRoomId).observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            //deleted message
        })
    }
    
    func insertMessages() {
        for item in loaded {
            //create message
        }
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if self.senderId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
        
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        if self.senderId == item["senderId"] as! String {
            return true
        } else {
            return false
        }
    }
}
