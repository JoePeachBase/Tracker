//
//  StatisticCardView.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 22.07.2026.
//

import UIKit

final class StatisticCardView: UIView {

    private let borderView = GradientBorderView()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setCount(_ count: Int) {
        countLabel.text = "\(count)"
        titleLabel.text = count.localizeNumbers("numberOfTrackersCompleted")
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(borderView)
        addSubview(countLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: topAnchor),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 90),

            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
