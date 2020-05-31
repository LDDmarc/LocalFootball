//
//  MatchesTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class MatchesTableViewController: TableViewControllerWithFRC {
    
    // MARK: - FetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<Match> = {
        let request: NSFetchRequest = Match.fetchRequest()
        if let matchesByTournamentPredicate = matchesByTournamentPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchesByTournamentPredicate, matchesByStatusPredicate])
        } else {
            request.predicate = matchesByStatusPredicate
        }
        request.sortDescriptors = [sortDescriptor]
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
    
    var sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    
    var matchesByStatusPredicate: NSPredicate = NSPredicate(format: "status == YES") {
        didSet {
            filterContent()
        }
    }
    var matchesByTeamsPredicate: NSPredicate? {
        didSet {
            filterContent()
        }
    }
    var matchesByTournamentPredicate: NSPredicate? {
        didSet {
            filterContent()
        }
    }
    
  
    // MARK: - UI
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Введите название команды"
        sc.searchResultsUpdater = self
        sc.searchBar.isHidden = false
        definesPresentationContext = true
        return sc
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Прошедшие", "Предстоящие"]
        let sc = UISegmentedControl(items: items)
        sc.addTarget(self, action: #selector(segmentedControlTap(sender:)), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var loadMoreActivityIndicatorView: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        
        navigationItem.searchController = searchController
        navigationItem.titleView = segmentedControl
        
        tableView.estimatedRowHeight = 139.5
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        customView.backgroundColor = UIColor.clear
        loadMoreActivityIndicatorView = UIActivityIndicatorView(style: .medium)
        loadMoreActivityIndicatorView.center = CGPoint(x: customView.center.x, y: customView.center.y + 8)
        customView.addSubview(loadMoreActivityIndicatorView)
        tableView.tableFooterView = customView
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func reloadTableData() {
        tableView.reloadData()
    }
    
    @objc private func loadMatches() {
        let date = fetchedResultsController.fetchedObjects?.last?.date
        let matchesStatus = (segmentedControl.selectedSegmentIndex == 0) ? MatchesStatus.past : MatchesStatus.future
        
        dataProvider.fetchMatchesData(matchesStatus: matchesStatus, from: date) { (error) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.loadMoreActivityIndicatorView.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
                if let error = error {
                    
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as! MatchTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        let match = fetchedResultsController.object(at: indexPath)
        
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (fetchedResultsController.fetchedObjects?.count ?? 1) - 1 {
            loadMoreActivityIndicatorView.startAnimating()
            loadMatches()
        }
    }
}

// MARK: - NSFetchedResultsController

extension MatchesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating
extension MatchesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            matchesByTeamsPredicate = NSPredicate(format: "ANY teams.name CONTAINS[cd] %@",  searchText)
        } else {
            matchesByTeamsPredicate = nil
        }
    }
    
    @objc func segmentedControlTap(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            matchesByStatusPredicate = NSPredicate(format: "status == YES")
        case 1:
            sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            matchesByStatusPredicate = NSPredicate(format: "status == NO")
        default:
            sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            matchesByStatusPredicate = NSPredicate(format: "status == YES")
        }
    }
    
    private func filterContent() {
        var predicates = [NSPredicate]()
        
        predicates.append(matchesByStatusPredicate)
        
        if let matchesByTeamsPredicate = matchesByTeamsPredicate {
            predicates.append(matchesByTeamsPredicate)
        }
        if let matchesByTournamentPredicate = matchesByTournamentPredicate {
            predicates.append(matchesByTournamentPredicate)
        }
        
        fetchedResultsController.fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        do {
            try fetchedResultsController.performFetch()
            tableView?.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
}

