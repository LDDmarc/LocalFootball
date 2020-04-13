//
//  MatchesTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class MatchesTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataManger.instance.persistentContainer.viewContext
    
    var matches = [Match]()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
        
        //matches = DataProcessing.shared.loadData(from: "matches", withExtension: "json", into: context)
        
        matches = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "matches", withExtension: "json")
        
        print(matches.count)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matches.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as! MatchTableViewCell
        
        let match = matches[indexPath.row]
        if let tournamentName = match.tournament?.name {
            cell.tournamentNameLabel.text = tournamentName
        }
        if let date = match.date {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        
        if let team1 = match.teams?[0] as? Team {
            cell.team1NameLabel.text = team1.name
            if let emblema1Data = team1.emblemaImageData {
                cell.team1EmblemaImageView.image = UIImage(data: emblema1Data)
            }
        }
        if let team2 = match.teams?[1] as? Team {
            cell.team2NameLabel.text = team2.name
            if let emblema2Data = team2.emblemaImageData {
                cell.team2EmblemaImageView.image = UIImage(data: emblema2Data)
            }
        }
        
        return cell
    }

}
