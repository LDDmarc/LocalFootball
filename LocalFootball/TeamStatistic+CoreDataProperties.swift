//
//  TeamStatistic+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
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
    @NSManaged public var tournamentStatistics: NSSet?
    @NSManaged public var team: Team?

}

// MARK: Generated accessors for tournamentStatistics
extension TeamStatistic {

    @objc(addTournamentStatisticsObject:)
    @NSManaged public func addToTournamentStatistics(_ value: TournamentStatistics)

    @objc(removeTournamentStatisticsObject:)
    @NSManaged public func removeFromTournamentStatistics(_ value: TournamentStatistics)

    @objc(addTournamentStatistics:)
    @NSManaged public func addToTournamentStatistics(_ values: NSSet)

    @objc(removeTournamentStatistics:)
    @NSManaged public func removeFromTournamentStatistics(_ values: NSSet)

}
