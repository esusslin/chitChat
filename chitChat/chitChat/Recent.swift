//
//  Recent.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/8/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import Foundation

let firebase = FIRDatabase.database().referenceFromURL("https://chittychatty-e7534.firebaseio.com/")
let backendless = Backendless.sharedInstance()
let currentUser = backendless.userService.currentUser

//MARK: create chatroom

func startChat(user1: BackendlessUser, user2: BackendlessUser) -> String {
    //user1 is current user
    let userId1: String = user1.objectId
    let userId2: String = user2.objectId
    
    var chatRoomId: String = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0  {
        chatRoomId = userId1.stringByAppendingString(userId2)
    } else {
        chatRoomId = userId2.stringByAppendingString(userId1)
    }
    
    let members = [userId1, userId2]
    
    CreateRecent(userId1, chatRoomID: chatRoomId, members: members, withUserUsername: user2.name!, withUseruserId: userId2)
    
    CreateRecent(userId2, chatRoomID: chatRoomId, members: members, withUserUsername: user1.name!, withUseruserId: userId1)
    
    return chatRoomId
}

//MARK: Create RecentItem

func CreateRecent(userId: String, chatRoomID: String, members: [String], withUserUsername: String, withUseruserId: String) {
    
    firebase.childByAppendingPath("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock:{
        snapshot in
        
        var createRecent = true
    
        if snapshot.exists() {
            for recent in (snapshot.value?.allValues)! {
                
                if recent["userId"] as! String == userId {
                    createRecent = false
                }
            }
        }
        
        if createRecent {
            
            CreateRecentItem(userId, chatRoomID: chatRoomID, members: members, withUserUsername: withUserUsername, withUserUserId: withUseruserId)
        }

    })
    
}

func CreateRecentItem(userId: String, chatRoomID: String, members: [String], withUserUsername: String, withUserUserId: String) {
    
    let ref = firebase.childByAppendingPath("Recent").childByAutoId()
    
    let recentId = ref.key
    let date = dateFormatter().stringFromDate(NSDate())
    
    let recent = ["recentId" : recentId, "userId" : userId, "chatRoomID" : chatRoomID, "members" : members, "withUserUsername" : withUserUsername, "lastMessage" : "", "counter" : 0, "date" : date, "withUserUserId" : withUserUserId]
    
//    // save to firebase
    
    ref.setValue(recent) { (error, ref) -> Void in
        if error != nil {
            print("error creating recent \(error)")
        }
    }
}

//MARK: Delete Recent functions

func DeleteRecentItem(recent: NSDictionary) {
    
    firebase.childByAppendingPath("Recent").childByAppendingPath((recent["recentId"] as? String)!).removeValueWithCompletionBlock { (error, ref) -> Void in
        
    }
}

//MARK: helper functions

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}