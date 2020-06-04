//
//  ResultsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class ResultsTableViewController: TableViewControllerWithFRC {

    override var backgroundImageName: String {
        return "man"
    }

    // MARK: - FetchedResultsController

    lazy var fetchedResultsController: NSFetchedResultsController<TournamentStatistics> = {
        let request: NSFetchRequest = TournamentStatistics.fetchRequest()
        request.predicate = tournamentPredicate
        let sort = NSSortDescriptor(key: "position", ascending: true)
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
    var tournamentPredicate: NSPredicate? {
        didSet {
            fetchedResultsController.fetchRequest.predicate = tournamentPredicate
            do {
                try fetchedResultsController.performFetch()
                tableView?.reloadData()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    var currentTournamentId: Int64?
    var currentTournamentName: String?

    // MARK: - UISegmentedControl

    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Таблица", "Форма"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(segmentedControlTap(sender:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    @objc func segmentedControlTap(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    override func loadView() {
        super.loadView()

        navigationItem.titleView = segmentedControl
        tableView.separatorStyle = .none

        tableView.estimatedRowHeight = 48.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ResultsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsTableSectionHeader.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: ResultsTableTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ResultsTableTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ResultsFormTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ResultsFormTableViewCell.self))

        tableView.tableFooterView = UIView()

        if tournamentPredicate == nil {
            let tournamentsRequest: NSFetchRequest = Tournament.fetchRequest()
            var tournaments = [Tournament]()
            do {
                tournaments = try dataProvider.context.fetch(tournamentsRequest)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            currentTournamentId = tournaments.first?.id
            currentTournamentName = tournaments.first?.name
            if let curentTournamentId = currentTournamentId {
                tournamentPredicate = NSPredicate(format: "tournamentId == %i", curentTournamentId)
            }

            let chooseTournamentButton = UIButton(type: .custom)
            chooseTournamentButton.setImage(UIImage(named: "tournaments"), for: .normal)
            chooseTournamentButton.addTarget(self, action: #selector(chooseTournament), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: chooseTournamentButton)
        }
    }

    @objc func chooseTournament(sender: UIButton) {
        var tournaments = [Tournament]()
        let tournamentsRequest: NSFetchRequest = Tournament.fetchRequest()
        do {
            tournaments = try dataProvider.context.fetch(tournamentsRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        let alertController = UIAlertController(title: "Выберете турнир", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        for tournament in tournaments {
            alertController.addAction(UIAlertAction(title: tournament.name, style: .default, handler: { _ in
                self.tournamentPredicate = NSPredicate(format: "tournamentId == %i", tournament.id)
                self.fetchedResultsController.fetchRequest.predicate = self.tournamentPredicate
                self.currentTournamentName = tournament.name
            }))
        }
        present(alertController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ResultsTableSectionHeader") as? ResultsTableSectionHeader
            else { return UIView() }
        headerView.tournamentNameLabel.text = currentTournamentName
        headerView.contentView.backgroundColor = .systemGray6

        if segmentedControl.selectedSegmentIndex == 0 {
            for label in [headerView.gamesLabel,
                          headerView.winsLabel,
                          headerView.drawsLabel,
                          headerView.lesionsNameLabel,
                          headerView.goalsNameLabel,
                          headerView.scoreNameLabel] {
                label?.isHidden = false
            }
            headerView.lastMatchesLabel.isHidden = true
        } else {
            for label in [headerView.gamesLabel,
                          headerView.winsLabel,
                          headerView.drawsLabel,
                          headerView.lesionsNameLabel,
                          headerView.goalsNameLabel,
                          headerView.scoreNameLabel] {
                label?.isHidden = true
            }
            headerView.lastMatchesLabel.isHidden = false
        }
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsTableTableViewCell.self)) as? ResultsTableTableViewCell
                else { return UITableViewCell() }
            let result = fetchedResultsController.object(at: indexPath)
            ResultsTableTableViewCellConfigurator().configureCell(cell, with: result)

            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .systemBackground
            } else {
                cell.backgroundColor = .secondarySystemBackground
            }

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsFormTableViewCell.self)) as? ResultsFormTableViewCell
                else { return UITableViewCell() }
            let result = fetchedResultsController.object(at: indexPath)
            ResultsFormTableViewCellConfigurator().configureCell(cell, with: result, indexPath.row % 2 == 0)

            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .systemBackground
            } else {
                cell.backgroundColor = .secondarySystemBackground
            }

            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segmentedControl.selectedSegmentIndex = segmentedControl.selectedSegmentIndex == 0 ? 1 : 0
        tableView.reloadData()
    }
}
