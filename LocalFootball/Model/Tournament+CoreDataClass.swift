//
//  Tournament+CoreDataClass.swift
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

@objc(Tournament)
public class Tournament: NSManagedObject, UpdatableManagedObject {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case modified = "modified"
        case name = "name"
        case imageName = "imageName"
        case info = "info"
        case status = "status"
        case numberOfTeams = "numberOfTeams"
        case tournamentTeams = "tournamentTeams"
        case numberOfMatches = "numberOfMatches"
        case dateOfTheBeginning = "dateOfTheBeginning"
        case dateOfTheEnd = "dateOfTheEnd"
        case teamsIds = "teamsIds"
        case matchesIds = "matchesIds"
    }
    
    lazy var tournamentTeamsIds: [Int64] = {
        if let myTournamentTeamsNames = teamsIds as? [Int64] {
            return myTournamentTeamsNames
        } else {
            return []
        }
    }()
    lazy var tournamentMatchesIds: [Int64] = {
        if let myTournamentMatchesIds = matchesIds as? [Int64] {
            return myTournamentMatchesIds
        } else {
            return []
        }
    }()
    
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Tournament", in: managedObjectContext) else { fatalError("Failed to decode Tournament") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            name = try values.decode(String?.self, forKey: .name)
            
            imageName = try values.decode(String?.self, forKey: .imageName)
            if let myimageName = imageName,
                let myimage = UIImage(named: myimageName) {
                let myimageData = myimage.pngData()
                imageData = myimageData
            }
            
            info = try values.decode(String?.self, forKey: .info)
            status = try values.decode(Bool.self, forKey: .status)
            
            if let beginDate = try values.decode(String?.self, forKey: .dateOfTheBeginning) {
                dateOfTheBeginning = DataPresentation.shared.readingDateFormatter.date(from: beginDate)
            }
            if let endDate = try values.decode(String?.self, forKey: .dateOfTheEnd) {
                dateOfTheEnd = DataPresentation.shared.readingDateFormatter.date(from: endDate)
            }
            
            numberOfTeams = try values.decode(Int16.self, forKey: .numberOfTeams)
            teamsIds = try values.decode([Int64]?.self, forKey: .tournamentTeams) as NSObject?
            numberOfMatches = try values.decode(Int16.self, forKey: .numberOfMatches)
            matchesIds = try values.decode([Int64]?.self, forKey: .matchesIds) as NSObject?
           
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func update(with tournamentJSON: JSON, into context: NSManagedObjectContext) {
        id = tournamentJSON[CodingKeys.id.rawValue].int64Value
        modified = tournamentJSON[CodingKeys.modified.rawValue].int64Value
        name = tournamentJSON[CodingKeys.name.rawValue].string
        info = tournamentJSON[CodingKeys.info.rawValue].string
        dateOfTheBeginning = DataPresentation.shared.readingDateFormatter.date(from: tournamentJSON[CodingKeys.dateOfTheBeginning.rawValue].stringValue)
        dateOfTheEnd = DataPresentation.shared.readingDateFormatter.date(from: tournamentJSON[CodingKeys.dateOfTheEnd.rawValue].stringValue)
        imageName = tournamentJSON[CodingKeys.imageName.rawValue].stringValue
        if let imageName = imageName {
            let image = UIImage(named: imageName)
            imageData = image?.pngData()
        }
        numberOfTeams = tournamentJSON[CodingKeys.numberOfTeams.rawValue].int16Value
        numberOfMatches = tournamentJSON[CodingKeys.numberOfMatches.rawValue].int16Value
        status = tournamentJSON[CodingKeys.status.rawValue].boolValue
        if let teamsIds = tournamentJSON[CodingKeys.teamsIds.rawValue].arrayObject {
            self.teamsIds = teamsIds as NSObject
        }
        if let matchesIds = tournamentJSON[CodingKeys.matchesIds.rawValue].arrayObject {
            self.matchesIds = matchesIds as NSObject
        }
    }
    
}
