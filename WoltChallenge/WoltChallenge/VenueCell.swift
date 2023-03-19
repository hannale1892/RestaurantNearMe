//
//  VenueCell.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 21.1.2023.
//

import UIKit
import CoreLocation
import MapKit

class VenueCell: UITableViewCell {
    var userLocation: CLLocation?
    let distanceFormatter: MKDistanceFormatter = {
        let distance = MKDistanceFormatter()
        distance.units = .metric
        return distance
    }()

    
    @IBOutlet weak var venueImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionlLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet var favouriteButton: UIButton!
    
    var item: Sections.Item! {
        didSet {
            nameLabel.text = item.venueName
            descriptionlLabel.text = item.venueShortDescrition
            
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
            
            guard let userLocation = userLocation else {
                distanceLabel.text = nil
                return
            }
            let distance = item.locationCoordinate.distance(from: userLocation)
            let formattedDistance = self.distanceFormatter.string(fromDistance: distance)
            distanceLabel?.text = formattedDistance
        }
    }
    
    
    @IBAction func toggleIsFavourite(_sender: UIButton) {
        item.isFavourite.toggle()
        let image = item.isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favouriteButton.setImage(image, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
