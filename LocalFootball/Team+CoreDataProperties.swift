//
//  Team+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 15.04.2020.
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
    @NSManaged public var logoImageData: Data?
    @NSManaged public var logoName: String?
    @NSManaged public var name: String?
    @NSManaged public var tournamentsNames: NSObject?
    @NSManaged public var yearOfFoundation: Int16
    @NSManaged public var matches: NSOrderedSet?
    @NSManaged public var teamStatistics: TeamStatistic?
    @NSManaged public var tournaments: NSSet?

}

// MARK: Generated accessors for matches
extension Team {

    @objc(insertObject:inMatchesAtIndex:)
    @NSManaged public func insertIntoMatches(_ value: Match, at idx: Int)

    @objc(removeObjectFromMatchesAtIndex:)
    @NSManaged public func removeFromMatches(at idx: Int)

    @objc(insertMatches:atIndexes:)
    @NSManaged public func insertIntoMatches(_ values: [Match], at indexes: NSIndexSet)

    @objc(removeMatchesAtIndexes:)
    @NSManaged public func removeFromMatches(at indexes: NSIndexSet)

    @objc(replaceObjectInMatchesAtIndex:withObject:)
    @NSManaged public func replaceMatches(at idx: Int, with value: Match)

    @objc(replaceMatchesAtIndexes:withMatches:)
    @NSManaged public func replaceMatches(at indexes: NSIndexSet, with values: [Match])

    @objc(addMatchesObject:)
    @NSManaged public func addToMatches(_ value: Match)

    @objc(removeMatchesObject:)
    @NSManaged public func removeFromMatches(_ value: Match)

    @objc(addMatches:)
    @NSManaged public func addToMatches(_ values: NSOrderedSet)

    @objc(removeMatches:)
    @NSManaged public func removeFromMatches(_ values: NSOrderedSet)

}

// MARK: Generated accessors for tournaments
extension Team {

    @objc(addTournamentsObject:)
    @NSManaged public func addToTournaments(_ value: Tournament)

    @objc(removeTournamentsObject:)
    @NSManaged public func removeFromTournaments(_ value: Tournament)

    @objc(addTournaments:)
    @NSManaged public func addToTournaments(_ values: NSSet)

    @objc(removeTournaments:)
    @NSManaged public func removeFromTournaments(_ values: NSSet)

}
