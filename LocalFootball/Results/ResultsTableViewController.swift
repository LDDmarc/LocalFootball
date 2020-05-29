//
//  ResultsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class ResultsTableViewController: UITableViewController {
    
    // MARK: - CoreData & FetchedResultsController
    
    var dataProvider: DataProvider!
 
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
        frc.delegate = self
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
    
    var curentTournamentId: Int64?
    var currentTournamentName: String?
    
    lazy var fetchedTournamentsResultsController: NSFetchedResultsController<Tournament> = {
        let request: NSFetchRequest = Tournament.fetchRequest()
        let sort = NSSortDescriptor(key: "dateOfTheEnd", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 8
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
    
    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Таблица", "Форма"]
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentedControlTap(sender:)), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    @objc func segmentedControlTap(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    lazy var resultsRefreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(loadData), for: .valueChanged)
        return rc
    }()

    let activityIndicatorView = UIActivityIndicatorView(style: .large)

    override func loadView() {
        super.loadView()
    
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = segmentedControl
        
        tableView.backgroundView = activityIndicatorView
        tableView.refreshControl = resultsRefreshControl
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 48.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ResultsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsTableSectionHeader.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: ResultsTableTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ResultsTableTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ResultsFormTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ResultsFormTableViewCell.self))
        
        tableView.tableFooterView = UIView()
        
        if tournamentPredicate == nil {
            do {
                try fetchedTournamentsResultsController.performFetch()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            curentTournamentId = fetchedTournamentsResultsController.fetchedObjects?.first?.id
            currentTournamentName = fetchedTournamentsResultsController.fetchedObjects?.first?.name
            if let curentTournamentId = curentTournamentId {
                tournamentPredicate = NSPredicate(format: "tournamentId == %i", curentTournamentId)
            }
            
            let chooseTournamentButton = UIButton(type: .custom)
            chooseTournamentButton.setImage(UIImage(named: "tournaments"), for: .normal)
            chooseTournamentButton.addTarget(self, action: #selector(chooseTournament), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: chooseTournamentButton)
        }
    }
    
    @objc private func loadData() {
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
    
    @objc func chooseTournament(sender: UIButton) {
        var tournaments = [Tournament]()
        do {
            try fetchedTournamentsResultsController.performFetch()
            if let fetchedTournaments = fetchedTournamentsResultsController.fetchedObjects {
                tournaments = fetchedTournaments
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        let ac = UIAlertController(title: "Выберете турнир", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        for tournament in tournaments {
            ac.addAction(UIAlertAction(title: tournament.name, style: .default, handler: { _ in
                self.tournamentPredicate = NSPredicate(format: "tournamentId == %i", tournament.id)
                self.fetchedResultsController.fetchRequest.predicate = self.tournamentPredicate
                self.currentTournamentName = tournament.name
            }))
        }
        present(ac, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ResultsTableSectionHeader") as! ResultsTableSectionHeader
        headerView.tournamentNameLabel.text = currentTournamentName
        headerView.contentView.backgroundColor = .systemGray6
        
        if segmentedControl.selectedSegmentIndex == 0 {
            for label in [headerView.gamesLabel, headerView.winsLabel, headerView.drawsLabel, headerView.lesionsNameLabel, headerView.goalsNameLabel,  headerView.scoreNameLabel] {
                label?.isHidden = false
            }
            headerView.lastMatchesLabel.isHidden = true
        } else {
            for label in [headerView.gamesLabel, headerView.winsLabel, headerView.drawsLabel, headerView.lesionsNameLabel, headerView.goalsNameLabel,  headerView.scoreNameLabel] {
                label?.isHidden = true
            }
            headerView.lastMatchesLabel.isHidden = false
        }
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsTableTableViewCell.self)) as! ResultsTableTableViewCell
            let result = fetchedResultsController.object(at: indexPath)
            CellsConfiguration.shared.configureCell(cell, with: result)
            
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .systemBackground
            } else {
                cell.backgroundColor = .secondarySystemBackground
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsFormTableViewCell.self)) as! ResultsFormTableViewCell
            let result = fetchedResultsController.object(at: indexPath)
            CellsConfiguration.shared.configureCell(cell, with: result, indexPath.row % 2 == 0)
            
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
// MARK: - NSFetchedResultsController

extension ResultsTableViewController: NSFetchedResultsControllerDelegate {
    
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

// MARK: - UITableViewHeaderFooterView

class ResultsTableSectionHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier = "ResultsTableSectionHeader"
    
    @IBOutlet weak var tournamentNameLabel: UILabel!
    
    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var drawsLabel: UILabel!
    @IBOutlet weak var lesionsNameLabel: UILabel!
    @IBOutlet weak var goalsNameLabel: UILabel!
    @IBOutlet weak var scoreNameLabel: UILabel!
    
    @IBOutlet weak var lastMatchesLabel: UILabel!
}

