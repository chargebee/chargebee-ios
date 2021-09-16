//
//  UIView.swift
//  Chargebee_Example
//
//  Created by CB/IT/01/1039 on 09/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {

    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }

    func roundCourners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    /** This helper function will clean up a lot of the UI Code that is being used for setting up all of our anchors for auto-layout.
            1.)  Pass the views constraints you want to constrain to
            2.)  Any padding you want to add to the constraint, use the UIEdgeInsets
            3.) Any fixed width or height you want to use, use the CGSize parameter
     */
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero, size: CGSize = .zero) {

        // Enables auto-layout
        translatesAutoresizingMaskIntoConstraints = false
        // Safe unwrap the rest of the anchors and only activate if provided
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }

        // Check if any of the height/width sizes are not 0 (size was explicitly defined when called), so set those anchors
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
