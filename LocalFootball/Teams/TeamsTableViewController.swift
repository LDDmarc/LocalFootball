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
        sc.searchBar.isHidden = false
        //  the search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
        return sc
    }()
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isScopeBarShown = true
    
    let teamsRefreshControl: UIRefreshControl = {
       let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    // TODO: не работает((
    @objc private func refresh() {
//        dataProvider.fetchData(entityName: "Team", [Team].self, urlString: "teams") { _ in  }
//        dataProvider.fetchData(entityName: "Match", [Match].self, urlString: "matches") { _ in }
//        dataProvider.fetchData(entityName: "Tournament", [Tournament].self, urlString: "tournaments") { _ in }
//        try? fetchedResultsController.performFetch()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    var titleText: String = "Команды"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Copperplate", size: 30)!]
        title = titleText
        
        tableView.refreshControl = teamsRefreshControl
        
        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TeamTableViewCell.self))
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
        guard let text = searchController.searchBar.text else { return }
        if !isSearchBarEmpty {
            teamsPredicate = NSPredicate(format: "name CONTAINS[cd] %@",  text)
        } else {
            teamsPredicate = nil
        }
        filterContentForSearchText()
    }
    
    private func filterContentForSearchText() {
        
        var predicate: NSPredicate?
        var predicates = [NSPredicate]()
        
        if isSearchBarEmpty {
            if let pr = teamsByTournamentsPredicate {
                predicates.append(pr)
            }
        } else {
            if let pr1 = teamsByTournamentsPredicate {
                predicates.append(pr1)
            }
            if let pr2 = teamsPredicate {
                predicates.append(pr2)
            }
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

// MARK: - NSFetchedResultsController

extension TeamsTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
  
    
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .automatic)
//        case .update:
//            //???
//            let cell = tableView.cellForRow(at: indexPath! as IndexPath)
//        default:
//            break
//        }
//    }
}
