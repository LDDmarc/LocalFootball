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
        get {
            return "boy"
        }
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @objc func loadData() {
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            backgroundView.addSubview(backgroundImageView)
            backgroundView.addSubview(activityIndicatorView)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                backgroundImageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                backgroundImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant:  100.0),
                backgroundImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                activityIndicatorView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                activityIndicatorView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
            ])
            tableView.backgroundView = backgroundView
    
            activityIndicatorView.startAnimating()
        }
        
        dataProvider.fetchAllData { (error) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.tableView.refreshControl?.endRefreshing()
                if self.tableView.numberOfRows(inSection: 0) == 0 {
                    switch error {
                    case .networkUnavailable:
                        self.showAlertWithAction(title: "Сеть недоступна", message: "Не удалось связаться с сервером", imageName: "network")
                    case .wrongURL:
                        self.showAlertWithAction(title: "Сеть недоступна", message: "Не удалось связаться с сервером", imageName: "network")
                    case .noData:
                        self.showAlertWithAction(title: "Нет данных", message: "На нашем сервере пусто. Ни одной команды 😫", imageName: "robot")
                    case .wrongDataFormat:
                        self.showAlertWithAction(title: "Ошибка данных", message: "Не удалось обработать данные", imageName: "gear")
                    case .coreDataError:
                        self.showAlertWithAction(title: "Ошибка данных", message: "Не удалось ничего сохранить", imageName: "robot")
                    case .failedToSaveToCoreData:
                        self.showAlertWithAction(title: "Ошибка данных", message: "Не удалось ничего сохранить", imageName: "robot")
                    default:
                        break
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
                    switch error {
                    case .networkUnavailable:
                        self.showAlertWithAction(title: "Сеть недоступна", message: "Не удалось связаться с сервером", imageName: "network")
                    case .wrongURL:
                        self.showAlertWithAction(title: "Сеть недоступна", message: "Не удалось связаться с сервером", imageName: "network")
                    case .wrongDataFormat:
                        self.showAlertWithAction(title: "Ошибка данных", message: "Не удалось обработать данные", imageName: "gear")
                    case .coreDataError:
                        self.showAlertWithAction(title: "Ошибка данных", message: "Не удалось ничего сохранить", imageName: "robot")
                    case .failedToSaveToCoreData:
                        self.showAlertWithAction(title: "Ошибка данных", message: "Не удалось ничего сохранить", imageName: "robot")
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ок", style: .cancel))
        present(ac, animated: true, completion: nil)
    }
    
    func showAlertWithAction(title: String?, message: String?, imageName: String?) {
        let vc = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(vc, animated: true)
    }
    
    func tryAgain(_ : UIAlertAction) {
        if tableView.numberOfRows(inSection: 0) == 0 {
            activityIndicatorView.startAnimating()
        } else {
            tableView.refreshControl?.beginRefreshing()
        }
        loadData()
    }
}

extension TableViewControllerWithFRC: CustomAlertProtocol {
    func tryAgain() {
        if tableView.numberOfRows(inSection: 0) == 0 {
            activityIndicatorView.startAnimating()
        } else {
            tableView.refreshControl?.beginRefreshing()
        }
        loadData()
    }
}
