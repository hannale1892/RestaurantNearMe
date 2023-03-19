//
//  NetworkRequest.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 22.2.2023.
//

import CoreLocation
import UIKit

typealias OnApiSuccess = ([Sections.Item]) -> Void
typealias OnApiError = (String) -> Void

class NetworkRequest {
    static let shared = NetworkRequest()
    let session = URLSession(configuration: .default)

    func fetchVenueData(location: CLLocationCoordinate2D, onSuccess: @escaping OnApiSuccess, onError: @escaping OnApiError){
        let URL_BASE = "https://restaurant-api.wolt.com/v1/pages/restaurants?lat=\(location.latitude)&lon=\(location.longitude)"
        let url = URL(string: "\(URL_BASE)")
        
        /// task constant that starts the actual querying of the endpoint that'll return actual data, a response code and/or an error
        let task = session.dataTask(with: url!) { data, response, error in
            DispatchQueue.main.async {
                /// handle session error
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                /// ensure there is data and a server response
                guard let data = data,
                      let response = response as? HTTPURLResponse else {
                    print("Invalid data or response")
                    return
                }
                do {
                    switch response.statusCode{
                    case 200:
                        let venueData = try JSONDecoder().decode(SectionResponse.self, from: data)
                        onSuccess(venueData.sections.last!.items)
                    default:
                        print("Error 400")
                        onError(error!.localizedDescription)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            }
        }
        task.resume()
    }
    
}
