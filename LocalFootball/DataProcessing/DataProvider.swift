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

enum Entities {
    case team
    case match
    case tournament
    
    func entityName() -> String {
        switch self {
        case .team:
            return "Team"
        case .match:
            return "Match"
        case .tournament:
            return "Tournament"
        }
    }
    
    func entityURLPathComponent() -> String {
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
    private var currentFetches = Set<String>()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer, repository: NetworkManager) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }
    
    func fetchAllData(completion: @escaping(Error?) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // for testing
            self.repository.testGetData { (teamsJSON, tournamentsJSON, matchesJSON, error) in
                if let error = error {
                    completion(error)
                    return
                }
                guard let teamsJSON = teamsJSON,
                    let tournamentsJSON = tournamentsJSON,
                    let matchesJSON = matchesJSON else {
                        let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                        completion(error)
                        return
                }
                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil
                
                _ = self.updateData(objectsJSON: teamsJSON, taskContext: taskContext, entityName: Entities.team.entityName())
                _ = self.updateData(objectsJSON: tournamentsJSON, taskContext: taskContext, entityName: Entities.tournament.entityName())
                _ = self.updateData(objectsJSON: matchesJSON, taskContext: taskContext, entityName: Entities.match.entityName())
                
                self.bindingTeamsAndMatchesData(taskContext: taskContext)
                completion(nil)
            }
        }
    }
    
    func fetchData(entity: Entities, completion: @escaping(Error?) -> Void) {
        
        let entityName = entity.entityName()
        guard !currentFetches.contains(entityName) else {
            print("double")
            return
        }
        currentFetches.insert(entityName)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            //  repository.getData(urlString: urlString) { (objectsJSON, error) in
            self.repository.testGetData(entityName: entity.entityURLPathComponent()) { (objectsJSON, error) in
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
                
                _ = self.updateData(objectsJSON: objectsJSON, taskContext: taskContext, entityName: entityName)
                
                completion(nil)
                self.currentFetches.remove(entityName)
            }
        }
    }
    
    private func updateData(objectsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String) -> Bool {
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
                
                let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let predicate = NSPredicate(format: "id == %d", id)
                req.predicate = predicate
                do {
                    let currentObjects = try taskContext.fetch(req)
                    if let currentObject = currentObjects.first as? UpdatableManagedObject {
                        if currentObject.modified < lastModified {
                            currentObject.update(with: objectJSON, into: taskContext)
                        }
                    } else {
                        guard let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: taskContext) as? UpdatableManagedObject else {
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
            
                if taskContext.hasChanges {
                    do {
                        try taskContext.save()
                    } catch {
                        fatalError("Failed to save")
                    }
                    taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
                }
        }
        
    }
    func bindingData(taskContext: NSManagedObjectContext) {
        let teamsRequest: NSFetchRequest = Team.fetchRequest()
        let matchesRequest: NSFetchRequest = Match.fetchRequest()
        let tournamentsRequest: NSFetchRequest = Tournament.fetchRequest()
        
        var teams = [Team]()
        var matches = [Match]()
        var tournaments = [Tournament]()
        
        do {
            teams = try taskContext.fetch(teamsRequest)
            matches = try taskContext.fetch(matchesRequest)
            tournaments = try taskContext.fetch(tournamentsRequest)
        } catch {
            print("Fetch failed")
        }
        
        var teamsResults = [Team]()
        var tornamentsResults = [Tournament]()
        
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
            teamsResults.forEach{ match.addToTeams($0)
                
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
                let tournamentId = match.tournamentId
                let frTournament: NSFetchRequest = Tournament.fetchRequest()
                frTournament.predicate = NSPredicate(format: "id == %d", tournamentId)
                do {
                    tornamentsResults = try taskContext.fetch(frTournament)
                } catch let error as NSError {
                    print(error.localizedDescription)
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
                let teamsIds = tournament.tournamentTeamsIds
                teamsIds.forEach { teamId in
                    let fr: NSFetchRequest = Team.fetchRequest()
                    fr.predicate = NSPredicate(format: "id == %d", teamId)
                    do {
                        teamsResults = try taskContext.fetch(fr)
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
        }
        if taskContext.hasChanges {
            do {
                try taskContext.save()
            } catch {
                fatalError("Failed to save")
            }
            taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
        }
    }
    
    
    func testFetchData<T>(entityName: String, _ type: T.Type, from fileName: String, withExtension: String, completion: @escaping(Error?) -> Void) where T: Decodable {
        repository.testGetData(entityName: fileName, withExtension: withExtension) { (teamsJSON, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let _ = teamsJSON else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
            
            //    _ = self.testUpdateData(teamsJSON: teamsJSON, taskContext: taskContext, entityName: "Team", Team.self)
            
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
            let teamsNames = tournament.tournamentTeamsIds
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
