//
//  DetailTeamTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class DetailTeamTableViewCell: UITableViewCell {

    @IBOutlet private weak var teamLogoImageView: UIImageView!

    @IBOutlet private weak var gamesLabel: UILabel!
    @IBOutlet private weak var winsLabel: UILabel!
    @IBOutlet private weak var goalsLabel: UILabel!
    @IBOutlet private weak var tournamentsLabel: UILabel!

    @IBOutlet private weak var lastMatchesStackView: UIStackView!

    @IBOutlet private weak var match1View: UIView!
    @IBOutlet private weak var match2View: UIView!
    @IBOutlet private weak var match3View: UIView!
    @IBOutlet private weak var match4View: UIView!
    @IBOutlet private weak var match5View: UIView!

    @IBOutlet private weak var match1Label: UILabel!
    @IBOutlet private weak var match2Label: UILabel!
    @IBOutlet private weak var match3Label: UILabel!
    @IBOutlet private weak var match4Label: UILabel!
    @IBOutlet private weak var match5Label: UILabel!

    var teamLogoData: Data? {
        didSet {
            guard let imageData = teamLogoData else { return }
            teamLogoImageView.image = UIImage(data: imageData)
        }
    }

    var games: Int16? {
        didSet {
            guard let games = games else { return }
            gamesLabel.text = "\(games)"
        }
    }
    var wins: Int16? {
        didSet {
            guard let wins = wins else { return }
            winsLabel.text = "\(wins)"
        }
    }
    var goals: Int16? {
        didSet {
            guard let goals = goals else { return }
            goalsLabel.text = "\(goals)"
        }
    }
    var tournaments: Int? {
        didSet {
            guard let tournaments = tournaments else { return }
            tournamentsLabel.text = "\(tournaments)"
        }
    }

    var match1Info: Int? {
        didSet {
            setMatchResult(matchInfo: match1Info, matchView: match1View, matchLabel: match1Label)
        }
    }
    var match2Info: Int? {
        didSet {
           setMatchResult(matchInfo: match2Info, matchView: match2View, matchLabel: match2Label)
        }
    }
    var match3Info: Int? {
        didSet {
           setMatchResult(matchInfo: match3Info, matchView: match3View, matchLabel: match3Label)
        }
    }
    var match4Info: Int? {
        didSet {
           setMatchResult(matchInfo: match4Info, matchView: match4View, matchLabel: match4Label)
        }
    }
    var match5Info: Int? {
        didSet {
            setMatchResult(matchInfo: match5Info, matchView: match5View, matchLabel: match5Label)
        }
    }

    private func setMatchResult(matchInfo: Int?, matchView: UIView, matchLabel: UILabel) {
        guard let matchInfo = matchInfo else {
            matchView.backgroundColor = .systemGray6
            matchLabel.isHidden = true
            return
        }
        matchLabel.isHidden = false
        if matchInfo == -1 {
            matchView.backgroundColor = .systemRed
            matchLabel.text = "П"
        } else {
            matchView.backgroundColor = (matchInfo == 1) ? .systemGreen : .systemGray
            matchLabel.text = (matchInfo == 1) ? "В" : "Н"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        for matchView in [match1View, match2View, match3View, match4View, match5View] {
            matchView?.layer.cornerRadius = 2 * .pi
            matchView?.clipsToBounds = true
            matchView?.backgroundColor = .label
        }
    }

}
