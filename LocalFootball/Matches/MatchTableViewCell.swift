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
    @IBOutlet weak var tournamentNameLabel: UILabel!
    @IBOutlet weak var team1LogoImageView: UIImageView!
    @IBOutlet weak var team2LogoImageView: UIImageView!
    
    @IBOutlet weak var teamsNamesLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func favoriteStarButton(_ sender: UIButton) {
        if delegate != nil,
            let _ = indexPath {
            self.delegate?.favoriteStarTap(sender)
        }
    }
    var indexPath: IndexPath?
    weak var delegate: MatchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}

protocol MatchTableViewCellDelegate: class {
    func favoriteStarTap(_ sender: UIButton)
}
