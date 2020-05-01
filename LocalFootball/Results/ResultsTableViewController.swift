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
    var tournamentPredicate: NSPredicate = NSPredicate(format: "tournamentId == %i", Int64(1101))

    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Таблица", "Форма"]
        let sc = UISegmentedControl(items: items)
     //   sc.addTarget(self, action: #selector(segmentedControlTap(sender:)), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = segmentedControl
        
        let chooseTournamentButton = UIButton(type: .custom)
        chooseTournamentButton.setImage(UIImage(named: "tournaments"), for: .normal)
        chooseTournamentButton.addTarget(self, action: #selector(chooseTournament), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: chooseTournamentButton)
        
        tableView.register(UINib(nibName: "ResultsTableSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ResultsTableSectionHeader.reuseIdentifier)
        tableView.register(UINib(nibName: String(describing: ResultsTableTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ResultsTableTableViewCell.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @objc func chooseTournament() {
        let ac = UIAlertController(title: "Выберете турнир", message: nil, preferredStyle: .actionSheet)
        
     //   ac.addpic
     //   ac.addAction(UIAction(title: "Отмена", handler: .canc))
        present(ac, animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ResultsTableSectionHeader") as! ResultsTableSectionHeader
        // ???
        headerView.layer.backgroundColor = UIColor(red: 232/255, green: 233/255, blue: 237/255, alpha: 1).cgColor
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultsTableTableViewCell.self)) as! ResultsTableTableViewCell
        let result = fetchedResultsController.object(at: indexPath)
        CellsConfiguration.shared.configureCell(cell, with: result)

        return cell
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


class ResultsTableSectionHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier = "ResultsTableSectionHeader"
}
