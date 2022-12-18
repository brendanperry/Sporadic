//
//  CustomError.swift
//  Sporadic
//
//  Created by Brendan Perry on 12/17/22.
//

import Foundation


enum CustomError: Error {
    case alreadyInGroup, groupNotFound, connectionError
    
    var description: String {
        switch self {
        case .alreadyInGroup:
            return "You are already in this group!"
        case .groupNotFound:
            return "Group not found."
        case .connectionError:
            return "Operation failed. Please check your connection and try again!"
        }
    }
}
