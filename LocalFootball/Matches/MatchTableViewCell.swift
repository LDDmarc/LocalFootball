//
//  MarchesTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var tournamentNameLabel: UILabel!
    @IBOutlet private weak var team1LogoImageView: UIImageView!
    @IBOutlet private weak var team2LogoImageView: UIImageView!
    @IBOutlet private weak var teamsNamesLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!

    @IBOutlet weak var calendarButton: UIButton!
    @IBAction func calendarButtonTap(_ sender: UIButton) {
        if delegate != nil,
            let indexPath = indexPath {
            delegate?.favoriteStarTap(sender, cellForRowAt: indexPath)
        }
    }

    weak var delegate: MatchTableViewCellDelegate?
    var indexPath: IndexPath?

    var date: Date? {
        didSet {
            guard let date = date else { return }
            dateLabel.text = DateFormatter.writtingDateFormatter().string(from: date)
        }
    }
    var tournamentName: String? {
        didSet {
            tournamentNameLabel.text = tournamentName
        }
    }
    var teamsNames: String? {
        didSet {
            teamsNamesLabel.text = teamsNames
        }
    }
    var score: String? {
        didSet {
            scoreLabel.text = score
        }
    }
    var team1ImageData: Data? {
        didSet {
            guard let imageData = team1ImageData else { return }
            team1LogoImageView.image = UIImage(data: imageData)
        }
    }
    var team2ImageData: Data? {
        didSet {
            guard let imageData = team2ImageData else { return }
            team2LogoImageView.image = UIImage(data: imageData)
        }
    }
    var status: Bool = true {
        didSet {
            calendarButton.isHidden = status
        }
    }
    var isEventInCalendar: Bool = false {
        didSet {
            calendarButton.tintColor = isEventInCalendar ? .red : .gray
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}

protocol MatchTableViewCellDelegate: class {
    func favoriteStarTap(_ sender: UIButton, cellForRowAt indexPath: IndexPath)
}
