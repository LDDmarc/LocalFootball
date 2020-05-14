//
//  ResultsTableTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsTableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var numberOfGamesLabel: UILabel!
    @IBOutlet weak var numberOfWinsLabel: UILabel!
    @IBOutlet weak var numberOfDrawsLabel: UILabel!
    @IBOutlet weak var numberOfLesionsLabel: UILabel!
    @IBOutlet weak var numberOfGoalsAndMissedLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    
}
