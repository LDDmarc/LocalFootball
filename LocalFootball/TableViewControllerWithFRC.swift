//
//  TableViewControllerWithFRC.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 29.05.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit
import CoreData

class TableViewControllerWithFRC: UITableViewController {
    
    let dataProvider: DataProvider
    
    lazy var eventsCalendarManager = EventsCalendarManager(presentingViewController: self)
 
    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        super.loadView()

        tableView.backgroundView = activityIndicatorView

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @objc func loadData() {
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            activityIndicatorView.startAnimating()
        }
        refresh()
    }
    
    @objc func refresh() {
        dataProvider.fetchAllData { (error) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
                if let error = error {
                    
                }
            }
        }
    }
}


