//
//  ResultsTableSectionHeader.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 30.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class ResultsTableSectionHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier = "ResultsTableSectionHeader"

    @IBOutlet weak var tournamentNameLabel: UILabel!

    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var drawsLabel: UILabel!
    @IBOutlet weak var lesionsNameLabel: UILabel!
    @IBOutlet weak var goalsNameLabel: UILabel!
    @IBOutlet weak var scoreNameLabel: UILabel!

    @IBOutlet weak var lastMatchesLabel: UILabel!
}
