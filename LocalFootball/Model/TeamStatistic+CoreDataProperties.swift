//
//  TeamStatistic+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 13.05.2020.
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

    @objc(insertObject:inTournamentsStatisticsAtIndex:)
    @NSManaged public func insertIntoTournamentsStatistics(_ value: TournamentStatistics, at idx: Int)

    @objc(removeObjectFromTournamentsStatisticsAtIndex:)
    @NSManaged public func removeFromTournamentsStatistics(at idx: Int)

    @objc(insertTournamentsStatistics:atIndexes:)
    @NSManaged public func insertIntoTournamentsStatistics(_ values: [TournamentStatistics], at indexes: NSIndexSet)

    @objc(removeTournamentsStatisticsAtIndexes:)
    @NSManaged public func removeFromTournamentsStatistics(at indexes: NSIndexSet)

    @objc(replaceObjectInTournamentsStatisticsAtIndex:withObject:)
    @NSManaged public func replaceTournamentsStatistics(at idx: Int, with value: TournamentStatistics)

    @objc(replaceTournamentsStatisticsAtIndexes:withTournamentsStatistics:)
    @NSManaged public func replaceTournamentsStatistics(at indexes: NSIndexSet, with values: [TournamentStatistics])

    @objc(addTournamentsStatisticsObject:)
    @NSManaged public func addToTournamentsStatistics(_ value: TournamentStatistics)

    @objc(removeTournamentsStatisticsObject:)
    @NSManaged public func removeFromTournamentsStatistics(_ value: TournamentStatistics)

    @objc(addTournamentsStatistics:)
    @NSManaged public func addToTournamentsStatistics(_ values: NSOrderedSet)

    @objc(removeTournamentsStatistics:)
    @NSManaged public func removeFromTournamentsStatistics(_ values: NSOrderedSet)

}
