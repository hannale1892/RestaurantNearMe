//
//  VenueDetailViewController.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 2.3.2023.
//

import Foundation
import UIKit
import CoreLocation

class VenueDetailViewController: UITableViewController {
    var item: Sections.Item!
    
    @IBOutlet var venueImageView: UIImageView!
    @IBOutlet var venueNameLabel: UILabel!
    @IBOutlet var venueShortDescription: UILabel!
    @IBOutlet var venueAddress: UILabel!
    @IBOutlet var venueCity: UILabel!
    @IBOutlet var venuePostalCode: UILabel!
    @IBOutlet var venueScore: UILabel!
    
    @IBSegueAction func showSingleVenueMapView(_ coder: NSCoder) -> VenueMapViewController? {
        return VenueMapViewController(coder: coder, item: item)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        navigationController?.isNavigationBarHidden = false
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        navigationItem.title = item.venueName
        venueNameLabel.text = item.venueName
        venueShortDescription.text = item.venueShortDescrition
        venueAddress.text = item.venueAddress
        
        let evaluation = evaluatedScore(score: item.venueScore)
        if let venueScore = item.venueScore {
            self.venueScore.text = "\(venueScore) \(evaluation)"
        } else {
            self.venueScore.text = "Not rated yet"
        }
        
        self.getVenueCity(location: item.locationCoordinate) { placemark in
            guard let placemark = placemark else { return }
            if let city = placemark.locality {
                self.venueCity.text =  "\(city)"
            }
            if let postalCode = placemark.postalCode {
                self.venuePostalCode.text = "\(postalCode),"
            }
        }
        
        NetworkRequest.shared.fetchImage(from: item.venueImageUrl!) { (result) in
            DispatchQueue.main.async {
                switch result {
                case.success(let image):
                    self.venueImageView.image = image
                case .failure(let error):
                    self.venueImageView.image = UIImage(systemName: "photo.fill")
                    print("Error fetching image: \(error)")
                }
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func evaluatedScore(score: Double?) -> String {
        let goodRange = 5.0..<7.5
        let veryGoodRange = 7.5..<8.5
        let excellentRange = 8.5...10.0
        if score == nil {
            return " "
        } else if excellentRange.contains(score!) {
            return "Excellent"
        } else if veryGoodRange.contains(score!) {
            return "Very Good"
        } else if goodRange.contains(score!)  {
            return "Good"
        } else {
            return "Average"
        }
    }
    
    func getVenueCity(location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            completion(placemark)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("This should never be called!")
    }
    
    init?(coder: NSCoder, item: Sections.Item) {
        self.item = item
        super.init(coder: coder)
    }
}
