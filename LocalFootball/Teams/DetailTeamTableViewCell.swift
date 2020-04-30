//
//  DetailTeamTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class DetailTeamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var colorsLabel: UILabel!
    @IBOutlet weak var yearOfFoundationLabel: UILabel!
    
    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var goalsLabel: UILabel!
    @IBOutlet weak var tournamentsLabel: UILabel!
    
    @IBOutlet weak var lastMatchesStackView: UIStackView!
    
    @IBOutlet weak var match1Label: UIView!
    @IBOutlet weak var match2Label: UIView!
    @IBOutlet weak var match3Label: UIView!
    @IBOutlet weak var match4Label: UIView!
    @IBOutlet weak var match5Label: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for matchLabel in [match1Label, match2Label, match3Label, match4Label, match5Label] {
            matchLabel?.layer.cornerRadius = 2 * .pi
            matchLabel?.clipsToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
