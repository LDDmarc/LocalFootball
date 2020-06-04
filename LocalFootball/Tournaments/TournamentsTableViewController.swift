//
//  TournamentsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class TournamentsTableViewController: TableViewControllerWithFRC {

    override var backgroundImageName: String {
        return "cup"
    }

    // MARK: - FetchedResultsController

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
        frc.delegate = fetchedResultsControllerDelegate
        return frc
    }()
    var expandedIndexSet: IndexSet = []

    override func loadView() {
        super.loadView()
        tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: TournamentTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: TournamentTableViewCell.self))
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TournamentTableViewCell.self)) as? TournamentTableViewCell
            else { return UITableViewCell() }

        let tournament = fetchedResultsController.object(at: indexPath)

        TournamentTableViewCellConfigurator().configureCell(cell, with: tournament)

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
        let teamsTableViewController = TeamsTableViewController(dataProvider: dataProvider)
        teamsTableViewController.title = tournament.name
        teamsTableViewController.teamsByTournamentsPredicate = NSPredicate(format: "id IN %@", tournament.tournamentTeamsIds)

        navigationController?.pushViewController(teamsTableViewController, animated: true)
    }

    func showMatches(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let matchesTableViewController = MatchesTableViewController(dataProvider: dataProvider)
        matchesTableViewController.title = tournament.name
        matchesTableViewController.matchesByTournamentPredicate = NSPredicate(format: "id IN %@", tournament.tournamentMatchesIds)

        navigationController?.pushViewController(matchesTableViewController, animated: true)
    }

    func showResults(indexPath: IndexPath) {
        let tournament = fetchedResultsController.object(at: indexPath)
        let resultsTableViewController = ResultsTableViewController(dataProvider: dataProvider)
        resultsTableViewController.title = tournament.name
        resultsTableViewController.tournamentPredicate = NSPredicate(format: "tournamentId == %i", tournament.id)

        navigationController?.pushViewController(resultsTableViewController, animated: true)
    }
}
