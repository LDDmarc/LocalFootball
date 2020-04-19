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
        
        let teamsImageView = UIImageView(image: UIImage(named: "teams"))
        NSLayoutConstraint.activate([
            teamsImageView.widthAnchor.constraint(equalToConstant: 40),
            teamsImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        teamsImageView.contentMode = .scaleAspectFit
        
        
        let teamsBarItem = UITabBarItem(title: nil, image: .none, tag: 0)
            //UITabBarItem.init
            //UITabBarItem(title: nil, image: .none, tag: 0)
       // UITabBarItem.init(
        teamsNavigationViewController.tabBarItem = teamsBarItem
        
        let matchesViewController = MatchesTableViewController()
        let matchesBarItem = UITabBarItem(title: "Матчи", image: .none, tag: 1)
        matchesViewController.tabBarItem = matchesBarItem
        
        let tournamentsNavigationViewController = TournamentsNavigationViewController()
        let tournamentsViewController = TournamentsTableViewController()
        tournamentsNavigationViewController.viewControllers = [tournamentsViewController]
        let tournamentsBarItem = UITabBarItem(title: "Турниры", image: .none, tag: 2)
        tournamentsNavigationViewController.tabBarItem = tournamentsBarItem
        
        let controllers = [teamsNavigationViewController, matchesViewController, tournamentsNavigationViewController]
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
