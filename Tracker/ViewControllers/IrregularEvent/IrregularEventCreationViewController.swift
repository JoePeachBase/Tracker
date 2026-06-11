//
//  UnRegularEventCreationViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 09.06.2026.
//

import UIKit

final class IrregularEventCreationViewController: UIViewController {
    
    var trackersViewController: TrackerActionProtocol?
    
    private let cellReuseIdentifier = "habitCell"
    private var selectedCategory = "Домашний уют"
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новое нерегулярное событие"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.addPadding(16)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.becomeFirstResponder()
        return textField
    }()
    
    private lazy var trackersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonDidTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutAndConstraints()
        setupTableView()
        setupTextField()
    }
    
    @objc
    private func cancelButtonDidTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func createButtonDidTapped() {
        guard let text = trackerNameTextField.text, !text.isEmpty else { return }
        let newTracker = Tracker(id: UUID(), name: text, emoji: "🤡", schedule: nil, color: .ypColorSelection2, createdDate: Date())
        trackersViewController?.add(tracker: newTracker)
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    private func setupLayoutAndConstraints() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(header)
        view.addSubview(trackerNameTextField)
        view.addSubview(trackersTableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            trackerNameTextField.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 75),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width/2) - 4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.frame.width/2) + 4)
        ])
    }
    
    private func setupTableView() {
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(HabitTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    private func setupTextField() {
        trackerNameTextField.delegate = self
    }
    
    private func updateCreateButtonState() {
        let isTextFieldEmpty = trackerNameTextField.text?.isEmpty ?? true
        
        let isEnabled = !isTextFieldEmpty
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
}

extension IrregularEventCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - Category
    }
}

extension IrregularEventCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? HabitTableViewCell else { return UITableViewCell()}
        
        if let row = HabitRow(rawValue: indexPath.row) {
            switch row {
            case .category:
                cell.configure(title: "Категория", subtitle: selectedCategory)
            default:
                cell.configure(title: "", subtitle: "")
            }
        } else {
            cell.title.text = "Новая строка" // при добавлении новых критериев
        }
        
        return cell
    }
}

extension IrregularEventCreationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



