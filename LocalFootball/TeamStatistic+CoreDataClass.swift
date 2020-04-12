//
//  TeamStatistic+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TeamStatistic)
public class TeamStatistic: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case fullStatistics = "fullStatistics"
        case tournamentStatistics = "tournamentStatistics"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "TeamStatistic", in: managedObjectContext) else { fatalError("Failed to decode TeamStatistic") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            fullStatistics = try values.decode(Statistics.self, forKey: .fullStatistics)
            tournamentStatistics = try values.decode(Set<TournamentStatistics>.self, forKey: .tournamentStatistics) as NSSet
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}
