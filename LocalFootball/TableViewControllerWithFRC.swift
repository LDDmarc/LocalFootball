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
            /*
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
             */
            tableView.backgroundView = activityIndicatorView
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
    
    func bindingCalendarEvent() {
        
    }
}

// MARK: - Alerts

extension TableViewControllerWithFRC {
    
    func showAlertWithOkButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let vc = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        vc.addAction(CustomAlertAction(title: "ОК", style: .cancel))
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(vc, animated: true)
    }
    
    func showAlertWithAccessButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let vc = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        vc.addAction(CustomAlertAction(title: "Не разрешать", style: .cancel))
        
        vc.addAction(CustomAlertAction(title: "Перейти в настройки", style: .default, handler: {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(vc, animated: true)
    }
    
    func showAlertWithBindingButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let vc = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        vc.addAction(CustomAlertAction(title: "ОК", style: .cancel))
        
        vc.addAction(CustomAlertAction(title: "Связать", style: .default, handler: {
            self.bindingCalendarEvent()
        }))
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(vc, animated: true)
    }
    
    func showAlertWithRepeatButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let vc = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        vc.addAction(CustomAlertAction(title: "ОК", style: .cancel))
        
        vc.addAction(CustomAlertAction(title: "Повторить", style: .default, handler: {
            if self.tableView.numberOfRows(inSection: 0) == 0 {
                self.activityIndicatorView.startAnimating()
            } else {
                self.tableView.refreshControl?.beginRefreshing()
            }
            self.loadData()
        }))
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(vc, animated: true)
    }
    
    func chooseAlert(for error: DataManagerError) {
        switch error {
        case .networkUnavailable:
            self.showAlertWithRepeatButton(title: "Сеть недоступна", message: "Не удалось связаться с сервером", imageName: "network", imageType: CustomAlertImage.networkError)
        case .wrongURL:
            self.showAlertWithRepeatButton(title: "Сеть недоступна", message: "Не удалось связаться с сервером", imageName: "network", imageType: .networkError)
        case .noData:
            self.showAlertWithRepeatButton(title: "Нет данных", message: "На нашем сервере пусто. Ни одной команды 😫", imageName: "robot", imageType: .wrongDataFormatError)
        case .wrongDataFormat:
            self.showAlertWithRepeatButton(title: "Ошибка данных", message: "Не удалось обработать данные", imageName: "gear", imageType: .wrongDataFormatError)
        case .coreDataError:
            self.showAlertWithRepeatButton(title: "Ошибка данных", message: "Не удалось ничего сохранить", imageName: "robot", imageType: .coreDataError)
        case .failedToSaveToCoreData:
            self.showAlertWithRepeatButton(title: "Ошибка данных", message: "Не удалось ничего сохранить", imageName: "robot", imageType: .coreDataError)
        default:
            break
        }
    }
    
    func chooseAlert(for error: CustomError) {
        switch error {
        case .calendarAccessDeniedOrRestricted:
            self.showAlertWithAccessButton(title: "Нет доступа к календарю", message: "Разрешите доступ к календарю в системных настройках", imageName: nil, imageType: .settings)
        case .eventNotAddedToCalendar:
            self.showAlertWithOkButton(title: "Ошибка", message: "Данного события нет в Вашем календаре", imageName: nil, imageType: .calendarAcccess)
        case .eventAlreadyExistsInCalendar:
            self.showAlertWithBindingButton(title: "Ошибка", message: "Данное событие уже есть Вашем календаре", imageName: nil, imageType: .calendarAcccess)
        default: break
        }
    }
    
    func chooseAlertEventAdd(for result: Result<Bool, CustomError>) {
        switch result {
        case .failure(let error):
            self.chooseAlert(for: error)
        case .success:
            break
        }
    }
    
    func chooseAlertEventDelete(for result: Result<Bool, CustomError>) {
        switch result {
        case .failure(let error):
            self.chooseAlert(for: error)
        case .success:
            self.showAlertWithOkButton(title: "Удалено", message: "Матч удален из Вашего календаря", imageName: nil, imageType: .calendarAcccess)
        }
    }
    
}

