//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 21.07.2026.
//

import UIKit

final class FiltersViewController: UIViewController {

    var onFilterSelected: ((TrackerFilter) -> Void)?

    private let currentFilter: TrackerFilter
    private let separatorTag = 999
    private let rowHeight: CGFloat = 75

    private lazy var header: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "filters.header".localized
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    init(currentFilter: TrackerFilter) {
        self.currentFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutAndConstraints()
    }

    private func setupLayoutAndConstraints() {
        view.backgroundColor = .ypWhite
        view.addSubview(header)
        view.addSubview(filtersTableView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filtersTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: rowHeight * CGFloat(TrackerFilter.allCases.count))
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        let filter = TrackerFilter.allCases[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = filter.title
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        cell.tintColor = .ypBlue
        cell.accessoryType = (filter.isCheckable && filter == currentFilter) ? .checkmark : .none

        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { rowHeight }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filter = TrackerFilter.allCases[indexPath.row]
        onFilterSelected?(filter)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.viewWithTag(separatorTag)?.removeFromSuperview()
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        guard !isLastRow else { return }

        let separatorInset: CGFloat = 16
        let separator = UIView(frame: CGRect(
            x: separatorInset,
            y: cell.frame.height - 1,
            width: tableView.bounds.width - separatorInset * 2,
            height: 1
        ))
        separator.backgroundColor = .ypGray
        separator.tag = separatorTag
        cell.addSubview(separator)
    }
}
