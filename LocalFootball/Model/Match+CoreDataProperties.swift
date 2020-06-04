//
//  Match+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.05.2020.
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
    @NSManaged public var team1Id: Int64
    @NSManaged public var team1Name: String?
    @NSManaged public var team1Score: Int16
    @NSManaged public var team2Id: Int64
    @NSManaged public var team2Name: String?
    @NSManaged public var team2Score: Int16
    @NSManaged public var tournamentId: Int64
    @NSManaged public var tournamentName: String?
    @NSManaged public var calendarId: String?
    @NSManaged public var teams: NSOrderedSet?

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
