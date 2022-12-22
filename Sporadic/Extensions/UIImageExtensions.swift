//
//  UIImageExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 1/12/22.
//

import UIKit
import CloudKit
//
//enum ImageFormats {
//    case png
//    case jpeg
//    case gif
//    case tiff
//    case unknown
//    
//    init(byte: UInt8) {
//        switch byte {
//        case 0x89:
//            self = .png
//        case 0xFF:
//            self = .jpeg
//        case 0x47:
//            self = .gif
//        case 0x49, 0x4D:
//            self = .tiff
//        default:
//            self = .unknown
//        }
//    }
//}
//
//extension Data {
//    var imageFormat: ImageFormats{
//        guard let header = map({ $0 as UInt8 })[safe: 0] else {
//            return .unknown
//        }
//        
//        return ImageFormat(byte: header)
//    }
//}

extension Data {
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
            try self.write(to: imageFilePath)
            return CKAsset(fileURL: imageFilePath)
        } catch {
            print("Error converting Data to CKAsset!")
        }

        return nil
    }
}

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
            try self.jpegData(compressionQuality: 0)?.write(to: imageFilePath)
            return CKAsset(fileURL: imageFilePath)
        } catch {
            print("Error converting UIImage to CKAsset!")
        }

        return nil
    }
    
    func orientedUp() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
