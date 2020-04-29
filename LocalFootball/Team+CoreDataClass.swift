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
public class Team: NSManagedObject, FootballNSManagedObjectProtocol {
    
    lazy var teamColors: [String] = {
        if let myColors = colors as? [String] {
            return myColors
        } else {
            return []
        }
    }()
    
    lazy var teamTournamentsNames: [String] = {
        if let myTournaments = tournamentsNames as? [String] {
            return myTournaments
        } else {
            return []
        }
    }()
    
    
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
        case tournamentsNames = "tournamentsNames"
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
            tournamentsNames = try values.decode([String]?.self, forKey: .tournamentsNames) as NSObject?
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func update(with teamJSON: JSON, into context: NSManagedObjectContext) {

        self.id = teamJSON["id"].int64Value
        self.modified = teamJSON["modified"].int64Value
        self.name = teamJSON["name"].string
        self.yearOfFoundation = teamJSON["yearOfFoundation"].int16Value
        self.logoName = teamJSON["logoName"].string
        if let imageName = self.logoName {
            let image = UIImage(named: imageName)
            self.logoImageData = image?.pngData()
        }
        
        self.colors = teamJSON["colors"].arrayObject! as NSObject
        self.tournamentsNames = teamJSON["tournamentsNames"].arrayObject! as NSObject
        
        if self.teamStatistics == nil {
            guard let teamStatistics = NSEntityDescription.insertNewObject(forEntityName: "TeamStatistic", into: context) as? TeamStatistic else {
                print("Error: Failed to create a new object!")
                return
            }
            self.teamStatistics = teamStatistics
        }
        if self.teamStatistics?.fullStatistics == nil {
            guard let fullStatistics = NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as? Statistics else {
                print("Error: Failed to create a new object!")
                return
            }
            self.teamStatistics?.fullStatistics = fullStatistics
        }
        
        if self.teamStatistics?.tournamentsStatistics?.count != self.teamTournamentsNames.count {
            if let currentCount = self.teamStatistics?.tournamentsStatistics?.count {
                for i in 0..<currentCount {
                    context.delete((self.teamStatistics?.tournamentsStatistics![i])! as! NSManagedObject)
                }
            }
           
            let tournamentsStatisticsSet = NSMutableOrderedSet()
            
            for _ in 0..<self.teamTournamentsNames.count {
                guard let tournamentStatistics = NSEntityDescription.insertNewObject(forEntityName: "TournamentStatistics", into: context) as? TournamentStatistics else {
                    print("Error: Failed to create a new object!")
                    return
                }
                tournamentsStatisticsSet.add(tournamentStatistics)
                self.teamStatistics?.tournamentsStatistics = tournamentsStatisticsSet
                
            }
        }

        self.teamStatistics?.update(with: teamJSON["teamStatistics"])
    
    }
}
