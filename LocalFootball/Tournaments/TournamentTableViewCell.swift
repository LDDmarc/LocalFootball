//
//  TournamentTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class TournamentTableViewCell: UITableViewCell {
    
    struct Const {
        static let standartOffSet: CGFloat = 8
        static let smallOffSet: CGFloat = 4
        static let fontSize: CGFloat = 17
        static let headingFontSize: CGFloat = 20
        static let standartFontSize: CGFloat = 17
        static let imageAspectRatio: CGFloat = 0.66
        static let oneThird: CGFloat = 0.33
    }

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tournamentNameLabel: UILabel!
    @IBOutlet weak var tournamentImageView: UIImageView!
    @IBOutlet weak var tournamentDatesLabel: UILabel!
 
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tournamentInfoLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
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
        
    }
    
    @IBOutlet weak var tournamentTeamsButton: UIButton!
    @IBOutlet weak var tournamentMatchesButton: UIButton!
    @IBOutlet weak var tournamentResultsButton: UIButton!
    
    var indexPath: IndexPath?
    
    weak var delegate: TournamentTableViewCellDelegate?
  
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        bottomView.isHidden = true
        
        for button in [tournamentTeamsButton, tournamentMatchesButton, tournamentResultsButton] {
            button?.layer.cornerRadius = .pi
            button?.clipsToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

protocol TournamentTableViewCellDelegate: AnyObject {
    func showTeams(indexPath: IndexPath)
    func showMatches(indexPath: IndexPath)
}

protocol ExpandableCellDelegate: class {
    func expandableCellLayoutChanged(_ expandableCell: TournamentTableViewCell)
}
