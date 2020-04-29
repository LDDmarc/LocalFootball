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
    
    let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, repository: NetworkManager.shared)
    
    lazy var fetchedResultsController: NSFetchedResultsController<Match> = {
        let request: NSFetchRequest = Match.fetchRequest()
        if let matchesByTournamentPredicate = matchesByTournamentPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchesByTournamentPredicate, matchesByStatusPredicate])
        } else {
            request.predicate = matchesByStatusPredicate
        }
        let sort = NSSortDescriptor(key: "date", ascending: false)
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
    var matchesByTeamsPredicate: NSPredicate?
    var matchesByTournamentPredicate: NSPredicate?
    var matchesByStatusPredicate: NSPredicate = NSPredicate(format: "status != NO")
    
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Введите название команды"
        sc.searchResultsUpdater = self
        sc.searchBar.isHidden = false
        //  the search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
        sc.searchBar.scopeButtonTitles = ["Прошедшие", "Предстоящие"]
        // TODO: change to true when we get status for match
        sc.searchBar.showsScopeBar = true
        sc.searchBar.delegate = self
        return sc
    }()
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    var selectedButton = 0
    var isScopeBarShown = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as! MatchTableViewCell
        
        let match = fetchedResultsController.object(at: indexPath)
        CellsConfiguration.shared.configureCell(cell, with: match)
        
        return cell
    }
    
}

// MARK: - NSFetchedResultsController
extension MatchesTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating
extension MatchesTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            matchesByTeamsPredicate = NSPredicate(format: "ANY teams.name CONTAINS[cd] %@",  searchText)
        } else {
            matchesByTeamsPredicate = nil
        }
        filterContent()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            matchesByStatusPredicate = NSPredicate(format: "status == YES")
        } else {
            matchesByStatusPredicate = NSPredicate(format: "status == NO")
        }
        filterContent()
    }
    
    private func filterContent() {
        var predicate: NSPredicate?
        var predicates = [NSPredicate]()
        
        predicates.append(matchesByStatusPredicate)
        
        if let matchesByTeamsPredicate = matchesByTeamsPredicate {
            predicates.append(matchesByTeamsPredicate)
        }
        if let matchesByTournamentPredicate = matchesByTournamentPredicate {
            predicates.append(matchesByTournamentPredicate)
        }
        
        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        updateData(with: predicate)
    }
    
    private func updateData(with predicate: NSPredicate?) {
        if let predicate = predicate {
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
}
