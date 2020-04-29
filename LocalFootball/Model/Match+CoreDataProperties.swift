//
//  Match+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 27.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData


extension Match {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: "Match")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: Int64
    @NSManaged public var location: String?
    @NSManaged public var modified: Int64
    @NSManaged public var status: Bool
    @NSManaged public var team1Name: String?
    @NSManaged public var team2Name: String?
    @NSManaged public var tournamentName: String?
    @NSManaged public var team1Id: Int64
    @NSManaged public var team2Id: Int64
    @NSManaged public var tournamentId: Int64
    @NSManaged public var team1Score: Int16
    @NSManaged public var team2Score: Int16
    @NSManaged public var matchResults: NSOrderedSet?
    @NSManaged public var teams: NSOrderedSet?
    @NSManaged public var tournament: Tournament?

}

// MARK: Generated accessors for matchResults
extension Match {

    @objc(insertObject:inMatchResultsAtIndex:)
    @NSManaged public func insertIntoMatchResults(_ value: MatchResults, at idx: Int)

    @objc(removeObjectFromMatchResultsAtIndex:)
    @NSManaged public func removeFromMatchResults(at idx: Int)

    @objc(insertMatchResults:atIndexes:)
    @NSManaged public func insertIntoMatchResults(_ values: [MatchResults], at indexes: NSIndexSet)

    @objc(removeMatchResultsAtIndexes:)
    @NSManaged public func removeFromMatchResults(at indexes: NSIndexSet)

    @objc(replaceObjectInMatchResultsAtIndex:withObject:)
    @NSManaged public func replaceMatchResults(at idx: Int, with value: MatchResults)

    @objc(replaceMatchResultsAtIndexes:withMatchResults:)
    @NSManaged public func replaceMatchResults(at indexes: NSIndexSet, with values: [MatchResults])

    @objc(addMatchResultsObject:)
    @NSManaged public func addToMatchResults(_ value: MatchResults)

    @objc(removeMatchResultsObject:)
    @NSManaged public func removeFromMatchResults(_ value: MatchResults)

    @objc(addMatchResults:)
    @NSManaged public func addToMatchResults(_ values: NSOrderedSet)

    @objc(removeMatchResults:)
    @NSManaged public func removeFromMatchResults(_ values: NSOrderedSet)

}

// MARK: Generated accessors for teams
extension Match {

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
