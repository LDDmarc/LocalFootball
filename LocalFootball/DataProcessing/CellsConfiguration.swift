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
    
        if let date = match.date {
            cell.dateLabel.text = DataPresentation.shared.writtingDateFormatter.string(from: date)
        }
        if let team1Obj = match.teams?.firstObject,
            let team2Obj = match.teams?.lastObject,
            let team1 = team1Obj as? Team,
            let team2 = team2Obj as? Team {
            cell.teamsNamesLabel.text = "\(team1.name!) - \(team2.name!)"
            if let team1LogoData = team1.logoImageData {
                cell.team1LogoImageView.image = UIImage(data: team1LogoData)
            }
            if let team2LogoData = team2.logoImageData {
                cell.team2LogoImageView.image = UIImage(data: team2LogoData)
            }
        }
    
        if match.status {
            cell.scoreLabel.textColor = .black
            cell.scoreLabel.text = "\(match.team1Score):\(match.team2Score)"
        } else {
            cell.scoreLabel.textColor = .red
            cell.scoreLabel.text = "❓:❓"
        }
    
    }
    
    func configureCell(_ cell: DetailTeamTableViewCell, with team: Team) {
    
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
            cell.gamesLabel.text = "\(fullstatistics.numberOfGames)"
            cell.winsLabel.text = "\(fullstatistics.numberOfWins)"
            cell.goalsLabel.text = "\(fullstatistics.goalsScored)"
            if let tournamentsCount = statistics.tournamentsStatistics?.count {
                cell.tournamentsLabel.text = "\(tournamentsCount)"
            }
        }
        // TODO:
        let match = team.matches?.array.first as? Match
        if match!.team1Score > match!.team2Score {
            cell.match1Label.backgroundColor = .green
        } else {
            if match!.team1Score == match!.team2Score {
                cell.match1Label.backgroundColor = .gray
            } else {
                cell.match1Label.backgroundColor = .red
            }
        }
    
    }
    
    func configureCell(_ cell: ResultsTableTableViewCell, with tournamentStatistics: TournamentStatistics) {
        cell.positionLabel.text = "\(tournamentStatistics.position)"
        if let teamStatistics = tournamentStatistics.teamStatistics,
            let team = teamStatistics.team,
            let imageData = team.logoImageData {
            cell.teamLogoImageView.image = UIImage(data: imageData)
            cell.teamNameLabel.text = team.name
        }
        cell.numberOfGamesLabel.text = "\(tournamentStatistics.statistics?.numberOfGames ?? 0)"
        cell.numberOfWinsLabel.text = "\(tournamentStatistics.statistics?.numberOfWins ?? 0)"
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
