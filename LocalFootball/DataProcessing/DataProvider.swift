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
              
                taskContext.performAndWait {
                    for (objectsJSON, entityName) in [ (teamsJSON, Entities.team.entityName()), (tournamentsJSON, Entities.tournament.entityName()), (matchesJSON, Entities.match.entityName())] {
                        self.updateData(objectsJSON: objectsJSON, taskContext: taskContext, entityName: entityName)
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
            }
        }
    }

    private func updateData(objectsJSON: JSON, taskContext: NSManagedObjectContext, entityName: String) {
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
