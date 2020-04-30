//
//  MarchesTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var team1LogoImageView: UIImageView!
    @IBOutlet weak var team2LogoImageView: UIImageView!
    
    @IBOutlet weak var teamsNamesLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}
