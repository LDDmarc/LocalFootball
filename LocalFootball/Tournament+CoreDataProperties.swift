//
//  Tournament+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
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
    @NSManaged public var matches: NSOrderedSet?
    @NSManaged public var teams: NSOrderedSet?

}

// MARK: Generated accessors for matches
extension Tournament {

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

// MARK: Generated accessors for teams
extension Tournament {

    @objc(insertObject:inTeamsAtIndex:)
    @NSManaged public func insertIntoTeams(_ value: Team, at idx: Int)

    @objc(removeObjectFromTeamsAtIndex:)
    @NSManaged public func removeFromTeams(at idx: Int)

    @objc(insertTeams:atIndexes:)
    @NSManaged public func insertIntoTeams(_ values: [Team], at indexes: NSIndexSet)

    @objc(removeTeamsAtIndexes:)
    @NSManaged public func removeFromTeams(at indexes: NSIndexSet)

    @objc(replaceObjectInTeamsAtIndex:withObject:)
    @NSManaged public func replaceTeams(at idx: Int, with value: Team)

    @objc(replaceTeamsAtIndexes:withTeams:)
    @NSManaged public func replaceTeams(at indexes: NSIndexSet, with values: [Team])

    @objc(addTeamsObject:)
    @NSManaged public func addToTeams(_ value: Team)

    @objc(removeTeamsObject:)
    @NSManaged public func removeFromTeams(_ value: Team)

    @objc(addTeams:)
    @NSManaged public func addToTeams(_ values: NSOrderedSet)

    @objc(removeTeams:)
    @NSManaged public func removeFromTeams(_ values: NSOrderedSet)

}
