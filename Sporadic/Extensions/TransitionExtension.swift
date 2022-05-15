//
//  TransitionExtension.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/14/22.
//

import SwiftUI

extension AnyTransition {
    static var backslide: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))}
}
