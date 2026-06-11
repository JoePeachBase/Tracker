//
//  UITextField+padding.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

extension UITextField {
    func addPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
