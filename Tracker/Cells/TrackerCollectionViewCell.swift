//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    var onCounterTaped: (() -> Void)?
    
    var tracker: Tracker? {
        didSet {
            trackerTitle.text = tracker?.name
            emoji.text = tracker?.emoji
            trackerBackGroundView.backgroundColor = tracker?.color
            trackerCounterButton.backgroundColor = tracker?.color
        }
    }
    
    var completedTracker = false
    
    lazy var trackerBackGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    lazy var trackerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        return label
    }()
    
    lazy var emoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var emojiBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1, alpha:  0.3)
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var daysPassedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var trackerCounterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(trackerCounterDidTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(tracker: Tracker, isCompleted: Bool, daysCount: Int) {
        self.tracker = tracker
        completedTracker = isCompleted
        daysPassedLabel.text = "\(daysCount) дней"
        updateButtonState()
    }
    
    @objc
    private func trackerCounterDidTapped() {
        onCounterTaped?()
    }
    
    private func setupLayoutAndConstraints() {
        contentView.addSubview(trackerBackGroundView)
        trackerBackGroundView.addSubview(trackerTitle)
        trackerBackGroundView.addSubview(emojiBackground)
        emojiBackground.addSubview(emoji)
        contentView.addSubview(daysPassedLabel)
        contentView.addSubview(trackerCounterButton)
        
        NSLayoutConstraint.activate([
            trackerBackGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerBackGroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerBackGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerBackGroundView.heightAnchor.constraint(equalToConstant: 90),
            
            trackerTitle.leadingAnchor.constraint(equalTo: trackerBackGroundView.leadingAnchor, constant: 12),
            trackerTitle.topAnchor.constraint(greaterThanOrEqualTo: emojiBackground.bottomAnchor, constant: 4),
            trackerTitle.trailingAnchor.constraint(equalTo: trackerBackGroundView.trailingAnchor, constant: -12),
            trackerTitle.bottomAnchor.constraint(equalTo: trackerBackGroundView.bottomAnchor, constant: -12),
            
            emojiBackground.leadingAnchor.constraint(equalTo: trackerBackGroundView.leadingAnchor, constant: 12),
            emojiBackground.topAnchor.constraint(equalTo: trackerBackGroundView.topAnchor, constant: 12),
            emojiBackground.heightAnchor.constraint(equalToConstant: 30),
            emojiBackground.widthAnchor.constraint(equalToConstant: 30),
            
            emoji.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            daysPassedLabel.topAnchor.constraint(equalTo: trackerBackGroundView.bottomAnchor, constant: 16),
            daysPassedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            trackerCounterButton.topAnchor.constraint(equalTo: trackerBackGroundView.bottomAnchor, constant: 8),
            trackerCounterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerCounterButton.heightAnchor.constraint(equalToConstant: 34),
            trackerCounterButton.widthAnchor.constraint(equalToConstant: 34)
        ])
        updateButtonState()
    }
    
    private func updateButtonState() {
        switch completedTracker {
        case true:
            trackerCounterButton.setImage(UIImage(named: "Checkmark"), for: .normal)
            trackerCounterButton.alpha = 0.3
            trackerCounterButton.tintColor = .ypWhite
        case false:
            trackerCounterButton.setImage(UIImage(systemName: "plus"), for: .normal)
            trackerCounterButton.alpha = 1
            trackerCounterButton.tintColor = .ypWhite
        }
    }
}
