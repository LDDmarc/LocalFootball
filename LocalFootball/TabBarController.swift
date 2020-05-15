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
        
        let teamsTableViewController = TeamsTableViewController()
        teamsTableViewController.title = "Команды"
        let teamsNavigationViewController = UINavigationController(rootViewController: teamsTableViewController)
        teamsNavigationViewController.tabBarItem.image = UIImage(named: "teams")
        
        let matchesTableViewController = MatchesTableViewController()
        matchesTableViewController.title = "Матчи"
        let matchesNavigationViewController = UINavigationController(rootViewController: matchesTableViewController)
        matchesNavigationViewController.tabBarItem.image = UIImage(named: "matches")
        
        let tournamentsTableViewController = TournamentsTableViewController()
        tournamentsTableViewController.title = "Турниры"
        let tournamentsNavigationViewController = UINavigationController(rootViewController: tournamentsTableViewController)
        tournamentsNavigationViewController.tabBarItem.image = UIImage(named: "tournaments")
        
        let resultsTableViewController = ResultsTableViewController()
        resultsTableViewController.title = "Результаты"
        let resultsNavigationViewController = UINavigationController(rootViewController: resultsTableViewController)
        resultsNavigationViewController.tabBarItem.image = UIImage(named: "results")
        
        let controllers = [teamsNavigationViewController, matchesNavigationViewController, tournamentsNavigationViewController, resultsNavigationViewController]
        viewControllers = controllers
    }
    
}
