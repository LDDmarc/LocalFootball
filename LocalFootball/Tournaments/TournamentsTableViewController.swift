//
//  TournamentsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class TournamentsTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataManger.instance.persistentContainer.viewContext
    lazy var fetchedResultsController: NSFetchedResultsController<Tournament> = {
        let request: NSFetchRequest = Tournament.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 3
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    var tournamentsPredicate: NSPredicate?
    
    var tournaments = [Tournament]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: TournamentTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TournamentTableViewCell.self))

        loadData()
    }
    
    private func loadData() {
        fetchedResultsController.fetchRequest.predicate = tournamentsPredicate

        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TournamentTableViewCell.self)) as! TournamentTableViewCell
        
        let tournament = fetchedResultsController.object(at: indexPath)
        
        cell.tournamentNameLabel.text = tournament.name
        if let imageData = tournament.imageData {
            cell.tournamentImageView?.image = UIImage(data: imageData)
        }
        cell.tournamentTeamsLabel.text = "Команд: \(tournament.numberOfTournamentTeams)"
        cell.tournamentInfoLabel.text = tournament.info
        if tournament.status {
            cell.tournmentStatusLabel.text = "В процессе"
        } else {
            cell.tournmentStatusLabel.text = "Завершен"
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        return cell
    }
}

extension TournamentsTableViewController: NSFetchedResultsControllerDelegate {
    
}

extension TournamentsTableViewController: TournamentTableViewCellDelegate {
    func show(indexPath: IndexPath) {
        
        let tournament = fetchedResultsController.object(at: indexPath)
        let nextVC = TeamsTableViewController()
        nextVC.teamsPredicate = NSPredicate(format: "name IN %@", tournament.tournamentTeamsNames)

        navigationController?.pushViewController(nextVC, animated: true)
        
    }

}
