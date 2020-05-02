//
//  ResultsTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker_3_0

class ResultsTableViewController: UITableViewController {
    
    let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, repository: NetworkManager.shared)
    
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
    var tournamentPredicate: NSPredicate?
    
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
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    @objc private func refresh() {
        fetchData()
    }
    var activityIndicatorView: UIActivityIndicatorView!
    
    private func fetchData() {
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
    
    override func loadView() {
        super.loadView()
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        tableView.backgroundView = activityIndicatorView
        tableView.refreshControl = resultsRefreshControl
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = segmentedControl
        
        let chooseTournamentButton = UIButton(type: .custom)
        chooseTournamentButton.setImage(UIImage(named: "tournaments"), for: .normal)
        chooseTournamentButton.addTarget(self, action: #selector(chooseTournament), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: chooseTournamentButton)
        
        tableView.register(UINib(nibName: "ResultsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsTableSectionHeader.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: ResultsTableTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ResultsTableTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ResultsFormTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ResultsFormTableViewCell.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
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
                do {
                    try self.fetchedResultsController.performFetch()
                    self.currentTournamentName = tournament.name
                    self.tableView.reloadData()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }))
        }
        present(ac, animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ResultsTableSectionHeader") as! ResultsTableSectionHeader
        headerView.tournamentNameLabel.text = currentTournamentName
        headerView.contentView.backgroundColor = UIColor.systemGray5
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsTableTableViewCell.self)) as! ResultsTableTableViewCell
            let result = fetchedResultsController.object(at: indexPath)
            CellsConfiguration.shared.configureCell(cell, with: result)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsFormTableViewCell.self)) as! ResultsFormTableViewCell
            let result = fetchedResultsController.object(at: indexPath)
            CellsConfiguration.shared.configureCell(cell, with: result)
            
            return cell
        }
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

class CustomAlertController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let table = UITableView()
        
        self.setValue(table, forKey: "contentViewController")
    }
}
