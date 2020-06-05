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

        let teamsTableViewController = TeamsTableViewController(dataProvider: dataProvider)
        teamsTableViewController.title = "Команды"
        let teamsNavigationViewController = UINavigationController(rootViewController: teamsTableViewController)
        teamsNavigationViewController.tabBarItem.image = UIImage(named: "teams")

        let matchesTableViewController = MatchesTableViewController(dataProvider: dataProvider)
        matchesTableViewController.title = "Матчи"
        let matchesNavigationViewController = UINavigationController(rootViewController: matchesTableViewController)
        matchesNavigationViewController.tabBarItem.image = UIImage(named: "matches")

        let tournamentsTableViewController = TournamentsTableViewController(dataProvider: dataProvider)
        tournamentsTableViewController.title = "Турниры"
        let tournamentsNavigationViewController = UINavigationController(rootViewController: tournamentsTableViewController)
        tournamentsNavigationViewController.tabBarItem.image = UIImage(named: "tournaments")

        let resultsTableViewController = ResultsTableViewController(dataProvider: dataProvider)
        resultsTableViewController.title = "Результаты"
        let resultsNavigationViewController = UINavigationController(rootViewController: resultsTableViewController)
        resultsNavigationViewController.tabBarItem.image = UIImage(named: "results")

        let controllers = [teamsNavigationViewController, matchesNavigationViewController, tournamentsNavigationViewController, resultsNavigationViewController]
        controllers.forEach { $0.navigationBar.prefersLargeTitles = true }
        viewControllers = controllers
    }
}
