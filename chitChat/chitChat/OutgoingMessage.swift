//
//  OutgoingMessage.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/11/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class OutgoingMessage {
    
    private let firebase = FIRDatabase.database().referenceFromURL("https://chittychatty-e7534.firebaseio.com/Message")
    
    let messageDictionary: NSMutableDictionary
    
    init (message: String, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "senderId", "senderName", "date", "status", "type"])
    }
    
    init (message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "latitude", "longitude", "senderId", "senderName", "date", "status", "type"])
    }
    
    init(message: String, pictureData: NSData, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        let pic = pictureData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture", "senderId", "senderName", "date", "status", "type"])
        
    }
    
    func sendMessage(chatRoomID: String, item: NSMutableDictionary) {
        
        let reference = firebase.childByAppendingPath(chatRoomID).childByAutoId()
        
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            if error != nil {
                print("Error, couldn't send message")
            }
        }
        
        //send push notification
        UpdateRecents(chatRoomID, lastMessage: (item["message"] as? String)!)
        
        // update recents here
        
        
    }

}