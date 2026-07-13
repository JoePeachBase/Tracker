//
//  HabitCategoryViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

final class HabitCategoryViewController: UIViewController {

    var onCategorySelected: ((String) -> Void)?

    private let viewModel: CategoryListViewModel
    private let separatorTag = 999
    
    private lazy var tableViewHeightConstraint = categoryTableView.heightAnchor.constraint(equalToConstant: 75)
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()

    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyScreenImage = UIImageView()
        emptyScreenImage.image = .emptyScreen
        emptyScreenImage.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyScreenText = UILabel()
        emptyScreenText.text = "Привычки и события можно\nобъединить по смыслу"
        emptyScreenText.numberOfLines = 0
        emptyScreenText.textAlignment = .center
        emptyScreenText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyScreenText.textColor = .ypBlack
        emptyScreenText.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenText)
        
        NSLayoutConstraint.activate([
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()

    init(categoryStore: TrackerCategoryStore, selectedCategory: String?) {
        self.viewModel = CategoryListViewModel(store: categoryStore, selectedTitle: selectedCategory)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupLayoutAndConstraints()
        bindViewModel()
        updateTableViewHeight()
        updateEmptyState()
    }
    
    @objc
    private func addCategoryTapped() {
        let vc = NewCategoryViewController(mode: .create)
        vc.onDone = { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        present(vc, animated: true)
    }
    
    private func setupLayoutAndConstraints() {
        view.addSubview(header)
        view.addSubview(emptyScreenView)
        view.addSubview(categoryTableView)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            categoryTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeightConstraint,
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
        categoryTableView.isScrollEnabled = false
    }

    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.categoryTableView.reloadData()
            self?.updateTableViewHeight()
            self?.updateEmptyState()
        }
        viewModel.onCategorySelected = { [weak self] title in
            self?.onCategorySelected?(title)
            self?.dismiss(animated: true)
        }
        viewModel.onError = { error in
            print("Ошибка работы с категориями: \(error)")
        }
    }
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 75
        tableViewHeightConstraint.constant = rowHeight * CGFloat(viewModel.cellViewModels.count)
    }

    private func updateEmptyState() {
        emptyScreenView.isHidden = !viewModel.isEmpty
        categoryTableView.isHidden = viewModel.isEmpty
    }
}

extension HabitCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryTableViewCell else { return UITableViewCell() }
        cell.configure(with: viewModel.cellViewModels[indexPath.row])
        return cell
    }
}

extension HabitCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.viewWithTag(separatorTag)?.removeFromSuperview()
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        guard !isLastRow else { return }
        
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .ypGray
        separatorView.tag = separatorTag
        cell.addSubview(separatorView)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            guard let self else { return nil }
            let edit = UIAction(title: "Редактировать") { _ in
                let currentTitle = self.viewModel.cellViewModels[indexPath.row].title
                let vc = NewCategoryViewController(mode: .edit(currentTitle))
                vc.onDone = { newTitle in
                    self.viewModel.renameCategory(at: indexPath.row, newTitle: newTitle)
                }
                self.present(vc, animated: true)
            }
            let delete = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.confirmDelete(at: indexPath.row)
            }
            return UIMenu(children: [edit, delete])
        })
    }

    private func confirmDelete(at index: Int) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(alert, animated: true)
    }
}
