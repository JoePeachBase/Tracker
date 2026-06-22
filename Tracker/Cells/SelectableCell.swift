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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Полный сброс перед переиспользованием
        resetCells()
    }
    
    func configure(with content: SelectableCellContent) {
        resetCells()
        
        switch content {
        case .emoji(let string):
            emojiLabel.isHidden = false
            emojiLabel.text = string
        case .color(let color):
            emojiLabel.isHidden = true
            colorImageView.isHidden = false
            colorImageView.backgroundColor = color
        }
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            if let existingColor = colorImageView.backgroundColor {
                layer.cornerRadius = 12
                layer.borderWidth = 3
                layer.borderColor = existingColor.withAlphaComponent(0.3).cgColor
            } else {
                layer.cornerRadius = 16
                layer.backgroundColor = UIColor.ypLightGray.cgColor
            }
            
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
    
    private func resetCells() {
        emojiLabel.isHidden = true
        emojiLabel.text = nil
        colorImageView.isHidden = true
        colorImageView.backgroundColor = nil
        backgroundColor = .clear
        layer.borderWidth = 0
        layer.borderColor = nil
        layer.backgroundColor = nil
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
}

enum SelectableCellContent {
    case emoji(String)
    case color(UIColor)
}
