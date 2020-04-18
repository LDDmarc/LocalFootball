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
    
    var team: Team! {
        didSet {
            if let data = team.logoImageData {
                rightBarButtonItemImageView.image = UIImage(data: data)
            }
        }
    }
    
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
                title = team.name
                rightBarButtonItemImageView.isHidden = false
            } else {
                title = nil
                rightBarButtonItemImageView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButtonItemImageView)
        
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
            let match = team.matches![indexPath.row - 1] as! Match
            
            CellsConfiguration.shared.configureCell(cell, with: match)
            
            return cell
        }
        
    }
    
    
    
}
