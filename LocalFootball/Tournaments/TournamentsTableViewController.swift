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
    
    // MARK: - CoreData & FetchedResultsController
    
    var dataProvider: DataProvider!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Tournament> = {
        let request: NSFetchRequest = Tournament.fetchRequest()
        let sort = NSSortDescriptor(key: "dateOfTheEnd", ascending: false)
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
    
    // MARK: - UI
    
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    lazy var tournamentsRefreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return rc
    }()
    
    var expandedIndexSet : IndexSet = []
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundView = activityIndicatorView
        tableView.refreshControl = tournamentsRefreshControl
       
        tableView.separatorStyle = .none
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: TournamentTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TournamentTableViewCell.self))
    }
    
    @objc private func loadData() {
        if fetchedResultsController.fetchedObjects?.isEmpty ?? true {
            self.activityIndicatorView.startAnimating()
            self.tableView.separatorStyle = .none
        }
        dataProvider.fetchAllData { error in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.tableView.separatorStyle = .singleLine
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedIndexSet.contains(indexPath.row) {
            return 0.52 * view.bounds.width + 81.5
        } else {
            return 0.52 * view.bounds.width
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.row) {
            expandedIndexSet.remove(indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            expandedIndexSet.insert(indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - TournamentTableViewCellDelegate

extension TournamentsTableViewController: TournamentTableViewCellDelegate {
    
    func showTeams(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let teamsTableViewController = TeamsTableViewController()
        teamsTableViewController.title = tournament.name
        teamsTableViewController.teamsByTournamentsPredicate = NSPredicate(format: "id IN %@", tournament.tournamentTeamsIds)
      
        navigationController?.pushViewController(teamsTableViewController, animated: true)
    }
    
    func showMatches(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let matchesTableViewController = MatchesTableViewController()
        matchesTableViewController.title = tournament.name
        matchesTableViewController.matchesByTournamentPredicate = NSPredicate(format: "id IN %@", tournament.tournamentMatchesIds)
        
        navigationController?.pushViewController(matchesTableViewController, animated: true)
    }
    
    func showResults(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let resultsTableViewController = ResultsTableViewController()
        resultsTableViewController.title = tournament.name
        resultsTableViewController.tournamentPredicate = NSPredicate(format: "tournamentId == %i", tournament.id)
       
        navigationController?.pushViewController(resultsTableViewController, animated: true)
    }
}

// MARK: - NSFetchedResultsController

extension TournamentsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            tableView.reloadData()
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            tableView.reloadData()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
}
