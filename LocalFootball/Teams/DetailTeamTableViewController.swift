//
//  DetailTeamTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class DetailTeamTableViewController: TableViewControllerWithFRC {

    // MARK: - FetchedResultsController

    lazy var fetchedResultsControllerTeam: NSFetchedResultsController<Team> = {
        let request: NSFetchRequest = Team.fetchRequest()
        request.predicate = teamPredicate
        request.fetchBatchSize = 1
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
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
    var teamPredicate: NSPredicate!

    lazy var fetchedResultsControllerMatches: NSFetchedResultsController<Match> = {
        let request: NSFetchRequest = Match.fetchRequest()
        request.predicate = matchesPredicate
        request.fetchBatchSize = 10
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
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
    var matchesPredicate: NSPredicate!

    // MARK: - UI rightBarButtonItemImageView

    var rightBarButtonItemImageView: UIImageView = {
        let view = UIImageView()
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40)
        ])
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    var isViewTitleHidden: Bool = true {
        didSet {
            if !isViewTitleHidden {
                rightBarButtonItemImageView.isHidden = false
            } else {
                rightBarButtonItemImageView.isHidden = true
            }
        }
    }

    // MARK: - Loading View

    override func loadView() {
        super.loadView()

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButtonItemImageView)
        navigationItem.largeTitleDisplayMode = .never

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: DetailTeamTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: DetailTeamTableViewCell.self))

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func reloadTableData() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offSet = tableView.visibleCells.first?.bounds.height ?? 120.0
        if scrollView.contentOffset.y + scrollView.adjustedContentInset.top > offSet/2 {
            if isViewTitleHidden {
                isViewTitleHidden = false
            }
        } else if !isViewTitleHidden {
            isViewTitleHidden = true
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fetchedResultsControllerTeam.sections?[0].numberOfObjects ?? 0
        } else {
            return fetchedResultsControllerMatches.sections?[0].numberOfObjects ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailTeamTableViewCell.self)) as? DetailTeamTableViewCell
                else { return UITableViewCell() }
            let team = fetchedResultsControllerTeam.object(at: indexPath)

            DetailTeamTableViewCellConfigurator().configureCell(cell, with: team)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as? MatchTableViewCell
                else { return UITableViewCell() }
            cell.delegate = self
            cell.indexPath = indexPath
            let match = fetchedResultsControllerMatches.object(at: IndexPath(row: indexPath.row, section: 0))

            if let calendarId = match.calendarId {
                if !eventsCalendarManager.isExistEvent(with: calendarId) {
                    match.calendarId = nil
                    do {
                        try dataProvider.context.save()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }

            MatchTableViewCellConfigurator().configureCell(cell, with: match)

            return cell
        }
    }
}

// MARK: - NSFetchedResultsController

extension DetailTeamTableViewController: NSFetchedResultsControllerDelegate {

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
            tableView.insertRows(at: [IndexPath(row: newIndexPath.row, section: newIndexPath.section + 1)], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section + 1)], with: .automatic)
        case .move:
            tableView.reloadData()
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section + 1)], with: .automatic)
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
