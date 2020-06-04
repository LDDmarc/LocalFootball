//
//  DataProvider.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 20.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

let dataErrorDomain = "dataErrorDomain"
enum DataErrorCode: NSInteger {
    case networkUnavailable = 101
    case wrongDataFormat = 102
    case noData = 103
}

enum EntityType {
    case team
    case match
    case tournament

    func name() -> String {
        switch self {
        case .team:
            return "Team"
        case .match:
            return "Match"
        case .tournament:
            return "Tournament"
        }
    }

    func urlPathComponent() -> String {
        switch self {
        case .team:
            return "teams"
        case .match:
            return "matches"
        case .tournament:
            return "tournaments"
        }
    }
}

class DataProvider {

    private let persistentContainer: NSPersistentContainer
    private let dataManager: DataManagerProtocol

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(persistentContainer: NSPersistentContainer, dataManager: DataManagerProtocol) {
        self.persistentContainer = persistentContainer
        self.dataManager = dataManager
    }

    var isLoadingAllData: Bool = false
    var isLoadingMatches: Bool = false

    func fetchAllData(completion: @escaping(DataManagerError?) -> Void) {
        guard !isLoadingAllData else {
            completion(DataManagerError.isAlreadyLoading)
            return
        }
        self.dataManager.getAllData { (data, dataManagerError) in
            self.isLoadingAllData = !self.isLoadingAllData
            if let dataManagerError = dataManagerError {
                self.isLoadingAllData = !self.isLoadingAllData
                completion(dataManagerError)
                return
            }

            guard let data = data else {
                self.isLoadingAllData = !self.isLoadingAllData
                completion(DataManagerError.noData)
                return
            }

            do {
                let jsonObject = try JSON(data: data)

                let teamsJSON = jsonObject[EntityType.team.urlPathComponent()]
                let tournamentsJSON = jsonObject[EntityType.tournament.urlPathComponent()]
                let matchesJSON = jsonObject[EntityType.match.urlPathComponent()]

                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil

                taskContext.performAndWait {
                    // because of relationships cannot use batchDelete for Team
                    do {
                        try self.updateDataWithoutBatchDelete(objectsJSON: teamsJSON, taskContext: taskContext, entityName: EntityType.team.name())
                    } catch {
                        self.isLoadingAllData = !self.isLoadingAllData
                        completion(DataManagerError.coreDataError)
                        return
                    }

                    for (objectsJSON, entityName) in [(tournamentsJSON, EntityType.tournament.name()), (matchesJSON, EntityType.match.name())] {
                        do {
                            try self.updateData(objectsJSON: objectsJSON, taskContext: taskContext, entityName: entityName)
                        } catch {
                            self.isLoadingAllData = !self.isLoadingAllData
                            completion(DataManagerError.coreDataError)
                            return
                        }
                    }

                    if taskContext.hasChanges {
                        self.bindingTeamsAndMatchesData(taskContext: taskContext)
                        do {
                            try taskContext.save()
                        } catch {
                            self.isLoadingAllData = !self.isLoadingAllData
                            completion(DataManagerError.failedToSaveToCoreData)
                            return
                        }
                        taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                    }
                }
                self.isLoadingAllData = !self.isLoadingAllData
                completion(nil)
            } catch {
                self.isLoadingAllData = !self.isLoadingAllData
                completion(DataManagerError.coreDataError)
                return
            }
        }
    }

    func fetchMatchesData(matchesStatus: MatchesStatus, from date: Date?, completion: @escaping(DataManagerError?) -> Void) {
        guard !isLoadingMatches else {
            completion(DataManagerError.isAlreadyLoading)
            return
        }
        self.dataManager.getMatchesData(matchesStatus: matchesStatus, from: date) { (data, dataManagerError) in
            self.isLoadingMatches = !self.isLoadingMatches

            if let dataManagerError = dataManagerError {
                self.isLoadingMatches = !self.isLoadingMatches
                completion(dataManagerError)
                return
            }

            guard let data = data else {
                self.isLoadingMatches = !self.isLoadingMatches
                completion(DataManagerError.noData)
                return
            }

            do {
                let jsonObject = try JSON(data: data)

                let matchesJSON = jsonObject[EntityType.match.urlPathComponent()]

                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil

                taskContext.performAndWait {
                    do {
                        try self.updateMatchesData(objectsJSON: matchesJSON, taskContext: taskContext, entityName: EntityType.match.name())
                    } catch {
                        self.isLoadingMatches = !self.isLoadingMatches
                        completion(DataManagerError.coreDataError)
                        return
                    }
                    if taskContext.hasChanges {
                        self.bindingTeamsAndMatchesData(taskContext: taskContext)
                        do {
                            try taskContext.save()
                        } catch {
                            self.isLoadingMatches = !self.isLoadingMatches
                            completion(DataManagerError.failedToSaveToCoreData)
                            return
                        }
                        taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                    }
                }
                self.isLoadingMatches = !self.isLoadingMatches
                completion(nil)
            } catch {
                self.isLoadingMatches = !self.isLoadingMatches
                completion(DataManagerError.coreDataError)
                return
            }
        }
    }

    private func updateDataWithoutBatchDelete(objectsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let objectIds = objectsJSON.arrayValue.map { $0["id"].int64 }.compactMap { $0 }
        request.predicate = NSPredicate(format: "NONE id IN %d", argumentArray: [objectIds])

        let deletedObjects = try taskContext.fetch(request) as? [NSManagedObject]
        if let deletedObjects = deletedObjects {
            for deletedObject in deletedObjects {
                taskContext.delete(deletedObject)
            }
        }
        for objectJSON in objectsJSON.arrayValue {
            guard let id = objectJSON["id"].int64,
                let lastModified = objectJSON["modified"].int64 else {
                    throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
            }

            let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let predicate = NSPredicate(format: "id == %d", id)
            req.predicate = predicate

            let currentObjects = try taskContext.fetch(req)
            if let currentObject = currentObjects.first as? UpdatableManagedObject {
                if currentObject.modified != lastModified {
                    currentObject.update(with: objectJSON, into: taskContext)
                }
            } else {
                guard let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: taskContext) as? UpdatableManagedObject else {
                    print("Error: Failed to create a new object!")
                    return
                }
                newObject.update(with: objectJSON, into: taskContext)
            }
        }
    }

    private func updateData(objectsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let objectIds = objectsJSON.arrayValue.map { $0["id"].int64 }.compactMap { $0 }
        request.predicate = NSPredicate(format: "NONE id IN %d", argumentArray: [objectIds])

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        batchDeleteRequest.resultType = .resultTypeObjectIDs

        let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult

        if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                into: [self.persistentContainer.viewContext])
        }

        for objectJSON in objectsJSON.arrayValue {
            guard let id = objectJSON["id"].int64,
                let lastModified = objectJSON["modified"].int64 else {
                    throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
            }

            let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let predicate = NSPredicate(format: "id == %d", id)
            req.predicate = predicate

            let currentObjects = try taskContext.fetch(req)
            if let currentObject = currentObjects.first as? UpdatableManagedObject {
                if currentObject.modified != lastModified {
                    currentObject.update(with: objectJSON, into: taskContext)
                }
            } else {
                guard let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: taskContext) as? UpdatableManagedObject else {
                    print("Error: Failed to create a new object!")
                    return
                }
                newObject.update(with: objectJSON, into: taskContext)
            }
        }
    }

    private func updateMatchesData(objectsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String) throws {
        for objectJSON in objectsJSON.arrayValue {
            guard let id = objectJSON["id"].int64,
                let lastModified = objectJSON["modified"].int64 else {
                    throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
            }

            let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let predicate = NSPredicate(format: "id == %i", id)
            req.predicate = predicate

            let currentObjects = try taskContext.fetch(req)
            if let currentObject = currentObjects.first as? UpdatableManagedObject {
                if currentObject.modified != lastModified {
                    currentObject.update(with: objectJSON, into: taskContext)
                }
            } else {
                guard let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: taskContext) as? UpdatableManagedObject else {
                    print("Error: Failed to create a new object!")
                    return
                }
                newObject.update(with: objectJSON, into: taskContext)
            }
        }
    }

    func bindingTeamsAndMatchesData(taskContext: NSManagedObjectContext) {
        taskContext.performAndWait {
            let matchesRequest: NSFetchRequest = Match.fetchRequest()
            var matches = [Match]()

            do {
                matches = try taskContext.fetch(matchesRequest)
            } catch {
                print("Fetch failed")
            }

            var teamsResults = [Team]()

            matches.forEach { match in
                let teamsIds = [match.team1Id, match.team2Id]
                teamsIds.forEach { teamId in
                    let fetchRequest: NSFetchRequest = Team.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %i ", teamId)
                    do {
                        teamsResults = try taskContext.fetch(fetchRequest)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    teamsResults.forEach { match.addToTeams($0) }
                    // adding match to teams
                    teamsResults.first?.addToMatches(match)
                }
            }
        }
    }
}

extension DateFormatter {

    static func readingDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }

    static func writtingDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }

}
