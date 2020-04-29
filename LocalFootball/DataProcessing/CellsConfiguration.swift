//
//  CellsConfiguration.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 18.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CellsConfiguration {
    
    static let shared = CellsConfiguration()
    private init() { }
    
    func configureCell(_ cell: MatchTableViewCell, with match: Match) {
        
        if let tournamentName = match.tournamentName {
            cell.tournamentNameLabel.text = tournamentName
        }
        
        if let date = match.date {
            cell.dateLabel.text = DataPresentation.shared.writtingDateFormatter.string(from: date)
        }
        
        if let team1 = match.teams?.firstObject,
            let team = team1 as? Team {
            cell.team1NameLabel.text = team.name
            if let logoData = team.logoImageData {
                cell.team1LogoImageView.image = UIImage(data: logoData)
            }
        }
        
        if match.status {
            cell.teamScoreLabel.textColor = .black
            cell.teamScoreLabel.text = "\(match.team1Score):\(match.team2Score)"
        } else {
            cell.teamScoreLabel.textColor = .red
            cell.teamScoreLabel.text = "❓:❓"
        }
        
        if let team2 = match.teams?.lastObject,
            let team = team2 as? Team {
            cell.team2NameLabel.text = team.name
            if let logoData = team.logoImageData {
                cell.team2LogoImageView.image = UIImage(data: logoData)
            }
        }
    }
    
    func configureCell(_ cell: DetailTeamTableViewCell, with team: Team) {
        cell.teamNameLabel.text = team.name
        
        if let data = team.logoImageData {
            cell.teamLogoImageView.image = UIImage(data: data)
        }
        var str = "Цвета: "
        team.teamColors.forEach {
            str += $0
            str += " "
        }
        cell.colorsLabel.text = str
        
        cell.yearOfFoundationLabel.text = "Год основания: \(team.yearOfFoundation)"
        if let statistics = team.teamStatistics,
            let fullstatistics = statistics.fullStatistics {
            cell.gamesLabel.text = "Игр: \(fullstatistics.numberOfGames)"
            cell.winsLabel.text = "Побед: \(fullstatistics.numberOfWins)"
            cell.goalsLabel.text = "Голов: \(fullstatistics.goalsScored)"
            if let tournamentsCount = statistics.tournamentsStatistics?.count {
                cell.tournamentsLabel.text = "Турниров: \(tournamentsCount)"
            }
        }
        
    }
    
    var dateFormatter: DateFormatter = {
           let df = DateFormatter()
           df.dateStyle = .medium
           df.timeStyle = .none
           return df
       }()
    func configureCell(_ cell: TournamentTableViewCell, with tournament: Tournament) {
        cell.tournamentNameLabel.text = tournament.name
        if let imageData = tournament.imageData {
            cell.tournamentImageView.image = UIImage(data: imageData)
        }
       
        cell.tournamentTeamsLabel.text = "🥅 Команд: \(tournament.numberOfTeams)"
        
//        if !tournament.status {
//            cell.tournamentStatusLabel.isHidden = false
//        }
        
        cell.tournamentInfoLabel.text = tournament.info
        
        if let date1 = tournament.dateOfTheBeginning,
            let date2 = tournament.dateOfTheEnd {
            cell.tournamentDatesLabel.text = "🗓 Даты: \(dateFormatter.string(from: date1)) - \(dateFormatter.string(from: date2))"
        }
        
        
    }
}
