//
//  TabBarController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 13.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let teamsNavigationViewController = TeamsNavigationViewController()
        let teamsViewController = TeamsTableViewController()
        teamsNavigationViewController.viewControllers = [teamsViewController]
        let teamsBarItem = UITabBarItem(title: "Команды", image: .none, tag: 0)
        teamsNavigationViewController.tabBarItem = teamsBarItem
        
        let matchesViewController = MatchesTableViewController()
        let matchesBarItem = UITabBarItem(title: "Матчи", image: .none, tag: 1)
        matchesViewController.tabBarItem = matchesBarItem
        
        let controllers = [teamsNavigationViewController, matchesViewController]
        self.viewControllers = controllers
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title ?? "") ?")
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
