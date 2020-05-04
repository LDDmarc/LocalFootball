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
            cell.dateLabel.text = DateFormatter.writtingDateFormatter().string(from: date)
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
            
            if match.status {
                cell.scoreLabel.textColor = .label
                if match.team1Id != team1.id {
                    cell.scoreLabel.text = "\(match.team2Score):\(match.team1Score)"
                } else {
                    cell.scoreLabel.text = "\(match.team1Score):\(match.team2Score)"
                }
            } else {
                cell.scoreLabel.textColor = .systemRed
                cell.scoreLabel.text = "❓:❓"
            }
            
        }
    }
    
    func configureCell(_ cell: DetailTeamTableViewCell, with team: Team, with lastMatches: [Match]) {
        
        var matches = lastMatches
        
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
        
        for (label, view) in [(cell.match1Label, cell.match1View), (cell.match2Label, cell.match2View), (cell.match3Label, cell.match3View), (cell.match4Label, cell.match4View), (cell.match5Label, cell.match5View)] {
            if !matches.isEmpty {
                let match = matches.removeFirst()
                if match.team1Score > match.team2Score {
                    if match.team1Id == team.id {
                        view?.backgroundColor = .systemGreen
                        label?.text = "В"
                        label?.isHidden = false
                    } else {
                        view?.backgroundColor = .systemRed
                        label?.text = "П"
                        label?.isHidden = false
                    }
                } else if match.team1Score < match.team2Score {
                    if match.team1Id == team.id {
                        view?.backgroundColor = .systemRed
                        label?.text = "П"
                        label?.isHidden = false
                    } else {
                        view?.backgroundColor = .systemGreen
                        label?.text = "В"
                        label?.isHidden = false
                    }
                } else if match.team1Score == match.team2Score {
                    view?.backgroundColor = .systemGray
                    label?.text = "Н"
                    label?.isHidden = false
                }
            } else {
                view?.backgroundColor = .systemGray6
                label?.isHidden = true
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
        cell.numberOfDrawsLabel.text = "\(tournamentStatistics.statistics?.numberOfDraws ?? 0)"
        cell.numberOfLesionsLabel.text = "\(tournamentStatistics.statistics?.numberOfLesions ?? 0)"
        cell.numberOfGoalsAndMissedLabel.text = "\(tournamentStatistics.statistics?.goalsScored ?? 0) - \(tournamentStatistics.statistics?.goalsConceded ?? 0)"
        cell.scoreLabel.text = "\(tournamentStatistics.score)"
    }
    
    func configureCell(_ cell: ResultsFormTableViewCell, with tournamentStatistics: TournamentStatistics) {
        cell.positionLabel.text = "\(tournamentStatistics.position)"
        
        guard let teamStatistics = tournamentStatistics.teamStatistics,
            let team = teamStatistics.team else { return }
        
        if let imageData = team.logoImageData {
            cell.teamLogoImageView.image = UIImage(data: imageData)
            cell.teamNameLabel.text = team.name
        }
        
        var matches = [Match]()
        guard let teamMatches = team.matches else { return }
        
        var sortedMatches = teamMatches.compactMap { $0 as? Match }
        sortedMatches.sort(by: { (match1, match2) -> Bool in
            match1.date!.compare(match2.date!) == .orderedDescending
        })
        matches = sortedMatches.filter {$0.status == true} 
        
        for (label, view) in [(cell.match1Label, cell.match1View), (cell.match2Label, cell.match2View), (cell.match3Label, cell.match3View), (cell.match4Label, cell.match4View), (cell.match5Label, cell.match5View), (cell.match6Label, cell.match6View)] {
            if !matches.isEmpty {
                let match = matches.removeFirst()
                if match.team1Score > match.team2Score {
                    if match.team1Id == team.id {
                        view?.backgroundColor = .systemGreen
                        label?.text = "В"
                        label?.isHidden = false
                    } else {
                        view?.backgroundColor = .systemRed
                        label?.text = "П"
                        label?.isHidden = false
                    }
                } else if match.team1Score < match.team2Score {
                    if match.team1Id == team.id {
                        view?.backgroundColor = .systemRed
                        label?.text = "П"
                        label?.isHidden = false
                    } else {
                        view?.backgroundColor = .systemGreen
                        label?.text = "В"
                        label?.isHidden = false
                    }
                } else if match.team1Score == match.team2Score {
                    view?.backgroundColor = .systemGray
                    label?.text = "Н"
                    label?.isHidden = false
                }
            } else {
                view?.backgroundColor = .systemGray6
                label?.isHidden = true
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
        
        cell.tournamentInfoLabel.text = tournament.info
        
        if let date1 = tournament.dateOfTheBeginning,
            let date2 = tournament.dateOfTheEnd {
            cell.tournamentDatesLabel.text = "\(dateFormatter.string(from: date1)) - \(dateFormatter.string(from: date2))"
        }
    }
}
