//
//  UINavigationControllerExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/3/22.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if GlobalSettings.shared.swipeToGoBackEnabled {
            return viewControllers.count > 1
        }
        else {
            return false
        }
    }
}
