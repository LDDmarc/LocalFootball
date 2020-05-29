//
//  TabBarController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 13.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataManager: DataManagerProtocol = TestDataManager()
        let dataProvider = DataProvider(persistentContainer: CoreDataManger.instance.persistentContainer, dataManager: dataManager)
        
        let teamsTableViewController = TeamsTableViewController()
        teamsTableViewController.title = "Команды"
        teamsTableViewController.dataProvider = dataProvider
        let teamsNavigationViewController = UINavigationController(rootViewController: teamsTableViewController)
        teamsNavigationViewController.tabBarItem.image = UIImage(named: "teams")
        
        let matchesTableViewController = MatchesTableViewController()
        matchesTableViewController.title = "Матчи"
        matchesTableViewController.dataProvider = dataProvider
        let matchesNavigationViewController = UINavigationController(rootViewController: matchesTableViewController)
        matchesNavigationViewController.tabBarItem.image = UIImage(named: "matches")
        
        let tournamentsTableViewController = TournamentsTableViewController()
        tournamentsTableViewController.title = "Турниры"
        tournamentsTableViewController.dataProvider = dataProvider
        let tournamentsNavigationViewController = UINavigationController(rootViewController: tournamentsTableViewController)
        tournamentsNavigationViewController.tabBarItem.image = UIImage(named: "tournaments")
        
        let resultsTableViewController = ResultsTableViewController()
        resultsTableViewController.title = "Результаты"
        resultsTableViewController.dataProvider = dataProvider
        let resultsNavigationViewController = UINavigationController(rootViewController: resultsTableViewController)
        resultsNavigationViewController.tabBarItem.image = UIImage(named: "results")
        
        let controllers = [teamsNavigationViewController, matchesNavigationViewController, tournamentsNavigationViewController, resultsNavigationViewController]
        viewControllers = controllers
    }
    
}
