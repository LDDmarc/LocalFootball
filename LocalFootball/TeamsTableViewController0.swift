//
//  TeamsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 09.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class TeamsTableViewController0: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataManger.instance.persistentContainer.viewContext
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var teams = [Team]()
    var matches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teams = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "teams", withExtension: "json")
      //  matches = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "matches", withExtension: "json")
     //   matches = DataProcessing.shared.loadData(from: "matches", withExtension: "json", into: context)
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return teams.count
      //  return matches.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
        let team = teams[indexPath.row]
        cell.textLabel?.text = team.name
        if let imageData = team.emblemaImageData {
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = DetailTeamViewController()
        nextVC.team = teams[indexPath.row]
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
//        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
//            let match = matches[indexPath.row]
//            cell.textLabel?.text = match.team1Name
//
//           // cell.textLabel?.text = dateFormatter.string(from: match.date!)
//
////            if let imageData = (match.teams?[0] as? Team)?.emblemaImageData {
////                cell.imageView?.image = UIImage(data: imageData)
////            }
//            return cell
//        }
}

