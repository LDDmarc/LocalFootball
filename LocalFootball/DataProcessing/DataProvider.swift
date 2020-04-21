//
//  DataProvider.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 20.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import CoreData

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
    
    func fetchData<T>(entityName: String, _ type: T.Type, urlString: String , completion: @escaping(Error?) -> Void) where T: Decodable {
        
        repository.getData(urlString: urlString) { (data, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let data = data else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
            
            _ = self.updateData(data: data, taskContext: taskContext, entityName: entityName, type)
            self.bindingData()
            completion(nil)
        }
    }
    
    private func updateData<T>(data: Data, taskContext: NSManagedObjectContext, entityName: String, _ type: T.Type) -> Bool where T: Decodable {
        var successfull = false
        taskContext.performAndWait {
            let teamRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: teamRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            // Create new records.
            let jsonDecoder = JSONDecoder()
            jsonDecoder.userInfo[CodingUserInfoKey.context!] = taskContext
            do {
                _ = try jsonDecoder.decode(type.self, from: data)
                do {
                    try taskContext.save()
                } catch {
                    fatalError("Failed to save")
                }
            } catch  {
                fatalError("Failed to decode")
            }
            taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
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
