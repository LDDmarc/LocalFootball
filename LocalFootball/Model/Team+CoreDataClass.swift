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
import SwiftyJSON

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

@objc(Team)
public class Team: NSManagedObject, UpdatableManagedObject {
    
    var teamColors: [String] {
        get {
            return colors as? [String] ?? []
        }
    }
    
    var teamTournamentsIds: [Int64] {
        get {
            return tournamentsIds as? [Int64] ?? []
        }
    }
    
    var teamMatchesIds: [Int64] {
        get {
            return matchesIds as? [Int64] ?? []
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case modified = "modified"
        case name = "name"
        case yearOfFoundation = "yearOfFoundation"
        case colors = "colors"
        case logoName = "logoName"
        case statistics = "statistics"
        case uuid = "uuid"
        case teamStatistics = "teamStatistics"
        case tournamemtsIds = "tournamemtsIds"
        case matchesIds = "matchesIds"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Team", in: managedObjectContext) else { fatalError("Failed to decode Team") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            
            id = try values.decode(Int64.self, forKey: .id)
            modified = try values.decode(Int64.self, forKey: .modified)
            
            name = try values.decode(String?.self, forKey: .name)
            yearOfFoundation = try values.decode(Int16.self, forKey: .yearOfFoundation)
            
            colors = try values.decode([String]?.self, forKey: .colors) as NSObject?
            
            logoName = try values.decode(String?.self, forKey: .logoName)
            if let imageName = logoName,
                let image = UIImage(named: imageName) {
                let imageData = image.pngData()
                logoImageData = imageData
            }
            
            teamStatistics = try values.decode(TeamStatistic.self, forKey: .teamStatistics)
            tournamentsIds = try values.decode([Int64]?.self, forKey: .tournamemtsIds) as NSObject?
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func update(with teamJSON: JSON, into context: NSManagedObjectContext) {

        id = teamJSON[CodingKeys.id.rawValue].int64Value
        modified = teamJSON[CodingKeys.modified.rawValue].int64Value
        name = teamJSON[CodingKeys.name.rawValue].string
        yearOfFoundation = teamJSON[CodingKeys.yearOfFoundation.rawValue].int16Value
        logoName = teamJSON[CodingKeys.logoName.rawValue].string
        if let imageName = logoName {
            let image = UIImage(named: imageName)
            logoImageData = image?.pngData()
        }
        if let colors = teamJSON[CodingKeys.colors.rawValue].arrayObject {
            self.colors = colors as NSObject
        }
        if let tournamentsIds = teamJSON[CodingKeys.tournamemtsIds.rawValue].arrayObject {
            self.tournamentsIds = tournamentsIds as NSObject
        }
        if let matchesIds = teamJSON[CodingKeys.matchesIds.rawValue].arrayObject {
            self.matchesIds = matchesIds as NSObject
        }
    
        
        if teamStatistics == nil {
            guard let teamStatistics = NSEntityDescription.insertNewObject(forEntityName: "TeamStatistic", into: context) as? TeamStatistic else {
                print("Error: Failed to create a new object!")
                return
            }
            self.teamStatistics = teamStatistics
        }
        if teamStatistics?.fullStatistics == nil {
            guard let fullStatistics = NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as? Statistics else {
                print("Error: Failed to create a new object!")
                return
            }
            teamStatistics?.fullStatistics = fullStatistics
        }
        
        if teamStatistics?.tournamentsStatistics?.count != teamTournamentsIds.count {
            if let currentCount = teamStatistics?.tournamentsStatistics?.count {
                for i in 0..<currentCount {
                    context.delete((teamStatistics?.tournamentsStatistics![i])! as! NSManagedObject)
                }
            }
           
       //     let tournamentsStatisticsSet = NSMutableOrderedSet()
            
            for _ in 0..<teamTournamentsIds.count {
                guard let tournamentStatistics = NSEntityDescription.insertNewObject(forEntityName: "TournamentStatistics", into: context) as? TournamentStatistics else {
                    print("Error: Failed to create a new object!")
                    return
                }
                guard let statistics = NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as? Statistics else {
                    print("Error: Failed to create a new object!")
                    return
                }
                tournamentStatistics.statistics = statistics
                teamStatistics?.addToTournamentsStatistics(tournamentStatistics)
              //  tournamentsStatisticsSet.add(tournamentStatistics)
            }
            
        //    teamStatistics?.tournamentsStatistics = tournamentsStatisticsSet
        }
        teamStatistics?.update(with: teamJSON[CodingKeys.teamStatistics.rawValue])
    }
}
