//
//  UIImageExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
