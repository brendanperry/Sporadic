//
//  CKAssetExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 9/2/22.
//

import Foundation
import CloudKit
import SwiftUI

extension CKAsset {
    func toUIImage() -> UIImage? {
        guard let url = self.fileURL else {
            return nil
        }
        
        if let data = NSData(contentsOf: url) {
            return UIImage(data: data as Data)
        }
        
        return nil
    }
}
