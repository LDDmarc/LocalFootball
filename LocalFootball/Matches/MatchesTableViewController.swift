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
    
    // MARK: - CoreData & FetchedResultsController
    
    let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, repository: NetworkManager.shared)
    
    lazy var fetchedResultsController: NSFetchedResultsController<Match> = {
        let request: NSFetchRequest = Match.fetchRequest()
        if let matchesByTournamentPredicate = matchesByTournamentPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchesByTournamentPredicate, matchesByStatusPredicate])
        } else {
            request.predicate = matchesByStatusPredicate
        }
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let sort2 = NSSortDescriptor(key: "tournamentName", ascending: false)
        request.sortDescriptors = [sort, sort2]
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataProvider.context, sectionNameKeyPath: "tournamentName", cacheName: nil)
        do {
            try frc.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        frc.delegate = self
        return frc
    }()
    
    var matchesByStatusPredicate: NSPredicate = NSPredicate(format: "status == YES") {
        didSet {
            filterContent()
        }
    }
    var matchesByTeamsPredicate: NSPredicate? {
        didSet {
            filterContent()
        }
    }
    var matchesByTournamentPredicate: NSPredicate? {
        didSet {
            filterContent()
        }
    }
    
    // MARK: - UI
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Введите название команды"
        sc.searchResultsUpdater = self
        sc.searchBar.isHidden = false
        definesPresentationContext = true
        return sc
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Прошедшие", "Предстоящие"]
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentedControlTap(sender:)), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    lazy var matchesRefreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        return rc
    }()
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    
    // MARK: - Loading View
    
    override func loadView() {
        super.loadView()
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        tableView.backgroundView = activityIndicatorView
        tableView.refreshControl = matchesRefreshControl
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.titleView = segmentedControl
        
        tableView.sectionHeaderHeight = CGFloat(40)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
    }

    @objc private func fetchData() {
        if fetchedResultsController.fetchedObjects?.isEmpty ?? true {
            self.activityIndicatorView.startAnimating()
        }
        dataProvider.fetchAllData { (error) in
            guard error == nil else { return }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else { return nil }
        return sections[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as! MatchTableViewCell
        
        let match = fetchedResultsController.object(at: indexPath)
        CellsConfiguration.shared.configureCell(cell, with: match)
        
        return cell
    }
    
}

// MARK: - NSFetchedResultsController
extension MatchesTableViewController: NSFetchedResultsControllerDelegate {
    
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
}

// MARK: - UISearchResultsUpdating
extension MatchesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            matchesByTeamsPredicate = NSPredicate(format: "ANY teams.name CONTAINS[cd] %@",  searchText)
        } else {
            matchesByTeamsPredicate = nil
        }
    }
    
    @objc func segmentedControlTap(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            matchesByStatusPredicate = NSPredicate(format: "status == YES")
        case 1:
            matchesByStatusPredicate = NSPredicate(format: "status == NO")
        default:
            matchesByStatusPredicate = NSPredicate(format: "status == YES")
        }
    }
    
    private func filterContent() {
        var predicates = [NSPredicate]()
        
        predicates.append(matchesByStatusPredicate)
        
        if let matchesByTeamsPredicate = matchesByTeamsPredicate {
            predicates.append(matchesByTeamsPredicate)
        }
        if let matchesByTournamentPredicate = matchesByTournamentPredicate {
            predicates.append(matchesByTournamentPredicate)
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
}

// TODO:

extension MatchesTableViewController: MatchTableViewCellDelegate {
    func favoriteStarTap(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "fillStar"), for: .normal)
    }
}
