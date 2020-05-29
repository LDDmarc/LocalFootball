//
//  DetailTeamTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class DetailTeamTableViewController: UITableViewController {
    
    var dataProvider: DataProvider!
    lazy var eventsCalendarManager = EventsCalendarManager(presentingViewController: self)
    
    
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
        frc.delegate = self
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

    // MARK: - UI
    
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
//        navigationItem.title = team.name ?? "??"
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: DetailTeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: DetailTeamTableViewCell.self))
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
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailTeamTableViewCell.self)) as! DetailTeamTableViewCell
            let team = fetchedResultsControllerTeam.object(at: indexPath)
            CellsConfiguration.shared.configureCell(cell, with: team)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as! MatchTableViewCell
            cell.delegate = self
            cell.indexPath = indexPath
            let match = fetchedResultsControllerMatches.object(at: IndexPath(row: indexPath.row, section: 0))
            CellsConfiguration.shared.configureCell(cell, with: match)
            
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
        
        var indexPathFixed: IndexPath?
        var newIndexPathFixed: IndexPath?
        
        if controller == fetchedResultsControllerTeam {
            indexPathFixed = indexPath
            newIndexPathFixed = newIndexPath
        } else {
            if let indexPath = indexPath {
                indexPathFixed = IndexPath(row: indexPath.row, section: indexPath.section + 1)
            }
            if let newIndexPath = newIndexPath {
                newIndexPathFixed = IndexPath(row: newIndexPath.row, section: newIndexPath.section + 1)
            }
        }
        
        switch type {
          case .insert:
              guard let newIndexPathFixed = newIndexPathFixed else { return }
              tableView.insertRows(at: [newIndexPathFixed], with: .automatic)
          case .delete:
              guard let indexPathFixed = indexPathFixed else { return }
              tableView.deleteRows(at: [indexPathFixed], with: .automatic)
          case .move:
              tableView.reloadData()
          case .update:
              guard let indexPathFixed = indexPathFixed else { return }
              tableView.reloadRows(at: [indexPathFixed], with: .automatic)
          @unknown default:
              tableView.reloadData()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .delete:
//            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
//        case .insert:
//            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
//        default:
//            break
//        }
    }
    
}

// MARK: - EventKit CalendarWorking

extension DetailTeamTableViewController: MatchTableViewCellDelegate {

    func favoriteStarTap(_ sender: UIButton, cellForRowAt indexPath: IndexPath) {
        let match = fetchedResultsControllerMatches.object(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))
        eventsCalendarManager.match = match
           guard let team1 = match.teams?.firstObject as? Team,
               let team2 = match.teams?.lastObject as? Team,
               let team1Name = team1.name,
               let team2Name = team2.name else { return }
           
           if match.calendarId == nil {
               if let startDate = match.date,
                   let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate) {
                   let event = Event(name: "Матч \(team1Name) - \(team2Name)", startDate: startDate, endDate: endDate)
                   
                     eventsCalendarManager.presentCalendarModalToAddEvent(event: event) { (result) in
                         DispatchQueue.main.async {
                             switch result {
                             case .failure(let error):
                                 switch error {
                                 case .calendarAccessDeniedOrRestricted:
                                     self.showAlert(title: "Нет доступа к календарю", message: "Разрешите доступ к календарю в системных настройках")
                                 case .eventNotAddedToCalendar:
                                     self.showAlert(title: "Ошибка", message: "Данного события нет в Вашем календаре")
                                 default: ()
                                 }
                             case .success(_):
                                 ()
                             }
                         }
                     }
               }
           } else {
               let event = eventsCalendarManager.eventStore.event(withIdentifier: match.calendarId!)
               eventsCalendarManager.deleteEventFromCalendar(event: event) { (result) in
                   switch result {
                   case .success:
                       self.showAlert(title: "Удалено", message: "Матч \(team1Name) - \(team2Name) удален из Вашего календаря")
                   case .failure(let error):
                       switch error {
                       case .calendarAccessDeniedOrRestricted:
                           self.showAlert(title: "Нет доступа к календарю", message: "Разрешите доступ к календарб в системных настройках")
                       case .eventNotAddedToCalendar:
                           self.showAlert(title: "Ошибка", message: "Данного события нет в Вашем календаре")
                       default: ()
                       }
                   }
               }
               match.calendarId = nil
               do {
                   try dataProvider.context.save()
               } catch let error as NSError {
                   print(error.localizedDescription)
               }
           }
       }
    
    func showAlert(title: String?, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ок", style: .cancel))
        present(ac, animated: true, completion: nil)
    }
}
