//
//  ResultsFormTableViewCell.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 01.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsFormTableViewCell: UITableViewCell {
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var lastMatchesStackView: UIStackView!
    
    @IBOutlet weak var match1View: UIView!
    @IBOutlet weak var match2View: UIView!
    @IBOutlet weak var match3View: UIView!
    @IBOutlet weak var match4View: UIView!
    @IBOutlet weak var match5View: UIView!
    @IBOutlet weak var match6View: UIView!
    
    @IBOutlet weak var match1Label: UILabel!
    @IBOutlet weak var match2Label: UILabel!
    @IBOutlet weak var match3Label: UILabel!
    @IBOutlet weak var match4Label: UILabel!
    @IBOutlet weak var match5Label: UILabel!
    @IBOutlet weak var match6Label: UILabel!

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
