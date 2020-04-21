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

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}

@objc(Team)
public class Team: NSManagedObject, Decodable {
    
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
            //uuid = try values.decode(UUID.self, forKey: .uuid)
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
    
    func update(with jsonDictionary: [String: Any]) throws {
        guard let name = jsonDictionary["name"] as? String,
            let yearOfFoundation = jsonDictionary["yearOfFoundation"] as? Int16,
            let logoName = jsonDictionary["logoName"] as? String
            else {
                throw NSError(domain: "", code: 100, userInfo: nil)
        }
        self.name = name
        self.yearOfFoundation = yearOfFoundation
        self.logoName = logoName
        let image = UIImage(named: logoName)
        self.logoImageData = image?.pngData()
        
    }
}
