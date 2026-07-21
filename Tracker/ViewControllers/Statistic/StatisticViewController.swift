//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

final class StatisticViewController: UIViewController {

    private let recordStore: TrackerRecordStore
    private var notificationToken: NSObjectProtocol?

    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = "statistics".localized
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var completedCard: StatisticCardView = {
        StatisticCardView()
    }()

    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView(image: .statisticsEmptyScreen)
        image.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "statistics.empty.screen.label".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(image)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        return view
    }()

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayoutAndConstraints()
        subscribeToRecordChanges()
        updateStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }

    deinit {
        if let notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }

    private func setupLayoutAndConstraints() {
        view.addSubview(header)
        view.addSubview(completedCard)
        view.addSubview(emptyScreenView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            completedCard.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 77),
            completedCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            emptyScreenView.topAnchor.constraint(equalTo: header.bottomAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func subscribeToRecordChanges() {
        notificationToken = NotificationCenter.default.addObserver(
            forName: .trackerRecordsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatistics()
        }
    }

    private func updateStatistics() {
        let completedCount = recordStore.records.count
        let hasStatistics = completedCount > 0

        completedCard.isHidden = !hasStatistics
        emptyScreenView.isHidden = hasStatistics
        completedCard.setCount(completedCount)
    }
}
