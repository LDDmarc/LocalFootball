//
//  MatchTableViewCellConfigurator.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import CoreData

class MatchTableViewCellConfigurator {
    func configureCell(_ cell: MatchTableViewCell, with match: Match) {

        var team1ImageData: Data?
        var team2ImageData: Data?
        var teamsNames = ""

        if let team1Obj = match.teams?.firstObject,
            let team1 = team1Obj as? Team {
            team1ImageData = team1.logoImageData
            if let team1Name = team1.name {
                teamsNames += team1Name
            }
        }
        if let team2Obj = match.teams?.lastObject,
            let team2 = team2Obj as? Team {
            team2ImageData = team2.logoImageData
            if let team2Name = team2.name {
                teamsNames += " - " + team2Name
            }
        }

        var score: String?
        if match.status {
            score = "\(match.team1Score):\(match.team2Score)"
        } else {
             score = "❓:❓"
        }

        cell.teamsNames = teamsNames
        cell.team1ImageData = team1ImageData
        cell.team2ImageData = team2ImageData
        cell.score = score
        cell.tournamentName = match.tournamentName
        cell.date = match.date
        cell.status = match.status
        cell.isEventInCalendar = (match.calendarId != nil) ? true : false
    }
}
