//
//  Tournament+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 04.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData

extension Tournament {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tournament> {
        return NSFetchRequest<Tournament>(entityName: "Tournament")
    }

    @NSManaged public var dateOfTheBeginning: Date?
    @NSManaged public var dateOfTheEnd: Date?
    @NSManaged public var id: Int64
    @NSManaged public var imageData: Data?
    @NSManaged public var imageName: String?
    @NSManaged public var info: String?
    @NSManaged public var matchesIds: NSObject?
    @NSManaged public var modified: Int64
    @NSManaged public var name: String?
    @NSManaged public var numberOfMatches: Int16
    @NSManaged public var numberOfTeams: Int16
    @NSManaged public var status: Bool
    @NSManaged public var teamsIds: NSObject?

}
