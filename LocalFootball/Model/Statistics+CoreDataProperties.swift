//
//  Statistics+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 13.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData

extension Statistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistics> {
        return NSFetchRequest<Statistics>(entityName: "Statistics")
    }

    @NSManaged public var goalsConceded: Int16
    @NSManaged public var goalsScored: Int16
    @NSManaged public var lastMatches: NSObject?
    @NSManaged public var numberOfDraws: Int16
    @NSManaged public var numberOfGames: Int16
    @NSManaged public var numberOfLesions: Int16
    @NSManaged public var numberOfWins: Int16
    @NSManaged public var penaltyConceded: Int16
    @NSManaged public var penaltyScored: Int16
    @NSManaged public var teamStatistics: TeamStatistic?
    @NSManaged public var tournamentPartStatistics: NSOrderedSet?

}

// MARK: Generated accessors for tournamentPartStatistics
extension Statistics {

    @objc(insertObject:inTournamentPartStatisticsAtIndex:)
    @NSManaged public func insertIntoTournamentPartStatistics(_ value: TournamentStatistics, at idx: Int)

    @objc(removeObjectFromTournamentPartStatisticsAtIndex:)
    @NSManaged public func removeFromTournamentPartStatistics(at idx: Int)

    @objc(insertTournamentPartStatistics:atIndexes:)
    @NSManaged public func insertIntoTournamentPartStatistics(_ values: [TournamentStatistics], at indexes: NSIndexSet)

    @objc(removeTournamentPartStatisticsAtIndexes:)
    @NSManaged public func removeFromTournamentPartStatistics(at indexes: NSIndexSet)

    @objc(replaceObjectInTournamentPartStatisticsAtIndex:withObject:)
    @NSManaged public func replaceTournamentPartStatistics(at idx: Int, with value: TournamentStatistics)

    @objc(replaceTournamentPartStatisticsAtIndexes:withTournamentPartStatistics:)
    @NSManaged public func replaceTournamentPartStatistics(at indexes: NSIndexSet, with values: [TournamentStatistics])

    @objc(addTournamentPartStatisticsObject:)
    @NSManaged public func addToTournamentPartStatistics(_ value: TournamentStatistics)

    @objc(removeTournamentPartStatisticsObject:)
    @NSManaged public func removeFromTournamentPartStatistics(_ value: TournamentStatistics)

    @objc(addTournamentPartStatistics:)
    @NSManaged public func addToTournamentPartStatistics(_ values: NSOrderedSet)

    @objc(removeTournamentPartStatistics:)
    @NSManaged public func removeFromTournamentPartStatistics(_ values: NSOrderedSet)

}
