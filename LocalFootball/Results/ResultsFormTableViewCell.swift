//
//  ResultsFormTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 01.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsFormTableViewCell: UITableViewCell {

    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var teamLogoImageView: UIImageView!
    @IBOutlet private weak var teamNameLabel: UILabel!

    @IBOutlet private weak var lastMatchesStackView: UIStackView!

    @IBOutlet private weak var match1View: UIView!
    @IBOutlet private weak var match2View: UIView!
    @IBOutlet private weak var match3View: UIView!
    @IBOutlet private weak var match4View: UIView!
    @IBOutlet private weak var match5View: UIView!
    @IBOutlet private weak var match6View: UIView!

    @IBOutlet private weak var match1Label: UILabel!
    @IBOutlet private weak var match2Label: UILabel!
    @IBOutlet private weak var match3Label: UILabel!
    @IBOutlet private weak var match4Label: UILabel!
    @IBOutlet private weak var match5Label: UILabel!
    @IBOutlet private weak var match6Label: UILabel!

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
    var match6Info: Int? {
        didSet {
            setMatchResult(matchInfo: match6Info, matchView: match6View, matchLabel: match6Label)
        }
    }

    var emptyColor = UIColor.systemGray6

    private func setMatchResult(matchInfo: Int?, matchView: UIView, matchLabel: UILabel) {
        guard let matchInfo = matchInfo else {
            matchView.backgroundColor = emptyColor
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

        for matchView in [match1View, match2View, match3View, match4View, match5View, match6View] {
            matchView?.layer.cornerRadius = 2 * .pi
            matchView?.clipsToBounds = true
            matchView?.backgroundColor = .label
        }
    }

}
