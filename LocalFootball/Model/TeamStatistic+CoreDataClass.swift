//
//  TeamStatistic+CoreDataClass.swift
//  LocalFootballZ
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(TeamStatistic)
public class TeamStatistic: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case fullStatistics = "fullStatistics"
        case tournamentsStatistics = "tournamentStatistics"
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "TeamStatistic", in: managedObjectContext) else { fatalError("Failed to decode TeamStatistic") }
        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            fullStatistics = try values.decode(Statistics.self, forKey: .fullStatistics)
            let tournamentStatistics = try values.decode([TournamentStatistics].self, forKey: .tournamentsStatistics)
            tournamentStatistics.forEach { self.addToTournamentsStatistics($0) }

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func update(with teamStatisticsJSON: JSON) {
        fullStatistics?.update(with: teamStatisticsJSON[CodingKeys.fullStatistics.rawValue])
        if let tournamentsStatistics = tournamentsStatistics {
            for (index, tournamentStatistics) in tournamentsStatistics.enumerated() {
                (tournamentStatistics as? TournamentStatistics)?.update(with: teamStatisticsJSON[CodingKeys.tournamentsStatistics.rawValue].arrayValue[index])
            }
        }
    }

}
