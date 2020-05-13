//
//  DetailTeamTableViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 17.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class DetailTeamTableViewController: UITableViewController {
    
    // MARK: - Data
    
    var team: Team! {
        didSet {
            if let data = team.logoImageData {
                rightBarButtonItemImageView.image = UIImage(data: data)
            }
            if let teamMatches = team.matches {
                var sortedMatches = teamMatches.compactMap { $0 as? Match }
                sortedMatches.sort(by: { (match1, match2) -> Bool in
                    match1.date!.compare(match2.date!) == .orderedDescending
                })
                matches = sortedMatches
            }
        }
    }
    var matches = [Match]()

    // MARK: - UI
    
    var rightBarButtonItemImageView: UIImageView = {
        let view = UIImageView()
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40)
        ])
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    var isViewTitleHidden: Bool = true {
        didSet {
            if !isViewTitleHidden {
                rightBarButtonItemImageView.isHidden = false
            } else {
                rightBarButtonItemImageView.isHidden = true
            }
        }
    }
    
    // MARK: - Loading View
    
    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButtonItemImageView)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = team.name ?? "??"
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MatchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MatchTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: DetailTeamTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: DetailTeamTableViewCell.self))
    }
    
    // MARK: - Table view data source
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offSet = tableView.visibleCells.first?.bounds.height ?? 120.0
        if scrollView.contentOffset.y + scrollView.adjustedContentInset.top > offSet/2 {
            if isViewTitleHidden {
                isViewTitleHidden = false
            }
        } else if !isViewTitleHidden {
            isViewTitleHidden = true
        }
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (team.matches?.count ?? 0) + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailTeamTableViewCell.self)) as! DetailTeamTableViewCell
            CellsConfiguration.shared.configureCell(cell, with: team)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MatchTableViewCell.self)) as! MatchTableViewCell
            let match = matches[indexPath.row - 1]
            CellsConfiguration.shared.configureCell(cell, with: match)
            return cell
        }
    }
}

