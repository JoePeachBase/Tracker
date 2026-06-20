//
//  HabitCreationBaseViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 21.06.2026.
//

import UIKit

class TrackerCreationBaseViewController: UIViewController {

    var trackersViewController: TrackerActionProtocol?

    // MARK: - Переопределяется в наследниках

    var headerTitle: String { "" }
    var tableViewHeight: CGFloat { 75 }
    var scheduleForNewTracker: [WeekDay]? { nil }

    func configureCell(_ cell: HabitTableViewCell, at indexPath: IndexPath) {}
    func handleRowSelection(at indexPath: IndexPath) {}
    func additionalCreateButtonValidation() -> Bool { true }

    // MARK: - Общие свойства

    let cellReuseIdentifier = "habitCell"
    var selectedCategory = "Домашний уют"
    var selectedEmojiIndex: Int? = nil
    var selectedColorIndex: Int? = nil

    let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]

    let colors: [UIColor] = [
        .ypColorSelection1, .ypColorSelection2, .ypColorSelection3,
        .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
        .ypColorSelection7, .ypColorSelection8, .ypColorSelection9,
        .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
        .ypColorSelection13, .ypColorSelection14, .ypColorSelection15,
        .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]

    var selectedEmoji: String? {
        guard let index = selectedEmojiIndex else { return nil }
        return emojis[index]
    }

    var selectedColor: UIColor? {
        guard let index = selectedColorIndex else { return nil }
        return colors[index]
    }

    private lazy var charLabelHeightConstraint: NSLayoutConstraint = {
        charLimitsLabel.heightAnchor.constraint(equalToConstant: 0)
    }()

    lazy var header: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var trackerNameTextField: UITextField = {
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

    lazy var charLimitsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.isHidden = true
        return label
    }()

    lazy var trackersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        return tableView
    }()

    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    lazy var cancelButton: UIButton = {
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

    lazy var createButton: UIButton = {
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
        header.text = headerTitle
        setupLayoutAndConstraints()
        setupTableView()
        setupTextField()
        setupCollectionView()
    }

    @objc private func cancelButtonDidTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonDidTapped() {
        guard let text = trackerNameTextField.text, !text.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor
        else { return }

        let newTracker = Tracker(
            id: UUID(),
            name: text,
            emoji: emoji,
            schedule: scheduleForNewTracker,
            color: color,
            createdDate: Date()
        )
        trackersViewController?.add(tracker: newTracker)
        trackersViewController?.reload()
        view.window?.rootViewController?.dismiss(animated: true)
    }

    func updateCreateButtonState() {
        let isEnabled = !(trackerNameTextField.text?.isEmpty ?? true)
            && selectedEmojiIndex != nil
            && selectedColorIndex != nil
            && additionalCreateButtonValidation()
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }

    private func setupLayoutAndConstraints() {
        view.backgroundColor = .ypWhite
        collectionView.isScrollEnabled = false

        view.addSubview(header)
        view.addSubview(scrollView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        scrollView.addSubview(contentView)

        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(charLimitsLabel)
        contentView.addSubview(trackersTableView)
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),

            charLimitsLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
            charLimitsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            trackersTableView.topAnchor.constraint(equalTo: charLimitsLabel.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: tableViewHeight),

            collectionView.topAnchor.constraint(equalTo: trackersTableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500),

            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        charLabelHeightConstraint.isActive = true
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectableCell.self, forCellWithReuseIdentifier: "selectableCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 19)
        collectionView.allowsMultipleSelection = false
    }

    private func setupTableView() {
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(HabitTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    private func setupTextField() {
        trackerNameTextField.delegate = self
    }
}

extension TrackerCreationBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleRowSelection(at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        guard !isLast else { return }
        let separator = UIView(frame: CGRect(x: 16, y: cell.frame.height - 1, width: tableView.bounds.width - 32, height: 1))
        separator.backgroundColor = .ypGray
        cell.addSubview(separator)
    }
}

extension TrackerCreationBaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Int(tableViewHeight / 75) // 149 → 2 строки, 75 → 1 строка
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? HabitTableViewCell
        else { return UITableViewCell() }
        configureCell(cell, at: indexPath)
        return cell
    }
}

extension TrackerCreationBaseViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        let isOverLimit = updatedText.count >= 38
        charLimitsLabel.isHidden = !isOverLimit
        charLabelHeightConstraint.constant = isOverLimit ? 22 : 0

        return updatedText.count <= 38
    }
}

extension TrackerCreationBaseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView
        else { return UICollectionReusableView() }
        switch indexPath.section {
        case 0: view.titleLabel.text = "Emoji"
        case 1: view.titleLabel.text = "Цвет"
        default: view.titleLabel.text = ""
        }
        return view
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let old = selectedEmojiIndex
            selectedEmojiIndex = indexPath.item
            var toReload = old.map { [IndexPath(item: $0, section: 0)] } ?? []
            toReload.append(indexPath)
            collectionView.reloadItems(at: toReload)
        case 1:
            let old = selectedColorIndex
            selectedColorIndex = indexPath.item
            var toReload = old.map { [IndexPath(item: $0, section: 1)] } ?? []
            toReload.append(indexPath)
            collectionView.reloadItems(at: toReload)
        default: break
        }
        updateCreateButtonState()
    }
}

extension TrackerCreationBaseViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return emojis.count
        case 1: return colors.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectableCell", for: indexPath) as? SelectableCell
        else { return UICollectionViewCell() }
        switch indexPath.section {
        case 0:
            cell.configure(with: .emoji(emojis[indexPath.item]))
            cell.setSelected(selectedEmojiIndex == indexPath.item)
        case 1:
            cell.configure(with: .color(colors[indexPath.item]))
            cell.setSelected(selectedColorIndex == indexPath.item)
        default: break
        }
        return cell
    }
}

extension TrackerCreationBaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 5
        let totalSpacing = spacing * (itemsPerRow - 1)
        let width = (collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 5 }
}
