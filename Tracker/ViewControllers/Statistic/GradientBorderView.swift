//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 22.07.2026.
//

import UIKit

final class GradientBorderView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    var cornerRadius: CGFloat = 16 { didSet { setNeedsLayout() } }
    var borderWidth: CGFloat = 1 { didSet { setNeedsLayout() } }

    var colors: [UIColor] = [
        .ypRedGradient,
        .ypGreenGradient,
        .ypBlueGradient
    ] {
        didSet { gradientLayer.colors = colors.map { $0.cgColor } }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func setup() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = colors.map { $0.cgColor }
        layer.addSublayer(gradientLayer)

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
            cornerRadius: cornerRadius
        )
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = borderWidth
    }
}
