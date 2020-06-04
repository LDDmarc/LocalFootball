//
//  ResultsTableTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsTableTableViewCell: UITableViewCell {

    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var teamLogoImageView: UIImageView!
    @IBOutlet private weak var teamNameLabel: UILabel!
    @IBOutlet private weak var numberOfGamesLabel: UILabel!
    @IBOutlet private weak var numberOfWinsLabel: UILabel!
    @IBOutlet private weak var numberOfDrawsLabel: UILabel!
    @IBOutlet private weak var numberOfLesionsLabel: UILabel!
    @IBOutlet private weak var numberOfGoalsAndMissedLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!

    var position: String? {
        didSet {
            guard let position = position else { return }
            positionLabel.text = position
        }
    }
    var teamName: String? {
        didSet {
            guard let teamName = teamName else { return }
            teamNameLabel.text = teamName
        }
    }
    var teamLogoData: Data? {
        didSet {
            guard let imageData = teamLogoData else { return }
            teamLogoImageView.image = UIImage(data: imageData)
        }
    }
    var numberOfGames: String? {
        didSet {
            guard let numberOfGames = numberOfGames else { return }
            numberOfGamesLabel.text = numberOfGames
        }
    }
    var numberOfWins: String? {
        didSet {
            guard let numberOfWins = numberOfWins else { return }
            numberOfWinsLabel.text = numberOfWins
        }
    }
    var numberOfDraws: String? {
        didSet {
            guard let numberOfDraws = numberOfDraws else { return }
            numberOfDrawsLabel.text = numberOfDraws
        }
    }
    var numberOfLesions: String? {
        didSet {
            guard let numberOfLesions = numberOfLesions else { return }
            numberOfLesionsLabel.text = numberOfLesions
        }
    }
    var numberOfGoalsAndMissed: String? {
        didSet {
            guard let numberOfGoalsAndMissed = numberOfGoalsAndMissed else { return }
            numberOfGoalsAndMissedLabel.text = numberOfGoalsAndMissed
        }
    }
    var score: String? {
        didSet {
            guard let score = score else { return }
            scoreLabel.text = score
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

}
