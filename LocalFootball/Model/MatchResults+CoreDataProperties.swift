//
//  MatchResults+CoreDataProperties.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 24.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData


extension MatchResults {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchResults> {
        return NSFetchRequest<MatchResults>(entityName: "MatchResults")
    }

    @NSManaged public var goalsConceded: Int16
    @NSManaged public var goalsScored: Int16
    @NSManaged public var penaltyConceded: Int16
    @NSManaged public var penaltyScored: Int16
    @NSManaged public var match: Match?

}
