//
//  MatchResults+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 10.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MatchResults)
public class MatchResults: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case goalsScored = "goalsScored"
        case goalsConceded = "goalsConceded"
        case penaltyScored = "penaltyScored"
        case penaltyConceded = "penaltyConceded"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "MatchResults", in: managedObjectContext) else { fatalError("Failed to decode MatchResults") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            goalsScored = try values.decode(Int16.self, forKey: .goalsScored)
            goalsConceded = try values.decode(Int16.self, forKey: .goalsConceded)
            penaltyScored = try values.decode(Int16.self, forKey: .penaltyScored)
            penaltyConceded = try values.decode(Int16.self, forKey: .penaltyConceded)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}
