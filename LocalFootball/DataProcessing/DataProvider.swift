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
    private let repository: NetworkManager
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer, repository: NetworkManager) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }
    
    func testFetchAllData(from fileName: String, completion: @escaping(Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // for testing
            self.repository.testGetData(from: fileName) { (data, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: dataErrorDomain, code: DataErrorCode.noData.rawValue, userInfo: nil)
                    completion(error)
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
                        for (objectsJSON, entityName) in [(teamsJSON, EntityType.team.name()), (tournamentsJSON, EntityType.tournament.name()), (matchesJSON, EntityType.match.name())] {
                            do {
                                try self.updateData(objectsJSON: objectsJSON, taskContext: taskContext, entityName: entityName)
                            } catch let error as NSError {
                                completion(error)
                                return
                            }
                        }
                        if taskContext.hasChanges {
                            self.bindingTeamsAndMatchesData(taskContext: taskContext)
                            do {
                                try taskContext.save()
                            } catch {
                                fatalError("Failed to save")
                            }
                            taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                        }
                    }
                    completion(nil)
                } catch let error as NSError {
                    completion(error)
                    return
                }
            }
        }
    }
    
    func fetchAllData(completion: @escaping(Error?) -> Void) {
        repository.getData { (data, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.noData.rawValue, userInfo: nil)
                completion(error)
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
                    // because of relationships cannot usebatchDelete for Team
                    do {
                        try self.updateDataWithoutBatchDelete(objectsJSON: teamsJSON, taskContext: taskContext, entityName: EntityType.team.name())
                    } catch let error as NSError {
                        completion(error)
                        return
                    }
                    
                    for (objectsJSON, entityName) in [(tournamentsJSON, EntityType.tournament.name()), (matchesJSON, EntityType.match.name())] {
                        do {
                            try self.updateData(objectsJSON: objectsJSON, taskContext: taskContext, entityName: entityName)
                        } catch let error as NSError {
                            completion(error)
                            return
                        }
                    }
                    
                    if taskContext.hasChanges {
                        self.bindingTeamsAndMatchesData(taskContext: taskContext)
                        do {
                            try taskContext.save()
                        } catch {
                            fatalError("Failed to save")
                        }
                        taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                    }
                }
                completion(nil)
            } catch let error as NSError {
                completion(error)
                return
            }
        }
        
    }
    
    func fetchMatchesData(pastMatches: Bool, beginningFrom date: Date?, completion: @escaping(Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // for testing
            self.repository.testGetMatchesData(pastMatches: pastMatches, beginningFrom: date) { (data, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: dataErrorDomain, code: DataErrorCode.noData.rawValue, userInfo: nil)
                    completion(error)
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
                        } catch let error as NSError {
                            completion(error)
                            return
                        }
                        if taskContext.hasChanges {
                            self.bindingTeamsAndMatchesData(taskContext: taskContext)
                            do {
                                try taskContext.save()
                            } catch {
                                fatalError("Failed to save")
                            }
                            taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                        }
                    }
                    completion(nil)
                } catch let error as NSError {
                    completion(error)
                    return
                }
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
  
    func bindingTeamsAndMatchesData(taskContext: NSManagedObjectContext) {
        taskContext.performAndWait {
            let teamsRequest: NSFetchRequest = Team.fetchRequest()
            let matchesRequest: NSFetchRequest = Match.fetchRequest()
            
            var teams = [Team]()
            var matches = [Match]()
            
            do {
                teams = try taskContext.fetch(teamsRequest)
                matches = try taskContext.fetch(matchesRequest)
            } catch {
                print("Fetch failed")
            }
            
            var teamsResults = [Team]()
            
            matches.forEach { match in
                // adding teams to match
                let team1Id = match.team1Id
                let team2Id = match.team2Id
                
                let fr: NSFetchRequest = Team.fetchRequest()
                fr.predicate = NSPredicate(format: "(id == %d) || (id == %d)", team1Id, team2Id)
                do {
                    teamsResults = try taskContext.fetch(fr)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                teamsResults.forEach{ match.addToTeams($0) }
                
                // adding match to teams
                if let firstTeamResult = teamsResults.first,
                    let teamIndex = teams.firstIndex(of: firstTeamResult) {
                    teams[teamIndex].addToMatches(match)
                }
                if let secondTeamResult = teamsResults.last,
                    let teamIndex = teams.firstIndex(of: secondTeamResult) {
                    teams[teamIndex].addToMatches(match)
                }
            }
        }
    }
    
}

extension DateFormatter {
    
    static func readingDateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }
    
    static func writtingDateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
    
}
