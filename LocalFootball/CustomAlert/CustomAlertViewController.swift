//
//  CustomAlertViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 01.06.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class CustomAlertAction {

    init(title: String?, style: CustomAlertAction.Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    let title: String?
    let style: Style?
    let handler: (() -> Void)?
}

extension CustomAlertAction {

    enum Style: Int {
        case `default`
        case cancel
    }
}

enum CustomAlertImage {
    case coreDataError
    case networkError
    case wrongDataFormatError
    case calendarAcccess
    case settings

    func image() -> UIImage? {
        switch self {
        case .coreDataError:
            return UIImage(named: "errorCoreData")
        case .networkError:
            return UIImage(named: "errorNetwork")
        case .wrongDataFormatError:
            return UIImage(named: "errorWrongDataFormat")
        case .calendarAcccess:
            return UIImage(named: "calendarAccess")
        case .settings:
            return UIImage(named: "settings")
        }
    }

    func color() -> UIColor {
        switch self {
        case .coreDataError:
            return #colorLiteral(red: 0.2271440923, green: 0.6863078475, blue: 0.2940705717, alpha: 1)
        case .networkError:
            return #colorLiteral(red: 0.1290173531, green: 0.5882815123, blue: 0.9528221488, alpha: 1)
        case .wrongDataFormatError:
            return #colorLiteral(red: 0.7019785047, green: 0.1373283267, blue: 0.7920630574, alpha: 1)
        case .calendarAcccess:
            return #colorLiteral(red: 0.7451130152, green: 0.211779207, blue: 0.2352870703, alpha: 1)
        case .settings:
            return #colorLiteral(red: 0.2753999596, green: 0.7058217005, blue: 0.6727463054, alpha: 1)
        }
    }
}

class CustomAlertButton: UIButton {
    var action: CustomAlertAction?
}

class CustomAlertViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var buttonsStackView: UIStackView!

    var stack = UIStackView()

    let titleText: String?
    let messageText: String?
    let imageName: String?
    let imageType: CustomAlertImage?

    var actions = [CustomAlertAction]()
    var buttons = [UIButton]()

    init(titleText: String?, messageText: String?, imageName: String?, imageType: CustomAlertImage?) {
        self.titleText = titleText
        self.messageText = messageText
        self.imageName = imageName
        self.imageType = imageType
        super.init(nibName: "CustomAlertViewController", bundle: Bundle.main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addAction(_ action: CustomAlertAction) {
        actions.append(action)
        let button = CustomAlertButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 19)
        button.action = action

        if let imageType = imageType {
            button.backgroundColor = imageType.color()
        } else {
            button.backgroundColor = #colorLiteral(red: 0.1290173531, green: 0.5882815123, blue: 0.9528221488, alpha: 1)
        }
        button.layer.cornerRadius = 12.0
        button.layer.cornerCurve = .continuous

        switch action.style {
        case .cancel:
            button.addTarget(self, action: #selector(cancelButtonTap(_:)), for: .touchUpInside)
        default:
            button.addTarget(self, action: #selector(alertButtonTap(_:)), for: .touchUpInside)
        }
        buttons.append(button)
    }

    override func loadView() {
        super.loadView()

        titleLabel.text = titleText
        messageLabel.text = messageText
        if let imageType = imageType {
            imageView.image = imageType.image()
        } else if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }

        mainView.layer.cornerRadius = 12.0
        mainView.layer.cornerCurve = .continuous
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for button in buttons {
            button.heightAnchor.constraint(equalToConstant: 45).isActive = true
            buttonsStackView.addArrangedSubview(button)
        }
    }

    @objc private func cancelButtonTap(_ sender: CustomAlertButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func alertButtonTap(_ sender: CustomAlertButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak sender] in
            sender?.action?.handler?()
        }
    }
}
