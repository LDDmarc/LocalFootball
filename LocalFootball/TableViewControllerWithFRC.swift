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

    var backgroundImageName: String {
        return "boy"
    }
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: backgroundImageName)
        imageView.alpha = 0.2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var eventsCalendarManager = EventsCalendarManager(presentingViewController: self)
    // swiftlint:disable weak_delegate
    // no reference cycles
    lazy var fetchedResultsControllerDelegate = DefaultFetchedResultsControllerDelegate(tableView: tableView)
    // swiftlint:enable weak_delegate
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

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        tableView.tableFooterView = UIView()
        tableView.backgroundView = activityIndicatorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    @objc func loadData() {
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            activityIndicatorView.startAnimating()
        }

        dataProvider.fetchAllData { (error) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
                if self.tableView.numberOfRows(inSection: 0) == 0 {
                    if let error = error {
                        self.chooseAlert(for: error)
                    }
                } else {
                    self.tableView.backgroundView = UIView()
                }
            }
        }
    }

    @objc func refresh() {
        dataProvider.fetchAllData { (error) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
                if self.tableView.numberOfRows(inSection: 0) != 0 { self.tableView.backgroundView = UIView() }
                if let error = error {
                    self.chooseAlert(for: error)
                }
            }
        }
    }
    func bindingCalendarEvent() { }
}
