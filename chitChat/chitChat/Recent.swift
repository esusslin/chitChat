//
//  Recent.swift
//  chitChat
//
//  Created by Emmet Susslin on 7/8/16.
//  Copyright © 2016 Emmet Susslin. All rights reserved.
//

import Foundation



private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}