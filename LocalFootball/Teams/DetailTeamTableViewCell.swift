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
    
    @IBOutlet weak var match1View: UIView!
    @IBOutlet weak var match2View: UIView!
    @IBOutlet weak var match3View: UIView!
    @IBOutlet weak var match4View: UIView!
    @IBOutlet weak var match5View: UIView!
    
    @IBOutlet weak var match1Label: UILabel!
    @IBOutlet weak var match2Label: UILabel!
    @IBOutlet weak var match3Label: UILabel!
    @IBOutlet weak var match4Label: UILabel!
    @IBOutlet weak var match5Label: UILabel!
    
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
