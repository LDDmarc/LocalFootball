//
//  Team+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var colors: NSObject?
    @NSManaged public var emblemaImageData: Data?
    @NSManaged public var emblemaName: String?
    @NSManaged public var name: String?
    @NSManaged public var yearOfFoundation: Int16
    @NSManaged public var matches: NSSet?
    @NSManaged public var tournament: NSSet?
    @NSManaged public var teamStatistics: TeamStatistic?

}

// MARK: Generated accessors for matches
extension Team {

    @objc(addMatchesObject:)
    @NSManaged public func addToMatches(_ value: Match)

    @objc(removeMatchesObject:)
    @NSManaged public func removeFromMatches(_ value: Match)

    @objc(addMatches:)
    @NSManaged public func addToMatches(_ values: NSSet)

    @objc(removeMatches:)
    @NSManaged public func removeFromMatches(_ values: NSSet)

}

// MARK: Generated accessors for tournament
extension Team {

    @objc(addTournamentObject:)
    @NSManaged public func addToTournament(_ value: Tournament)

    @objc(removeTournamentObject:)
    @NSManaged public func removeFromTournament(_ value: Tournament)

    @objc(addTournament:)
    @NSManaged public func addToTournament(_ values: NSSet)

    @objc(removeTournament:)
    @NSManaged public func removeFromTournament(_ values: NSSet)

}
