//
//  Statistics+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 10.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Statistics)
public class Statistics: NSManagedObject, Decodable {

    var resultsOfLastMatches: [Int] {
        return lastMatches as? [Int] ?? []
    }

    enum CodingKeys: String, CodingKey {
        case numberOfGames
        case numberOfWins
        case numberOfLesions
        case numberOfDraws
        case goalsScored
        case goalsConceded
        case penaltyScored
        case penaltyConceded
        case lastMatches
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Statistics", in: managedObjectContext) else { fatalError("Failed to decode Statistics") }
        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            numberOfGames = try values.decode(Int16.self, forKey: .numberOfGames)
            numberOfWins = try values.decode(Int16.self, forKey: .numberOfWins)
            numberOfLesions = try values.decode(Int16.self, forKey: .numberOfLesions)
            numberOfDraws = try values.decode(Int16.self, forKey: .numberOfDraws)

            goalsScored = try values.decode(Int16.self, forKey: .goalsScored)
            goalsConceded = try values.decode(Int16.self, forKey: .goalsConceded)
            penaltyScored = try values.decode(Int16.self, forKey: .penaltyScored)
            penaltyConceded = try values.decode(Int16.self, forKey: .penaltyConceded)

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func update(with jsonDictionary: JSON) {
        numberOfGames = jsonDictionary[CodingKeys.numberOfGames.rawValue].int16Value
        numberOfWins = jsonDictionary[CodingKeys.numberOfWins.rawValue].int16Value
        numberOfLesions = jsonDictionary[CodingKeys.numberOfLesions.rawValue].int16Value
        numberOfDraws = jsonDictionary[CodingKeys.numberOfDraws.rawValue].int16Value

        goalsScored = jsonDictionary[CodingKeys.goalsScored.rawValue].int16Value
        goalsConceded = jsonDictionary[CodingKeys.goalsConceded.rawValue].int16Value
        penaltyScored = jsonDictionary[CodingKeys.penaltyScored.rawValue].int16Value
        penaltyConceded = jsonDictionary[CodingKeys.penaltyConceded.rawValue].int16Value

        if let lastMatches = jsonDictionary[CodingKeys.lastMatches.rawValue].arrayObject {
            self.lastMatches = lastMatches as NSObject
        }
    }
}
