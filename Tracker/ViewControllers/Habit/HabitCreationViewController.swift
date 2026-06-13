//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

protocol TrackerActionProtocol {
    func add(tracker: Tracker)
    func reload()
}

final class HabitCreationViewController: UIViewController {
    
    var trackersViewController: TrackerActionProtocol?
    
    private let cellReuseIdentifier = "habitCell"
    private var selectedCategory = "Домашний уют" // Mock
    private var selectedDays: [WeekDay] = []
    private let scrollView = UIScrollView()
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private let colors: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3,
        .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9,
        .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15,
        .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]
    
    private lazy var charLabelHeightConstraint: NSLayoutConstraint = {
        charLimitsLabel.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новая привычка"
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
    
    private lazy var charLimitsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.isHidden = true
        return label
    }()
    
    private lazy var trackersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        setupLayoutAndConstraints()
        setupTableView()
        setupTextField()
        setupCollectionView()
    }
    
    @objc
    private func cancelButtonDidTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func createButtonDidTapped() {
        guard let text = trackerNameTextField.text, !text.isEmpty else { return }
        let newTracker = Tracker(id: UUID(), name: text, emoji: "🤡", schedule: selectedDays, color: .ypColorSelection1, createdDate: Date())
        trackersViewController?.add(tracker: newTracker)
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    private func setupLayoutAndConstraints() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(header)
        view.addSubview(trackerNameTextField)
        view.addSubview(charLimitsLabel)
        view.addSubview(trackersTableView)
        view.addSubview(collectionView)
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
            
            charLimitsLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            charLimitsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackersTableView.topAnchor.constraint(equalTo: charLimitsLabel.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 149),
            
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: trackersTableView.bottomAnchor, constant: 32),
            collectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width/2) - 4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.frame.width/2) + 4),
        ])
        charLabelHeightConstraint.isActive = true
    }
    
    private func setupCollectionView() {
//        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectableCell.self, forCellWithReuseIdentifier: "selectableCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 19)
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
        let isSelectedDaysEmpty = selectedDays.isEmpty
        
        let isEnabled = !isTextFieldEmpty && !isSelectedDaysEmpty
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
}

extension HabitCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = HabitRow(rawValue: indexPath.row) {
            switch row {
            case .category:
                // TODO: - Category
                return
            case .schedule:
                let vc = HabitScheduleViewController()
                vc.selectedDays = selectedDays
                vc.onScheduleSelected = { [weak self] days in
                    guard let self else { return }
                    self.selectedDays = days
                    self.trackersTableView.reloadRows(
                        at: [IndexPath(row: HabitRow.schedule.rawValue, section: 0)],
                        with: .none)
                    self.updateCreateButtonState()
                }
                present(vc, animated: true)
            }
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .ypGray
        cell.addSubview(separatorView)
    }
}

extension HabitCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? HabitTableViewCell else { return UITableViewCell()}
        
        if let row = HabitRow(rawValue: indexPath.row) {
            switch row {
            case .category:
                cell.configure(title: "Категория", subtitle: selectedCategory)
            case .schedule:
                let subtitle = selectedDays.isEmpty ? nil :
                selectedDays.sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortTitle }
                    .joined(separator: ", ")
                cell.configure(title: "Расписание", subtitle: subtitle)
            }
        } else {
            cell.title.text = "Новая строка" // при добавлении новых критериев
        }
        
        return cell
    }
}

extension HabitCreationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        // Формируем новый текст после предполагаемого изменения
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Лимит символов
        let limit = 38
        let isOverLimit = updatedText.count >= limit
        
        charLimitsLabel.isHidden = !isOverLimit
        charLabelHeightConstraint.constant = isOverLimit ? 22 : 0
        
        // Разрешаем изменение, только если длина нового текста не превышает лимит
        return updatedText.count <= limit
        
    }
}

extension HabitCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else { return UICollectionReusableView()}
        
        switch indexPath.section {
        case 0: view.titleLabel.text = "Emoji"
        case 1: view.titleLabel.text = "Цвет"
        default: view.titleLabel.text = ""
        }
        
        return view
    }
}

extension HabitCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectableCell", for: indexPath) as? SelectableCell else { return UICollectionViewCell()}
        
        switch indexPath.section {
        case 0: cell.configure(with: .emoji(emojis[indexPath.item]))
        case 1: cell.configure(with: .color(colors[indexPath.item]))
        default: break
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return emojis.count
        case 1: return colors.count
        default: return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
}

extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 5
        let totalSpacing = spacing * (itemsPerRow - 1)
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right) - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}
