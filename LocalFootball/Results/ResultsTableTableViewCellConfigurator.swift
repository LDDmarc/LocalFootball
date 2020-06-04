//
//  ResultsTableTableViewCellConfigurator.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsTableTableViewCellConfigurator {

    func configureCell(_ cell: ResultsTableTableViewCell, with tournamentStatistics: TournamentStatistics) {

        cell.position = "\(tournamentStatistics.position)"
        if let teamStatistics = tournamentStatistics.teamStatistics,
            let team = teamStatistics.team {
            cell.teamName = team.name
            if let imageData = team.logoImageData {
                cell.teamLogoData = imageData
            }
        }

        cell.numberOfGames = "\(tournamentStatistics.statistics?.numberOfGames ?? 0)"
        cell.numberOfWins = "\(tournamentStatistics.statistics?.numberOfWins ?? 0)"
        cell.numberOfDraws = "\(tournamentStatistics.statistics?.numberOfDraws ?? 0)"
        cell.numberOfLesions = "\(tournamentStatistics.statistics?.numberOfLesions ?? 0)"
        cell.numberOfGoalsAndMissed = "\(tournamentStatistics.statistics?.goalsScored ?? 0) - \(tournamentStatistics.statistics?.goalsConceded ?? 0)"
        cell.score = "\(tournamentStatistics.score)"
    }
}
