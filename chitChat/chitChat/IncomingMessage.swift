//
//  IncomingMessage.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/11/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import Foundation

class IncomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        
        if type == "text" {
            message = createTextMessage(dictionary)
        }
        if type == "location" {
            
        }
        if type == "picture" {
            
        }
        
        if let mes = message {
            return mes
        }
        
        return nil
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
        
    }
    
}