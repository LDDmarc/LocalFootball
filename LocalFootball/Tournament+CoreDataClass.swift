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

@objc(Tournament)
public class Tournament: NSManagedObject {
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case imageName = "imageName"
        case info = "info"
        case status = "status"
        case location = "location"
        case tournamentTeams = "TournamentTeams"
        case tournamentMatches = "TournamentMatches"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Tournament", in: managedObjectContext) else { fatalError("Failed to decode Tournament") }
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            name = try values.decode(String?.self, forKey: .name)
            imageName = try values.decode(String?.self, forKey: .imageName)
            info = try values.decode(String?.self, forKey: .info)
            status = try values.decode(Bool.self, forKey: .status)
            
            //location = try values.decode(, forKey: <#T##Tournament.CodingKeys#>)
            
            tournamentTeams = try values.decode([String]?.self, forKey: .tournamentTeams) as NSObject?
            tournamentMatches = try values.decode([String]?.self, forKey: .tournamentMatches) as NSObject?
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}
