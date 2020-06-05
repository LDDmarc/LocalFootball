//
//  File.swift
//  LocalFootball
//
//  Created by Дарья Леонова on 16.04.2020.
//  Copyright © 2020 Дарья Леонова. All rights reserved.
//

import Foundation
import UIKit

class ExpandableCellViewController: UITableViewController, ExpandableCellDelegate {

    override func loadView() {
        super.loadView()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(ExpandableCell.self, forCellReuseIdentifier: "expandableCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "expandableCell", for: indexPath) as? ExpandableCell
            else { return UITableViewCell() }
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableCell {
            cell.isExpanded = true
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableCell {
            cell.isExpanded = false
        }
    }

    func expandableCellLayoutChanged(_ expandableCell: ExpandableCell) {
        refreshTableAfterCellExpansion()
    }

    func refreshTableAfterCellExpansion() {
        self.tableView.beginUpdates()
        self.tableView.setNeedsDisplay()
        self.tableView.endUpdates()
    }
}

//protocol ExpandableCellDelegate: class {
//    func expandableCellLayoutChanged(_ expandableCell: ExpandableCell)
//}

//class ExpandableCell: UITableViewCell {
//    weak var delegate: ExpandableCellDelegate?
//
//    fileprivate let stack = UIStackView()
//    fileprivate let topView = UIView()
//    fileprivate let bottomView = UIView()
//
//    var isExpanded: Bool = false {
//        didSet {
//            bottomView.isHidden = !isExpanded
//            delegate?.expandableCellLayoutChanged(self)
//        }
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        selectionStyle = .none
//
//        contentView.addSubview(stack)
//        stack.addArrangedSubview(topView)
//        stack.addArrangedSubview(bottomView)
//
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        topView.translatesAutoresizingMaskIntoConstraints = false
//        bottomView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
//            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
//            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
//            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//            topView.heightAnchor.constraint(equalToConstant: 50),
//
//            bottomView.heightAnchor.constraint(equalToConstant: 30),
//            ])
//
//        stack.axis = .vertical
//        stack.distribution = .fill
//        stack.alignment = .fill
//        stack.spacing = 0
//
//        topView.backgroundColor = .red
//        bottomView.backgroundColor = .blue
//        bottomView.isHidden = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
