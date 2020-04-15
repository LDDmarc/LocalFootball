//
//  Tournament+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 15.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData


extension Tournament {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tournament> {
        return NSFetchRequest<Tournament>(entityName: "Tournament")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var imageName: String?
    @NSManaged public var info: String?
    @NSManaged public var location: NSObject?
    @NSManaged public var name: String?
    @NSManaged public var numberOfTournamentMatches: Int16
    @NSManaged public var numberOfTournamentTeams: Int16
    @NSManaged public var status: Bool
    @NSManaged public var tournamentMatches: NSObject?
    @NSManaged public var tournamentTeams: NSObject?
    @NSManaged public var matches: NSSet?
    @NSManaged public var teams: NSSet?

}

// MARK: Generated accessors for matches
extension Tournament {

    @objc(addMatchesObject:)
    @NSManaged public func addToMatches(_ value: Match)

    @objc(removeMatchesObject:)
    @NSManaged public func removeFromMatches(_ value: Match)

    @objc(addMatches:)
    @NSManaged public func addToMatches(_ values: NSSet)

    @objc(removeMatches:)
    @NSManaged public func removeFromMatches(_ values: NSSet)

}

// MARK: Generated accessors for teams
extension Tournament {

    @objc(addTeamsObject:)
    @NSManaged public func addToTeams(_ value: Team)

    @objc(removeTeamsObject:)
    @NSManaged public func removeFromTeams(_ value: Team)

    @objc(addTeams:)
    @NSManaged public func addToTeams(_ values: NSSet)

    @objc(removeTeams:)
    @NSManaged public func removeFromTeams(_ values: NSSet)

}

extension NSSet {
    func toArray<T>() -> [T] {
        let array = self.map({ $0 as! T})
        return array
    }
}
