//
//  TournamentTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class TournamentTableViewCell: UITableViewCell {

    @IBOutlet weak var tournamentNameLabel: UILabel!
    @IBOutlet weak var tournamentImageView: UIImageView!
    @IBOutlet weak var tournamentDatesLabel: UILabel!
    @IBOutlet weak var tournamentTeamsLabel: UILabel!
    @IBOutlet weak var tournmentStatusLabel: UILabel!
    @IBOutlet weak var tournamentInfoLabel: UILabel!
    
    var indexPath: IndexPath?
    
    @IBAction func showTeams(_ sender: UIButton) {
        if delegate != nil,
            let indexPath = indexPath {
            self.delegate?.show(indexPath: indexPath)
        }
    }
    
    weak var delegate: TournamentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol TournamentTableViewCellDelegate: AnyObject {
    func show(indexPath: IndexPath)
}
