//
//  CustomAlertViewController.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 01.06.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import UIKit

class CustomAlertViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBAction func okButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func repeatTapButton(_ sender: UIButton) {
        delegate?.tryAgain()
        self.dismiss(animated: true, completion: nil)
    }
    
    let titleText: String?
    let messageText: String?
    let imageName: String?
    
    weak var delegate: CustomAlertProtocol?
    
    init(titleText: String?, messageText: String?, imageName: String?) {
        self.titleText = titleText
        self.messageText = messageText
        self.imageName = imageName
        super.init(nibName: "CustomAlertViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        messageLabel.text = messageText
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
    }
}

protocol CustomAlertProtocol: class {
    func tryAgain()
}
