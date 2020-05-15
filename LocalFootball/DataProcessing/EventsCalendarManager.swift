//
//  EventsCalendarManager.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 14.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI

struct Event {
    var name: String
    var startDate: Date
    var endDate: Date
}

enum CustomError: Error {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
    case eventCouldntBeDeleted
    case eventDoesntExist
}

typealias EventsCalendarManagerResponse = (_ result: Result<Bool, CustomError>) -> Void
typealias EventsCalendarManagerResponseWithId = (_ result: Result<Bool, CustomError>, _ eventId: String?) -> Void
typealias EventsCalendarManagerEventId = (_ eventId: String?) -> Void

class EventsCalendarManager: NSObject {
    
    var eventStore: EKEventStore!
    
    init(presentingViewController: UIViewController?) {
        eventStore = EKEventStore()
        self.presentingViewController = presentingViewController
    }
    
    var match: Match!
    let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, repository: NetworkManager.shared)
    
    let presentingViewController: UIViewController?
    
    private func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: .event) { (isAccessGranted, error) in
            completion(isAccessGranted, error)
        }
    }
    
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    func addEventToCalendar(event: Event, completion: @escaping EventsCalendarManagerResponse) -> String? {
        let authorizationStatus = getAuthorizationStatus()
        var eventId: String?
        switch authorizationStatus {
        case .authorized:
            eventId = self.addEvent(event: event) { result in
                switch result {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .notDetermined:
            self.requestAccess { (accessGranted, error) in
                if accessGranted {
                    eventId = self.addEvent(event: event) { result in
                        switch result {
                        case .success:
                            completion(.success(true))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        default:
            completion(.failure(.calendarAccessDeniedOrRestricted))
        }
        return eventId
    }
    
    private func generateEvent(event: Event) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.name
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        newEvent.addAlarm(EKAlarm(relativeOffset: -3600))
        return newEvent
    }
    
    private func addEvent(event: Event, completion: @escaping EventsCalendarManagerResponse) -> String {
        let eventToAdd = generateEvent(event: event)
        if !isAlreadyExist(event: eventToAdd) {
            do {
                try eventStore.save(eventToAdd, span: .thisEvent)
            } catch {
                completion(.failure(.eventNotAddedToCalendar))
            }
        } else {
            completion(.failure(.eventAlreadyExistsInCalendar))
        }
        return eventToAdd.eventIdentifier
    }
    
    private func isAlreadyExist(event eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        return existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && eventToAdd.startDate == event.startDate && eventToAdd.endDate == event.endDate
        }
    }
    
    func deleteEventFromCalendar(event: EKEvent?, completion: @escaping EventsCalendarManagerResponse) {
        let authorizationStatus = getAuthorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            self.deleteEvent(event: event) { result in
                switch result {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .notDetermined:
            self.requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.deleteEvent(event: event) { result in
                        switch result {
                        case .success:
                            completion(.success(true))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        default:
            completion(.failure(.calendarAccessDeniedOrRestricted))
        }
    }
    
    private func deleteEvent(event: EKEvent?, completion: @escaping EventsCalendarManagerResponse) {
        guard let event = event else { return }
        do {
            try eventStore.remove(event, span: .thisEvent)
            completion(.success(true))
        } catch {
            completion(.failure(.eventCouldntBeDeleted))
        }
    }
    
    func updateEvent(withIdentifier: String, by newStartDate: Date, by newEndDate: Date) {
        guard let event = eventStore.event(withIdentifier: withIdentifier) else { return }
        event.startDate = newStartDate
        event.endDate = newEndDate
        event.alarms?.removeAll()
        event.addAlarm(EKAlarm(relativeOffset: -3600))
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func presentCalendarModalToAddEvent(event: Event, completion : @escaping EventsCalendarManagerResponse) {
        let authorizationStatus = getAuthorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentEventCalendarDetailModal(event: event)
            completion(.success(true))
        case .notDetermined:
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.presentEventCalendarDetailModal(event: event)
                    completion(.success(true))
                } else {
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        default:
            completion(.failure(.calendarAccessDeniedOrRestricted))
            
        }
    }
    
    func presentEventCalendarDetailModal(event: Event) {
        let eventToAdd = generateEvent(event: event)
        if !isAlreadyExist(event: eventToAdd) {
            DispatchQueue.main.async {
                let eventModalVC = EKEventEditViewController()
                eventModalVC.event = eventToAdd
                eventModalVC.eventStore = self.eventStore
                eventModalVC.editViewDelegate = self
                self.presentingViewController?.present(eventModalVC, animated: true)
            }
        }
    }
}

extension EventsCalendarManager: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true) {
            self.match.calendarId = controller.event?.eventIdentifier
            do {
                try self.dataProvider.context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
