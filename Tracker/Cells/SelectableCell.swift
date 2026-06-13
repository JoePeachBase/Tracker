//
//  TrackerCustomizationCollectionViewCell.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 11.06.2026.
//

import UIKit

final class SelectableCell: UICollectionViewCell {
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private lazy var colorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayoutAndConstraints() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(colorImageView)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorImageView.heightAnchor.constraint(equalToConstant: 40),
            colorImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with content: SelectableCellContent) {
        switch content {
        case .emoji(let string):
            emojiLabel.isHidden = false
            emojiLabel.text = string
        case .color(let color):
            emojiLabel.isHidden = true
            colorImageView.backgroundColor = color
        }
    }
}

enum SelectableCellContent {
    case emoji(String)
    case color(UIColor)
}
