//
//  VenueController.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 11.2.2023.
//

import UIKit

class VenueInfoController {
    
    private var items = [Sections.Item]()
    
    enum VenueInfoError: Error, LocalizedError {
        case itemNotFound
        case imageDataMissing
    }
    
    // MARK: - Fetch Venues
    
    func fetchVenueInfo(completion: @escaping (Result<[Sections.Item], Error>) -> Void) {
        let venueURL = URL(string: "https://restaurant-api.wolt.com/v1/pages/restaurants?lat=64.983323&lon=25.522710")!
// let venueURL = URL(string: "https://restaurant-api.wolt.com/v1/pages/restaurants?lat=60.170187&lon=24.930599")!
        
        let urlRequest = URLRequest(url: venueURL)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let sectionsResponse = try decoder.decode(SectionResponse.self, from: data)
                    completion(.success(sectionsResponse.sections.last!.items))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(VenueInfoError.imageDataMissing))
            }
        }
        task.resume()
    }
    
    
    
}
