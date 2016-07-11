//
//  OutgoingMessage.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/11/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    private let firebase = FIRDatabase.database().referenceFromURL("https://chittychatty-e7534.firebaseio.com/Message")
    
    let messageDictionary: NSMutableDictionary
    
    init (message: String, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "senderId", "senderName", "date", "status", "type"])
    }
    
    init(message: String, pictureData: NSData, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        let pic = pictureData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, pic, latitude, longitude, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture", "latitude", "longitude", "senderId", "senderName", "date", "status", "type"])
        
    }
    
    func mendMessage(chatRoomID: String, item: NSMutableDictionary) {
        
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