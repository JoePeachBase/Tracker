//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 07.07.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {

    enum Mode {
        case create
        case edit(String)
    }

    var onDone: ((String) -> Void)?

    private let mode: Mode
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "category.name.placeholder".localized
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.addPadding(16)
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("done.button".localized, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .create:
            header.text = "new.category".localized
            updateButtonState()
        case .edit(let title):
            header.text = "edit.category".localized
            textField.text = title
            updateButtonState()
        }
        
        setupLayoutAndConstraints()
    }

    @objc
    private func textChanged() {
        updateButtonState()
    }
    
    @objc
    private func doneButtonTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        onDone?(text)
        dismiss(animated: true)
    }
    
    private func setupLayoutAndConstraints() {
        view.backgroundColor = .ypWhite
        view.addSubview(header)
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func updateButtonState() {
        let isEnabled = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        doneButton.isEnabled = isEnabled
        doneButton.setTitleColor(isEnabled ? .ypWhite : .ypWhiteNight, for: .normal)
        doneButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
