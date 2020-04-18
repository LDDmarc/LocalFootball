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
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case team1Name = "team1Name"
        case team2Name = "team2Name"
        case matchResults = "matchResults"
        case tournamentName = "tournamentName"
        case status = "status"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Match", in: managedObjectContext) else { fatalError("Failed to decode Match") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {

            if let dateStr = try values.decode(String?.self, forKey: .date) {
                date = DataProcessing.shared.readingDateFormatter.date(from: dateStr)
            }
            team1Name = try values.decode(String?.self, forKey: .team1Name)
            team2Name = try values.decode(String?.self, forKey: .team2Name)
            tournamentName = try values.decode(String?.self, forKey: .tournamentName)
            
            let matchResults = try values.decode([MatchResults].self, forKey: .matchResults)
            matchResults.forEach { self.addToMatchResults($0) }
            
            status = try values.decode(Bool.self, forKey: .status)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}
