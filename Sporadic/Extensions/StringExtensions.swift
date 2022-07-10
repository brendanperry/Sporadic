//
//  StringExtensions.swift
//  Sporadic
//
//  Created by Brendan Perry on 6/25/22.
//

import Foundation

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    var containsEmoji: Bool { contains { $0.isEmoji } }
}
