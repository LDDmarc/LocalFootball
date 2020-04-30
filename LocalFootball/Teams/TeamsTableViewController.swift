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
    
    let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, repository: NetworkManager.shared)
  
    lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
        let request: NSFetchRequest = Team.fetchRequest()
        request.predicate = teamsByTournamentsPredicate
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
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
    var teamsPredicate: NSPredicate?
    var teamsByTournamentsPredicate: NSPredicate? 
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Введите название команды"
        sc.searchResultsUpdater = self
        //  the search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
        return sc
    }()
    
    lazy var teamsRefreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    @objc private func refresh() {
        fetchTeams()
        
//        let files = ["teams2", "teams3", "teams4"]
//        if counter < 3 {
//            dataProvider.fetchData(entity: .team) { (error) in
//                guard error == nil else { return }
//                DispatchQueue.main.async {
//                    self.tableView.refreshControl?.endRefreshing()
//                }
//                self.counter += 1
//            }
//        } else {
//            DispatchQueue.main.async {
//                self.tableView.refreshControl?.endRefreshing()
//            }
//        }
    }
    var counter = 0
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        tableView.backgroundView = activityIndicatorView
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Copperplate", size: 30)!]
        
        tableView.refreshControl = teamsRefreshControl
        
        tableView.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        
        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TeamTableViewCell.self))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        fetchTeams()
    }
    
    private func fetchTeams() {
        if fetchedResultsController.fetchedObjects?.isEmpty ?? true {
            self.activityIndicatorView.startAnimating()
            self.tableView.separatorStyle = .none
        }
        dataProvider.fetchAllData { (error) in
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
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamTableViewCell.self)) as! TeamTableViewCell
        let team = fetchedResultsController.object(at: indexPath)
        
        cell.teamNameLabel.text = team.name
        if let imageData = team.logoImageData {
            cell.teamLogoImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = DetailTeamTableViewController()
        nextVC.team = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

    // MARK: - UISearchResultsUpdating
extension TeamsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            teamsPredicate = NSPredicate(format: "name CONTAINS[cd] %@",  searchText)
        } else {
            teamsPredicate = nil
        }
        filterContent()
    }
    
    private func filterContent() {
        var predicates = [NSPredicate]()
        
        if let teamsByTournamentsPredicate = teamsByTournamentsPredicate {
            predicates.append(teamsByTournamentsPredicate)
        }
        if let teamsPredicate = teamsPredicate {
            predicates.append(teamsPredicate)
        }
        
        updateData(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    private func updateData(with predicate: NSPredicate) {
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
}

// MARK: - NSFetchedResultsController

extension TeamsTableViewController: NSFetchedResultsControllerDelegate {
    
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
