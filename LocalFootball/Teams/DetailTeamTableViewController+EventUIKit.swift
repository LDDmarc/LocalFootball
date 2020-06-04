//
//  DetailTeamTableViewController+EventUIKit.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 31.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

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
                      self.chooseAlertEventAdd(for: result)
                    }
                }
            }
        } else {
            let event = eventsCalendarManager.eventStore.event(withIdentifier: match.calendarId!)
            eventsCalendarManager.deleteEventFromCalendar(event: event) { (result) in
                DispatchQueue.main.async {
                  self.chooseAlertEventDelete(for: result)
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
