//
//  DetailTeamViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class DetailTeamViewController: UIViewController {
    var team: Team!

    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var colorsLabel: UILabel!
    @IBOutlet weak var yearOfFoundationLabel: UILabel!
    
    @IBOutlet weak var statisticsLabel: UILabel!
    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var goalsLabel: UILabel!
    @IBOutlet weak var tournamentsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        fillView()
    }

    private func fillView() {
        teamNameLabel.text = team.name
        if let imageData = team.logoImageData { teamLogoImageView.image = UIImage(data: imageData) }
        
        
        var str = "Цвета: "
        team.teamColors.forEach {
            str += $0
            str += " "
        }
        colorsLabel.text = str
        
        yearOfFoundationLabel.text = "Год основания: \(team.yearOfFoundation)"
        if let statistics = team.teamStatistics,
            let fullstatistics = statistics.fullStatistics {
            gamesLabel.text = "Игр: \(fullstatistics.numberOfGames)"
            winsLabel.text = "Побед: \(fullstatistics.numberOfWins)"
            goalsLabel.text = "Голов: \(fullstatistics.goalsScored)"
            if let tournamentsCount = statistics.tournamentStatistics?.count {
                tournamentsLabel.text = "Турниров: \(tournamentsCount)"
            }
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
