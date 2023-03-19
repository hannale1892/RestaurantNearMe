//
//  Venue.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 19.1.2023.
//

import Foundation
import CoreLocation
import UIKit

struct Sections: Hashable, Codable {
    var items: [Item]
    let title: String
    let name: String
    
    struct Item: Hashable, Codable {
        var venueImageUrl: URL?
        var venueName: String = ""
        var venueId: String = ""
        var venueShortDescrition: String = ""
        var venueAddress: String = ""
        var isFavourite: Bool = false
        var venueScore: Double?
        
        
        var venueCoordinates: [Double] = []
        var locationCoordinate2D: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: venueCoordinates[1], longitude: venueCoordinates[0])
        }
        
        var locationCoordinate: CLLocation {
            CLLocation(latitude: venueCoordinates[1], longitude: venueCoordinates[0])
        }
        
        private enum ItemKeys: String, CodingKey {
            case venue
            case image
        }
        
        private enum ImageKeys: String, CodingKey {
            case url
        }

        private enum VenueKeys: String, CodingKey {
            case venueName = "name"
            case venueId = "id"
            case venueShortDescrition = "short_description"
            case venueAdress = "address"
            case venueCoordinates = "location"
            case venueRating = "rating"
        }
        
        private enum RatingKeys: String, CodingKey {
            case score
        }
        
        init(from decoder: Decoder) throws {
            if let itemContainer = try? decoder.container(keyedBy: ItemKeys.self) {
                
                if let venueContainer = try? itemContainer.nestedContainer(keyedBy: VenueKeys.self, forKey: .venue) {
                    let rawVenueId = try? venueContainer.decode(String.self, forKey: .venueId)
                    let rawVenueName = try? venueContainer.decode(String.self, forKey: .venueName)
                    let rawVenueShortDescription = try? venueContainer.decode(String.self, forKey: .venueShortDescrition)
                    let rawVenueAddress = try? venueContainer.decode(String.self, forKey: .venueAdress)
                    let rawVenueCoordinates = try? venueContainer.decode([Double].self, forKey: .venueCoordinates)
                    
                    if let ratingContainer = try? venueContainer.nestedContainer(keyedBy: RatingKeys.self, forKey: .venueRating) {
                        let rawVenueScore = try? ratingContainer.decode(Double.self, forKey: .score)
                        
                        guard let venueScore = rawVenueScore
                        else {
                            throw VenueError.missingData
                        }
                        self.venueScore = venueScore
                    }

                    
                    guard let venueId = rawVenueId,
                          let venueName = rawVenueName,
                          let venueShortDescription = rawVenueShortDescription,
                          let venueAddress = rawVenueAddress,
                          let venueCoordinates = rawVenueCoordinates
                    else {
                        throw VenueError.missingData
                    }
                    
                    self.venueId = venueId
                    self.venueName = venueName
                    self.venueShortDescrition = venueShortDescription
                    self.venueAddress = venueAddress
                    self.venueCoordinates = venueCoordinates
                }
                
                
                if let imageContainer = try? itemContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .image) {
                    let rawVenueImageUrl = try? imageContainer.decode(URL.self, forKey: .url)
                    
                    guard let venueImageUrl = rawVenueImageUrl
                    else {
                        throw VenueError.missingData
                    }
                    self.venueImageUrl = venueImageUrl
                }
          

            } //itemContainer
            
        }

    }
}


struct SectionResponse: Codable {
    let sections: [Sections]
}


// MARK: - Original Venue
//struct Sections: Hashable, Codable {
//    var items: [Item]
//    let title: String
//    let name: String
//
//    struct Item: Hashable, Codable {
//        var venueImageUrl: URL?
//        var venueName: String = ""
//        var venueId: String = ""
//        var venueShortDescrition: String = ""
//        var isFavourite: Bool = false
//
//        var venueCoordinates: [Double] = []
//        var locationCoordinate2D: CLLocationCoordinate2D {
//            CLLocationCoordinate2D(latitude: venueCoordinates[1], longitude: venueCoordinates[0])
//        }
//
//        var locationCoordinate: CLLocation {
//            CLLocation(latitude: venueCoordinates[1], longitude: venueCoordinates[0])
//        }
//
//
//        private enum ImageKeys: String, CodingKey {
//            case url
//        }
//        private enum ItemKeys: String, CodingKey {
//            case venue
//            case image
//        }
//        private enum VenueKeys: String, CodingKey {
//            case venueName = "name"
//            case venueId = "id"
//            case venueShortDescrition = "short_description"
//            case venueCoordinates = "location"
//        }
//
//        init(from decoder: Decoder) throws {
//            if let itemContainer = try? decoder.container(keyedBy: ItemKeys.self) {
//
//                if let venueContainer = try? itemContainer.nestedContainer(keyedBy: VenueKeys.self, forKey: .venue) {
//                    self.venueId = try venueContainer.decode(String.self, forKey: .venueId)
//                    self.venueName = try venueContainer.decode(String.self, forKey: .venueName)
//                    self.venueShortDescrition = try venueContainer.decode(String.self, forKey: .venueShortDescrition)
//                    self.venueCoordinates = try venueContainer.decode([Double].self, forKey: .venueCoordinates)
//                }
//
//
//                if let imageContainer = try? itemContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .image) {
//                    self.venueImageUrl = try imageContainer.decode(URL.self, forKey: .url)
//
//                }
//            }
//
//        }
//
//    }
//}
//struct SectionResponse: Codable {
//    let sections: [Sections]
//}

