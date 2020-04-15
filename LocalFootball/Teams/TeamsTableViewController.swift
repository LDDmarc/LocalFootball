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
    lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
        let request: NSFetchRequest = Team.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    var teamsPredicate: NSPredicate?
    
    var teams = [Team]()
    var matches = [Match]()
    var tournaments = [Tournament]()
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Введите название команды"
        sc.searchResultsUpdater = self
        sc.searchBar.isHidden = false
        //  the search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
        sc.searchBar.scopeButtonTitles = []
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        navigationItem.searchController = searchController
      
        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TeamTableViewCell.self))
        
        loadData()
        
        // <4 - ?
        tournaments.forEach { tournament in
            if let name = tournament.name {
                searchController.searchBar.scopeButtonTitles?.append(name)}
            }
    }
    
    @objc private func filter() {
        
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
        let nextVC = DetailTeamViewController()
        nextVC.team = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(nextVC, animated: true)
    }
 
}

extension TeamsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        if !isSearchBarEmpty {
            teamsPredicate = NSPredicate(format: "name CONTAINS[cd] %@",  text)
        } else {
            teamsPredicate = nil
        }
        upDateDataByNewFetchRequest()
    }
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        
//        let name = searchBar.scopeButtonTitles?[selectedScope]
//        teamsPredicate = NSPredicate(format: "tournamentsNames CONTAINS %@", name!)
//        upDateDataByNewFetchRequest()
//    }
}

// MARK: - Data Processing

extension TeamsTableViewController: NSFetchedResultsControllerDelegate {
    private func loadData() {
        teams = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "teams", withExtension: "json")
        matches = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "matches", withExtension: "json")
        tournaments = DataProcessing.shared.getDataFromCoreData(with: context, orFrom: "tournaments", withExtension: "json")
        
        // todo
        let userDefaults = UserDefaults.standard
        let firstLaunch = FirstLaunch(userDefaults: userDefaults)
        if firstLaunch.isFirstLaunch {
           DataProcessing.shared.bindingData(matches: matches, teams: teams, tournaments: tournaments)
        }
        
        upDateDataByNewFetchRequest()
    }
    
    private func upDateDataByNewFetchRequest() {
        fetchedResultsController.fetchRequest.predicate = teamsPredicate
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    //private func
}
