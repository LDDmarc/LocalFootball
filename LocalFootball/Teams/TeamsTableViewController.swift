//
//  TeamsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 09.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class TeamsTableViewController: TableViewControllerWithFRC {

    // MARK: - FetchedResultsController

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
        frc.delegate = fetchedResultsControllerDelegate
        return frc
    }()
    var teamsPredicate: NSPredicate? {
        didSet {
            filterContent()
        }
    }
    var teamsByTournamentsPredicate: NSPredicate? {
        didSet {
            filterContent()
        }
    }

    // MARK: - UISearchController

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите название команды"
        definesPresentationContext = true
        return searchController
    }()

    // MARK: - Loading View

    override func loadView() {
        super.loadView()

        navigationItem.searchController = searchController

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 58.0

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TeamTableViewCell.self))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamTableViewCell.self)) as? TeamTableViewCell
            else { return UITableViewCell() }
        let team = fetchedResultsController.object(at: indexPath)

        cell.teamNameLabel.text = team.name
        if let imageData = team.logoImageData {
            cell.teamLogoImageView.image = UIImage(data: imageData)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailTeamTableViewController = DetailTeamTableViewController(dataProvider: dataProvider)
        let team = fetchedResultsController.object(at: indexPath)
        detailTeamTableViewController.teamPredicate = NSPredicate(format: "id == %i", team.id)
        detailTeamTableViewController.matchesPredicate = NSPredicate(format: "(team1Id == %i) OR (team2Id == %i)", team.id, team.id)
        detailTeamTableViewController.title = team.name
        navigationController?.pushViewController(detailTeamTableViewController, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension TeamsTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            teamsPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        } else {
            teamsPredicate = nil
        }
    }

    private func filterContent() {
        var predicates = [NSPredicate]()

        if let teamsByTournamentsPredicate = teamsByTournamentsPredicate {
            predicates.append(teamsByTournamentsPredicate)
        }
        if let teamsPredicate = teamsPredicate {
            predicates.append(teamsPredicate)
        }

        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        do {
            try fetchedResultsController.performFetch()
            tableView?.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
}
