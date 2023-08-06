//
//  SequenceExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 8/6/23.
//

import Foundation


extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
