//
//  GlobalSettings.swift
//  Sporadic
//
//  Created by Brendan Perry on 3/4/23.
//

import Foundation

public struct GlobalSettings {
    static var shared = GlobalSettings()
    
    public let controlCornerRadius = 12.0
    public let controlSpacing = 50.0
    public let shadowRadius = 3.0
    public var swipeToGoBackEnabled = true
    
    private init() { }
}
