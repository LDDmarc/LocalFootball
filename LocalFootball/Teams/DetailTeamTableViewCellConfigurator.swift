//
//  DetailTeamTableViewCellConfigurator.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class DetailTeamTableViewCellConfigurator {
    func configureCell(_ cell: DetailTeamTableViewCell, with team: Team) {

        cell.teamLogoData = team.logoImageData
        if let statistics = team.teamStatistics,
            let fullstatistics = statistics.fullStatistics {
            cell.games = fullstatistics.numberOfGames
            cell.wins = fullstatistics.numberOfWins
            cell.goals = fullstatistics.goalsScored
            if let tournamentsCount = statistics.tournamentsStatistics?.count {
                cell.tournaments = tournamentsCount
            }
        }

        if var resultsOfLastMatches = team.teamStatistics?.fullStatistics?.resultsOfLastMatches {

            cell.match1Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
            cell.match2Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
            cell.match3Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
            cell.match4Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
            cell.match5Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil

        }
    }
}
