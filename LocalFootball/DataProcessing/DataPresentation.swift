//
//  DataPresentation.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 21.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation

class DataPresentation {
    static let shared = DataPresentation()
    private init() {}
    
    var readingDateFormatter: DateFormatter = {
           let df = DateFormatter()
           df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
           return df
       }()
       
       var writtingDateFormatter: DateFormatter = {
           let df = DateFormatter()
           df.dateStyle = .medium
           df.timeStyle = .short
           return df
       }()
    
}
