//
//  Match+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 10.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Match)
public class Match: NSManagedObject, Decodable {
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }()
    
    var results: [MatchResults] {
        get {
            matchResults.flatMap { $0.allObjects as? [MatchResults] } ?? []
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case team1Name = "team1Name"
        case team2Name = "team2Name"
        case matchResults = "matchResults"
        
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Match", in: managedObjectContext) else { fatalError("Failed to decode Match") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {

            if let dateStr = try values.decode(String?.self, forKey: .date) {
                date = dateFormatter.date(from: dateStr)
            }
            team1Name = try values.decode(String?.self, forKey: .team1Name)
            team2Name = try values.decode(String?.self, forKey: .team2Name)
            
            matchResults = try values.decode(Set<MatchResults>.self, forKey: .matchResults) as NSSet
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}
