//
//  Match+CoreDataClass.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 10.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Match)
public class Match: NSManagedObject, UpdatableManagedObject {

    enum CodingKeys: String, CodingKey {
        case id
        case modified
        case date
        case team1Id
        case team2Id
        case team1Name
        case team2Name
        case tournamentName
        case status
        case tournamentId
        case team1Score
        case team2Score
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let contexUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contexUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Match", in: managedObjectContext) else { fatalError("Failed to decode Match") }
        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try values.decode(Int64.self, forKey: .id)
            modified = try values.decode(Int64.self, forKey: .modified)
            team1Id = try values.decode(Int64.self, forKey: .team1Id)
            team2Id = try values.decode(Int64.self, forKey: .team2Id)

            if let dateStr = try values.decode(String?.self, forKey: .date) {
                date = DateFormatter.readingDateFormatter().date(from: dateStr)
            }
            team1Name = try values.decode(String?.self, forKey: .team1Name)
            team2Name = try values.decode(String?.self, forKey: .team2Name)
            tournamentName = try values.decode(String?.self, forKey: .tournamentName)

            status = try values.decode(Bool.self, forKey: .status)

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func update(with matchJSON: JSON, into context: NSManagedObjectContext) {
        id = matchJSON[CodingKeys.id.rawValue].int64Value
        modified = matchJSON[CodingKeys.modified.rawValue].int64Value
        date = DateFormatter.readingDateFormatter().date(from: matchJSON[CodingKeys.date.rawValue].stringValue)
        status = matchJSON[CodingKeys.status.rawValue].boolValue

        team1Id = matchJSON[CodingKeys.team1Id.rawValue].int64Value
        team2Id = matchJSON[CodingKeys.team2Id.rawValue].int64Value
        team1Name = matchJSON[CodingKeys.team1Name.rawValue].stringValue
        team2Name = matchJSON[CodingKeys.team2Name.rawValue].stringValue
        team1Score = matchJSON[CodingKeys.team1Score.rawValue].int16Value
        team2Score = matchJSON[CodingKeys.team2Score.rawValue].int16Value

        tournamentId = matchJSON[CodingKeys.tournamentId.rawValue].int64Value
        tournamentName = matchJSON[CodingKeys.tournamentName.rawValue].stringValue

        if calendarId != nil {
            if let startDate = date,
                let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate) {
                    EventsCalendarManager(presentingViewController: nil).updateEvent(withIdentifier: calendarId!, by: startDate, by: endDate)
            }
        }

    }
}
