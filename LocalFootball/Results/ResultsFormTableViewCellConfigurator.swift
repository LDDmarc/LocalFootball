//
//  ResultsFormTableViewCellConfigurator.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsFormTableViewCellConfigurator {
    func configureCell(_ cell: ResultsFormTableViewCell, with tournamentStatistics: TournamentStatistics, _ isEven: Bool) {

        cell.position = "\(tournamentStatistics.position)"
        if let teamStatistics = tournamentStatistics.teamStatistics,
            let team = teamStatistics.team {
            cell.teamName = team.name
            if let imageData = team.logoImageData {
                cell.teamLogoData = imageData
            }
        }

        cell.emptyColor = isEven ? .systemBackground : .secondarySystemBackground

        var resultsOfLastMatches = tournamentStatistics.resultsOfLastMatches

        cell.match1Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
        cell.match2Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
        cell.match3Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
        cell.match4Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
        cell.match5Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
        cell.match6Info = !resultsOfLastMatches.isEmpty ? resultsOfLastMatches.removeLast() : nil
    }
}
