//
//  VenueError.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 26.2.2023.
//

import Foundation

enum VenueError: Error {
    case missingData
}

extension VenueError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingData:
            return NSLocalizedString("Found and will discard a venue missing a valid code.", comment: "")
        }
    }
}
