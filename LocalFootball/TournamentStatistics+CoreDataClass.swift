//
//  TournamentStatistics+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(TournamentStatistics)
public class TournamentStatistics: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case tournamentName = "tournamentName"
        case score = "score"
        case position = "position"
        case statistics = "statistics"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "TournamentStatistics", in: managedObjectContext) else { fatalError("Failed to decode TournamentStatistics") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            tournamentName = try values.decode(String?.self, forKey: .tournamentName)
            score = try values.decode(Int16.self, forKey: .score)
            position = try values.decode(Int16.self, forKey: .position)
            statistics = try values.decode(Statistics.self, forKey: .statistics)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func update(with tournamentStatisticsJSON: JSON) {
        self.tournamentName = tournamentStatisticsJSON["tournamentName"].string
        self.score = tournamentStatisticsJSON["score"].int16Value
        self.position = tournamentStatisticsJSON["position"].int16Value
        
        self.statistics?.update(with: tournamentStatisticsJSON["statistics"])
    }
}
