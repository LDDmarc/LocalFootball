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

@objc(Tournament)
public class Tournament: NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case imageName = "imageName"
        case info = "info"
        case status = "status"
        case location = "location"
        case numberOfTournamentTeams = "numberOfTournamentTeams"
        case tournamentTeams = "tournamentTeams"
        case numberOfTournamentMatches = "numberOfTournamentMatches"
        case dateOfTheBeginning = "dateOfTheBeginning"
        case dateOfTheEnd = "dateOfTheEnd"
    }
    
    lazy var tournamentTeamsNames: [String] = {
        if let myTournamentTeamsNames = tournamentTeams as? [String] {
            return myTournamentTeamsNames
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
            
            numberOfTournamentTeams = try values.decode(Int16.self, forKey: .numberOfTournamentTeams)
            tournamentTeams = try values.decode([String]?.self, forKey: .tournamentTeams) as NSObject?
            numberOfTournamentMatches = try values.decode(Int16.self, forKey: .numberOfTournamentMatches)
           
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}
