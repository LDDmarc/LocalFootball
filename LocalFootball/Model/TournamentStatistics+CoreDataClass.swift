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

    var resultsOfLastMatches: [Int] {
           return lastMatches as? [Int] ?? []
       }

    enum CodingKeys: String, CodingKey {
        case tournamentId
        case score
        case position
        case statistics
        case lastMatches
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "TournamentStatistics", in: managedObjectContext)
                else { fatalError("Failed to decode TournamentStatistics") }
        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            tournamentId = try values.decode(Int64.self, forKey: .tournamentId)
            score = try values.decode(Int16.self, forKey: .score)
            position = try values.decode(Int16.self, forKey: .position)
            statistics = try values.decode(Statistics.self, forKey: .statistics)

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func update(with tournamentStatisticsJSON: JSON) {
        tournamentId = tournamentStatisticsJSON[CodingKeys.tournamentId.rawValue].int64Value
        score = tournamentStatisticsJSON[CodingKeys.score.rawValue].int16Value
        position = tournamentStatisticsJSON[CodingKeys.position.rawValue].int16Value

        if let lastMatches = tournamentStatisticsJSON[CodingKeys.lastMatches.rawValue].arrayObject {
            self.lastMatches = lastMatches as NSObject
        }

        statistics?.update(with: tournamentStatisticsJSON[CodingKeys.statistics.rawValue])
    }
}
