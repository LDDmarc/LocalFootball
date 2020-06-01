//
//  MatchesTableViewController+EventUIKit.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
// MARK: - EventKit CalendarWorking

extension MatchesTableViewController: MatchTableViewCellDelegate {
    
    func favoriteStarTap(_ sender: UIButton, cellForRowAt indexPath: IndexPath) {
        let match = fetchedResultsController.object(at: indexPath)
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
}

