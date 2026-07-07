//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 07.07.2026.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {

    static let reuseIdentifier = "categoryCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackground
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        selectionStyle = .none
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(with viewModel: CategoryCellViewModel) {
        textLabel?.text = viewModel.title
        accessoryType = viewModel.isSelected ? .checkmark : .none
    }
}
