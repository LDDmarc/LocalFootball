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
    
    var context: NSManagedObjectContext!
    var teams = [Team]()
    var matches = [Match]()
    var t: Temp!
    var statistics = [Statistics]()
    var tournamentStatistics = [TournamentStatistics]()
    var teamStatistic = [TeamStatistic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //teams = loadData(from: "teams", withExtension: "json")
        
        teams = getDataFromCoreData(orFrom: "teams", withExtension: "json")
       
        //statistics = getDataFromCoreData(orFrom: "statistics", withExtension: "json")
       //tournamentStatistics =  getDataFromCoreData(orFrom: "tournamentStatistics", withExtension: "json")
        //teamStatistic =  getDataFromCoreData(orFrom: "tournamentStatistics", withExtension: "json")
        //matches = getDataFromCoreData(orFrom: "matches", withExtension: "json")
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return teams.count
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
    
    //    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
    //        let match = matches[indexPath.row]
    //        cell.textLabel?.text = match.team1Name
    //        cell.detailTextLabel?.text = ""
    //
    //        if let imageData = (match.teams?[0] as? Team)?.emblemaImageData {
    //            cell.imageView?.image = UIImage(data: imageData)
    //        }
    //        return cell
    //    }
}




// MARK: - Loading Data
extension TeamsTableViewController {
    
    private func loadData<T: Decodable>(from fileName: String, withExtension: String) -> [T] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: withExtension) else {
            fatalError("File \(fileName).\(withExtension) not found.")
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            
            jsonDecoder.userInfo[CodingUserInfoKey.context!] = context
            do {
                let object = try jsonDecoder.decode([T].self, from: data)
                do {
                    try context.save()
                    return object
                } catch {
                    fatalError("Failed to save")
                }
            } catch  {
                fatalError("Failed to decode")
            }
            
        } catch {
            fatalError("Failed to create data")
        }
    }
    
    private func getDataFromCoreData<T: NSManagedObject & Decodable>(orFrom fileName: String, withExtension: String) -> [T] {
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return [] }
       // fetchRequest.predicate = NSPredicate(format: "name != nil")
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                return loadData(from: fileName, withExtension: withExtension)
            }
            return results
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
    
}
