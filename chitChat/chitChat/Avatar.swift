//
//  Avatar.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/14/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import Foundation

func uploadAvatar(image: UIImage, result: (imageLink: String?) ->Void) {
    
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    
    let dateString = dateFormatter().stringFromDate(NSDate())
    
    let fileName = "Img/" + dateString + ".jpeg"
    
    backendless.fileService.upload(fileName, content: imageData, response: { (file) -> Void in
        
        result(imageLink: file.fileURL)
        
    }) { (fault: Fault!) -> Void in
        print("error uploading avatar image : \(fault)")
    }
}

func getImageFromURL(url: String, result: (image: UIImage?) ->Void) {
    
    let URL = NSURL(string: url)
//    print(URL)
    
    let downloadQue = dispatch_queue_create("imageDownloadQue", nil)
    
    dispatch_async(downloadQue) { () -> Void in
        let data = NSData(contentsOfURL: URL!)
        
//        print(data)
        
        let image: UIImage!
        
//        print(image)
        
        if data != nil {
            image = UIImage(data: data!)
            
            dispatch_async(dispatch_get_main_queue()) {
                result(image: image)
            }
            }
        }
}