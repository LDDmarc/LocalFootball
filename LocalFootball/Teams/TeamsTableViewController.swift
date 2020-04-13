//
//  TeamsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 09.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class TeamsTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataManger.instance.persistentContainer.viewContext
    var teams = [Team]()
    var matches = [Match]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TeamTableViewCell.self))
    
        teams = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "teams", withExtension: "json")
        matches = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "matches", withExtension: "json")
        
        var results = [Team]()
        matches.forEach { match in
            if let team1Name = match.team1Name,
                let team2Name = match.team2Name {
                let fr: NSFetchRequest = Team.fetchRequest()
                fr.predicate = NSPredicate(format: "(name == %@) || (name == %@)", team1Name, team2Name)
                do {
                    results = try context.fetch(fr)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            //match.addToTeams(results)
            results.forEach{ match.addToTeams($0) }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamTableViewCell.self)) as! TeamTableViewCell
        let team = teams[indexPath.row]
        cell.teamNameLabel.text = team.name
        if let imageData = team.emblemaImageData {
            cell.teamEmblemaImageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = DetailTeamViewController()
        nextVC.team = teams[indexPath.row]
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
}

