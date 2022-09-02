//
//  UIImageExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import UIKit
import CloudKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func toCKAsset(name: String? = nil) -> CKAsset? {
        guard let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }

        guard let imageFilePath = NSURL(fileURLWithPath: documentDirectory)
                .appendingPathComponent(name ?? "asset#\(UUID.init().uuidString)")
        else {
            return nil
        }

        do {
            try self.pngData()?.write(to: imageFilePath)
            return CKAsset(fileURL: imageFilePath)
        } catch {
            print("Error converting UIImage to CKAsset!")
        }

        return nil
    }
}
