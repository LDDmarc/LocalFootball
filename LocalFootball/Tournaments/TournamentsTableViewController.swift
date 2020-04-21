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
    
     let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, repository: NetworkManager.shared)
    
    lazy var fetchedResultsController: NSFetchedResultsController<Tournament> = {
        let request: NSFetchRequest = Tournament.fetchRequest()
        request.predicate = tournamentsPredicate
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 6
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataProvider.context, sectionNameKeyPath: nil, cacheName: nil)
       do {
           try frc.performFetch()
       } catch {
           let nserror = error as NSError
           fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
       }
        frc.delegate = self
        return frc
    }()
    var tournamentsPredicate: NSPredicate?
    
    var expandedIndexSet : IndexSet = []
    
    override func loadView() {
        super.loadView()
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: TournamentTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TournamentTableViewCell.self))
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
        
        CellsConfiguration.shared.configureCell(cell, with: tournament)
    
        cell.indexPath = indexPath
        cell.delegate = self
        
        cell.bottomView.isHidden = !expandedIndexSet.contains(indexPath.row)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.row) {
            expandedIndexSet.remove(indexPath.row)
        } else {
            expandedIndexSet.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

extension TournamentsTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}

extension TournamentsTableViewController: TournamentTableViewCellDelegate {
    func showTeams(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let nextVC = TeamsTableViewController()
        
        if let name = tournament.name {
            nextVC.teamsPredicate = NSPredicate(format: "ANY tournaments.name == %@", name)
            nextVC.teamsByTournamentsPredicate = NSPredicate(format: "ANY tournaments.name == %@", name)
        }
        nextVC.isScopeBarShown = false
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
    func showMatches(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let nextVC = MatchesTableViewController()
        
        if let name = tournament.name {
            //nextVC.matchesPredicate = NSPredicate(format: "tournamentName == %@", name)
        }
        
           navigationController?.pushViewController(nextVC, animated: true)
    }

}

extension TournamentsTableViewController: ExpandableCellDelegate {
    func expandableCellLayoutChanged(_ expandableCell: TournamentTableViewCell) {
        refreshTableAfterCellExpansion()
    }
    
    func refreshTableAfterCellExpansion() {
        self.tableView.beginUpdates()
        self.tableView.setNeedsDisplay()
        self.tableView.endUpdates()
    }
}
