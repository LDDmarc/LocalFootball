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
    
    enum CodingKeys: String, CodingKey {
        case numberOfGames = "numberOfGames"
        case numberOfWins = "numberOfWins"
        case numberOfLesions = "numberOfLesions"
        case numberOfDraws = "numberOfDraws"
        case goalsScored = "goalsScored"
        case goalsConceded = "goalsConceded"
        case penaltyScored = "penaltyScored"
        case penaltyConceded = "penaltyConceded"
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
        self.numberOfGames = jsonDictionary["numberOfGames"].int16Value
        self.numberOfWins = jsonDictionary["numberOfWins"].int16Value
        self.numberOfLesions = jsonDictionary["numberOfLesions"].int16Value
        self.numberOfDraws = jsonDictionary["numberOfDraws"].int16Value
        
        self.goalsScored = jsonDictionary["goalsScored"].int16Value
        self.goalsConceded = jsonDictionary["goalsConceded"].int16Value
        self.penaltyScored = jsonDictionary["penaltyScored"].int16Value
        self.penaltyConceded = jsonDictionary["penaltyConceded"].int16Value
    }
}
