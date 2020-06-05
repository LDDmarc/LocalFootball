//
//  TournamentTableViewCellConfigurator.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import SDWebImage

class TournamentTableViewCellConfigurator {
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_Ru")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    func configureCell(_ cell: TournamentTableViewCell, with tournament: Tournament) {
        cell.tournamentName = tournament.name

        if let imageURL = tournament.imageName {
            cell.tournamentImageView.sd_setImage(with: URL(string: imageURL),
                                                 placeholderImage: UIImage(named: "IFLimage"),
                                                 options: .highPriority,
                                                 progress: nil,
                                                 completed: nil)
        }
        cell.info = tournament.info

        if let date1 = tournament.dateOfTheBeginning,
            let date2 = tournament.dateOfTheEnd {
            cell.dates = "\(dateFormatter.string(from: date1)) - \(dateFormatter.string(from: date2))"
        }
    }
}
