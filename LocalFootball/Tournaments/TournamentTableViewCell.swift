//
//  TournamentTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class TournamentTableViewCell: UITableViewCell {

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var tournamentNameLabel: UILabel!
    @IBOutlet weak var tournamentImageView: UIImageView!
    @IBOutlet private weak var tournamentDatesLabel: UILabel!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet private weak var tournamentInfoLabel: UILabel!
    @IBOutlet private weak var buttonsStackView: UIStackView!

    @IBAction func tournamentTeamsButtonTap(_ sender: UIButton) {
        if delegate != nil,
            let indexPath = indexPath {
            self.delegate?.showTeams(indexPath: indexPath)
        }
    }
    @IBAction func tournamentMatchesButtonTap(_ sender: UIButton) {
        if delegate != nil,
            let indexPath = indexPath {
            self.delegate?.showMatches(indexPath: indexPath)
        }
    }
    @IBAction func tournamentResultsButtonTap(_ sender: UIButton) {
        if delegate != nil,
            let indexPath = indexPath {
            self.delegate?.showResults(indexPath: indexPath)
        }
    }

    @IBOutlet weak var tournamentTeamsButton: UIButton!
    @IBOutlet weak var tournamentMatchesButton: UIButton!
    @IBOutlet weak var tournamentResultsButton: UIButton!

    var tournamentName: String? {
        didSet {
            guard let tournamentName = tournamentName else { return }
            tournamentNameLabel.text = tournamentName
        }
    }
    var dates: String? {
        didSet {
            guard let dates = dates else { return }
            tournamentDatesLabel.text = dates
        }
    }
    var info: String? {
        didSet {
            guard let info = info else { return }
            tournamentInfoLabel.text = info
        }
    }

    let separator = UIView()

    var indexPath: IndexPath?

    weak var delegate: TournamentTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
        separator.backgroundColor = .separator

        bottomView.isHidden = true

        for button in [tournamentTeamsButton, tournamentMatchesButton, tournamentResultsButton] {
            button?.layer.cornerRadius = .pi
            button?.clipsToBounds = true
        }
    }
}

protocol TournamentTableViewCellDelegate: AnyObject {
    func showTeams(indexPath: IndexPath)
    func showMatches(indexPath: IndexPath)
    func showResults(indexPath: IndexPath)
}
