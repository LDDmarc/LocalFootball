//
//  TeamStatistic+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData


extension TeamStatistic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamStatistic> {
        return NSFetchRequest<TeamStatistic>(entityName: "TeamStatistic")
    }

    @NSManaged public var fullStatistics: Statistics?
    @NSManaged public var team: Team?
    @NSManaged public var tournamentsStatistics: NSOrderedSet?

}

// MARK: Generated accessors for tournamentsStatistics
extension TeamStatistic {

    @objc(insertObject:inTournamentStatisticsAtIndex:)
    @NSManaged public func insertIntoTournamentStatistics(_ value: TournamentStatistics, at idx: Int)

    @objc(removeObjectFromTournamentStatisticsAtIndex:)
    @NSManaged public func removeFromTournamentStatistics(at idx: Int)

    @objc(insertTournamentStatistics:atIndexes:)
    @NSManaged public func insertIntoTournamentStatistics(_ values: [TournamentStatistics], at indexes: NSIndexSet)

    @objc(removeTournamentStatisticsAtIndexes:)
    @NSManaged public func removeFromTournamentStatistics(at indexes: NSIndexSet)

    @objc(replaceObjectInTournamentStatisticsAtIndex:withObject:)
    @NSManaged public func replaceTournamentStatistics(at idx: Int, with value: TournamentStatistics)

    @objc(replaceTournamentStatisticsAtIndexes:withTournamentStatistics:)
    @NSManaged public func replaceTournamentStatistics(at indexes: NSIndexSet, with values: [TournamentStatistics])

    @objc(addTournamentStatisticsObject:)
    @NSManaged public func addToTournamentStatistics(_ value: TournamentStatistics)

    @objc(removeTournamentStatisticsObject:)
    @NSManaged public func removeFromTournamentStatistics(_ value: TournamentStatistics)

    @objc(addTournamentStatistics:)
    @NSManaged public func addToTournamentStatistics(_ values: NSOrderedSet)

    @objc(removeTournamentStatistics:)
    @NSManaged public func removeFromTournamentStatistics(_ values: NSOrderedSet)

}
