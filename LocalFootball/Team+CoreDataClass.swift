//
//  Team+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 10.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

@objc(Team)
public class Team: NSManagedObject, Decodable {
    
    var teamColors: [String] {
        get {
            if let myColors = colors as? [String] {
                return myColors
            } else {
                return [""]
            }
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case yearOfFoundation = "yearOfFoundation"
        case colors = "colors"
        case emblemaName = "emblemaName"
        case statistics = "statistics"
        case uuid = "uuid"
        case teamStatistics = "teamStatistics"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Team", in: managedObjectContext) else { fatalError("Failed to decode Team") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
         //   uuid = try values.decode(UUID.self, forKey: .uuid)
            name = try values.decode(String?.self, forKey: .name)
            yearOfFoundation = try values.decode(Int16.self, forKey: .yearOfFoundation)
            
            colors = try values.decode([String]?.self, forKey: .colors) as NSObject?
            
            emblemaName = try values.decode(String?.self, forKey: .emblemaName)
            if let imageName = emblemaName,
                let image = UIImage(named: imageName) {
                let imageData = image.pngData()
                emblemaImageData = imageData
            }
            
            teamStatistics = try values.decode(TeamStatistic.self, forKey: .teamStatistics)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}
