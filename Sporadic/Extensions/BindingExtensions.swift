//
//  BindingExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 8/6/23.
//

import SwiftUI


extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(limit))
            }
        }
        return self
    }
}
