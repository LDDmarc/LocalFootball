//
//  DataProcessing.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 12.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import CoreData

class DataProcessing {
    
    static let shared = DataProcessing()
    private init() { }
    
    var context: NSManagedObjectContext = CoreDataManger.instance.persistentContainer.viewContext
    
    lazy var readingDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }()
    
    lazy var writtingDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    func loadData<T: Decodable>(from fileName: String, withExtension: String, into context: NSManagedObjectContext) -> [T] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: withExtension) else {
            fatalError("File \(fileName).\(withExtension) not found.")
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            
            jsonDecoder.userInfo[CodingUserInfoKey.context!] = context
            do {
                let object = try jsonDecoder.decode([T].self, from: data)
                do {
                    try context.save()
                    return object
                } catch {
                    fatalError("Failed to save")
                }
            } catch  {
                fatalError("Failed to decode")
            }
            
        } catch {
            fatalError("Failed to create data")
        }
    }
    
    func getDataFromCoreData<T: NSManagedObject & Decodable>(with context: NSManagedObjectContext, orFrom fileName: String, withExtension: String) -> [T] {
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else { return [] }
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                return loadData(from: fileName, withExtension: withExtension, into: context)
            }
            return results
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
    
    func bindingData(matches: [Match], teams: [Team], tournaments: [Tournament]) {
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
