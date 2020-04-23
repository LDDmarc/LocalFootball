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
    
    func fetchData<T>(entityName: String, _ type: T.Type, from fileName: String, withExtension: String, completion: @escaping(Error?) -> Void) where T: FootballNSManagedObjectProtocol {
        repository.testGetData(fileName: fileName, withExtension: withExtension) { (objectsJSON, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let objectsJSON = objectsJSON else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
           
            _ = self.updateData(objectsJSON: objectsJSON, taskContext: taskContext, entityName: "Team", Team.self)

            completion(nil)
        }
    }
    
    private func updateData<T>(objectsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String, _ type: T.Type) -> Bool where T: FootballNSManagedObjectProtocol {
        var successfull = false
        
        taskContext.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let objectIds = objectsJSON.arrayValue.map { $0["id"].int64 }.compactMap { $0 }
            request.predicate = NSPredicate(format: "NONE id IN %d", argumentArray: [objectIds])
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                    print("")
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            for objectJSON in objectsJSON.arrayValue {
                
                guard let id = objectJSON["id"].int64,
                    let lastModified = objectJSON["modified"].int64 else { return  }
                
                let req: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
                let predicate = NSPredicate(format: "id == %d", id)
                req.predicate = predicate
                do {
                    let currentObjects = try taskContext.fetch(req)
                    if let currentObject = currentObjects.first as? T{
                        if currentObject.modified < lastModified {
                            currentObject.update(with: objectJSON, into: taskContext)
                        }
                    } else {
                        guard let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: taskContext) as? T else {
                            print("Error: Failed to create a new object!")
                            return
                        }
                        newObject.update(with: objectJSON, into: taskContext)
                    }
                } catch {
                    print("Error: \(error)\nCould not find records.")
                    return
                }
            }
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    fatalError("Failed to save")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
    
    
    
    
    
    func testFetchData<T>(entityName: String, _ type: T.Type, from fileName: String, withExtension: String, completion: @escaping(Error?) -> Void) where T: Decodable {
        repository.testGetData(fileName: fileName, withExtension: withExtension) { (teamsJSON, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let teamsJSON = teamsJSON else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
           
            _ = self.testUpdateData(teamsJSON: teamsJSON, taskContext: taskContext, entityName: "Team", Team.self)

            completion(nil)
        }
    }
    
    private func testUpdateData<T>(teamsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String, _ type: T.Type) -> Bool where T: Decodable {
        var successfull = false
        
        taskContext.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let objectIds = teamsJSON.arrayValue.map { $0["id"].int64 }.compactMap { $0 }
            request.predicate = NSPredicate(format: "NONE id IN %d", argumentArray: [objectIds])
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                    print("")
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            for teamJSON in teamsJSON.arrayValue {
                
                guard let id = teamJSON["id"].int64,
                    let lastModified = teamJSON["modified"].int64 else { return  }
                
                let req: NSFetchRequest<Team> = Team.fetchRequest()
                let predicate = NSPredicate(format: "id == %d", id)
                req.predicate = predicate
                do {
                    let currentObjects = try taskContext.fetch(req)
                    if let currentObject = currentObjects.first {
                        if currentObject.modified < lastModified {
                            currentObject.update(with: teamJSON, into: taskContext)
                        }
                    } else {
                        guard let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: taskContext) as? Team else {
                            print("Error: Failed to create a new object!")
                            return
                        }
                        newObject.update(with: teamJSON, into: taskContext)
                    }
                } catch {
                    print("Error: \(error)\nCould not find records.")
                    return
                }
                
            }
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    fatalError("Failed to save")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            
            successfull = true
        }
       
        return successfull
    }
    
    func bindingData() {
        let teamsRequest: NSFetchRequest = Team.fetchRequest()
        let matchesRequest: NSFetchRequest = Match.fetchRequest()
        let tournamentsRequest: NSFetchRequest = Tournament.fetchRequest()
        
        var teams = [Team]()
        var matches = [Match]()
        var tournaments = [Tournament]()
        
        do {
            teams = try context.fetch(teamsRequest)
            matches = try context.fetch(matchesRequest)
            tournaments = try context.fetch(tournamentsRequest)
        } catch {
            print("Fetch failed")
        }
        
        var teamsResults = [Team]()
        var tornamentsResults = [Tournament]()
        
        matches.forEach { match in
            // adding teams to match
            if let team1Name = match.team1Name,
                let team2Name = match.team2Name {
                let fr: NSFetchRequest = Team.fetchRequest()
                fr.predicate = NSPredicate(format: "(name == %@) || (name == %@)", team1Name, team2Name)
                do {
                    teamsResults = try context.fetch(fr)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
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
            
            // adding tournament to match
            if let tournamentName = match.tournamentName {
                let fr: NSFetchRequest = Tournament.fetchRequest()
                fr.predicate = NSPredicate(format: "name == %@", tournamentName)
                do {
                    tornamentsResults = try context.fetch(fr)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            if let tournament = tornamentsResults.first {
                match.tournament = tournament
                
                // adding match to tournament
                if let tournamentIndex = tournaments.firstIndex(of: tournament) {
                    tournaments[tournamentIndex].addToMatches(match)
                }
            }
        }
        
        tournaments.forEach { tournament in
            let teamsNames = tournament.tournamentTeamsNames
            teamsNames.forEach { teamName in
                let fr: NSFetchRequest = Team.fetchRequest()
                fr.predicate = NSPredicate(format: "name == %@", teamName)
                do {
                    teamsResults = try context.fetch(fr)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                if let team = teamsResults.first {
                    // adding team to tournament
                    tournament.addToTeams(team)
                    // adding tournament to team
                    if let teamIndex = teams.firstIndex(of: team) {
                        teams[teamIndex].addToTournaments(tournament)
                    }
                }
            }
            
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
}

final class FirstLaunch {
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    init(userDefaults: UserDefaults) {
        wasLaunchedBefore = userDefaults.bool(forKey: "wasLaunchedBefore")
        if isFirstLaunch {
            userDefaults.set(true, forKey: "wasLaunchedBefore")
        }
    }
}
