//
//  TableViewControllerWithFRC + Alerts.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 04.06.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

// MARK: - Alerts

extension TableViewControllerWithFRC {

    func showAlertWithOkButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let customAlertController = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        customAlertController.addAction(CustomAlertAction(title: "ОК", style: .cancel))
        customAlertController.modalPresentationStyle = .overCurrentContext
        customAlertController.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(customAlertController, animated: true)
    }

    func showAlertWithAccessButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let customAlertController = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        customAlertController.addAction(CustomAlertAction(title: "Не разрешать", style: .cancel))

        customAlertController.addAction(CustomAlertAction(title: "Перейти в настройки", style: .default, handler: {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))

        customAlertController.modalPresentationStyle = .overCurrentContext
        customAlertController.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(customAlertController, animated: true)
    }

    func showAlertWithBindingButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let customAlertController = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        customAlertController.addAction(CustomAlertAction(title: "ОК", style: .cancel))

        customAlertController.addAction(CustomAlertAction(title: "Связать", style: .default, handler: {
            self.bindingCalendarEvent()
        }))

        customAlertController.modalPresentationStyle = .overCurrentContext
        customAlertController.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(customAlertController, animated: true)
    }

    func showAlertWithRepeatButton(title: String?, message: String?, imageName: String?, imageType: CustomAlertImage?) {
        let customAlertController = CustomAlertViewController(titleText: title, messageText: message, imageName: imageName, imageType: imageType)
        customAlertController.addAction(CustomAlertAction(title: "ОК", style: .cancel))

        customAlertController.addAction(CustomAlertAction(title: "Повторить", style: .default, handler: {
            if self.tableView.numberOfRows(inSection: 0) == 0 {
                self.activityIndicatorView.startAnimating()
            } else {
                self.tableView.refreshControl?.beginRefreshing()
            }
            self.loadData()
        }))

        customAlertController.modalPresentationStyle = .overCurrentContext
        customAlertController.modalTransitionStyle = .crossDissolve
        navigationController?.tabBarController?.present(customAlertController, animated: true)
    }

    func chooseAlert(for error: DataManagerError) {
        switch error {
        case .networkUnavailable:
            self.showAlertWithRepeatButton(title: "Сеть недоступна",
                                           message: "Не удалось связаться с сервером",
                                           imageName: "network",
                                           imageType: CustomAlertImage.networkError)
        case .wrongURL:
            self.showAlertWithRepeatButton(title: "Сеть недоступна",
                                           message: "Не удалось связаться с сервером",
                                           imageName: "network",
                                           imageType: .networkError)
        case .noData:
            self.showAlertWithRepeatButton(title: "Нет данных",
                                           message: "На нашем сервере пусто. Ни одной команды 😫",
                                           imageName: "robot",
                                           imageType: .wrongDataFormatError)
        case .wrongDataFormat:
            self.showAlertWithRepeatButton(title: "Ошибка данных",
                                           message: "Не удалось обработать данные",
                                           imageName: "gear",
                                           imageType: .wrongDataFormatError)
        case .coreDataError:
            self.showAlertWithRepeatButton(title: "Ошибка данных",
                                           message: "Не удалось ничего сохранить",
                                           imageName: "robot",
                                           imageType: .coreDataError)
        case .failedToSaveToCoreData:
            self.showAlertWithRepeatButton(title: "Ошибка данных",
                                           message: "Не удалось ничего сохранить",
                                           imageName: "robot",
                                           imageType: .coreDataError)
        default:
            break
        }
    }

    func chooseAlert(for error: CustomError) {
        switch error {
        case .calendarAccessDeniedOrRestricted:
            self.showAlertWithAccessButton(title: "Нет доступа к календарю",
                                           message: "Разрешите доступ к календарю в системных настройках",
                                           imageName: nil,
                                           imageType: .settings)
        case .eventNotAddedToCalendar:
            self.showAlertWithOkButton(title: "Ошибка",
                                       message: "Данного события нет в Вашем календаре",
                                       imageName: nil,
                                       imageType: .calendarAcccess)
        case .eventAlreadyExistsInCalendar:
            self.showAlertWithBindingButton(title: "Ошибка",
                                            message: "Данное событие уже есть Вашем календаре",
                                            imageName: nil,
                                            imageType: .calendarAcccess)
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
