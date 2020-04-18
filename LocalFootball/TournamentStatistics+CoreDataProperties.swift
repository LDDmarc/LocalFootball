//
//  TournamentStatistics+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData


extension TournamentStatistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TournamentStatistics> {
        return NSFetchRequest<TournamentStatistics>(entityName: "TournamentStatistics")
    }

    @NSManaged public var position: Int16
    @NSManaged public var score: Int16
    @NSManaged public var tournamentName: String?
    @NSManaged public var statistics: Statistics?
    @NSManaged public var teamStatistics: TeamStatistic?

}
