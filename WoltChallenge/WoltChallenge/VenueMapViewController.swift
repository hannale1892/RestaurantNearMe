//
//  VenueMapViewController.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 17.3.2023.
//

import UIKit
import MapKit
import CoreLocation

class VenueMapViewController: UIViewController {
    var item: Sections.Item!
    let locationManager = CLLocationManager()

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        render()
        createAnnotations(item: item)
    }
    
    func render() {
        let coordinate = CLLocationCoordinate2D(latitude: item.locationCoordinate2D.latitude, longitude: item.locationCoordinate2D.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("This should never be called!")
    }

    init?(coder: NSCoder, item: Sections.Item) {
        self.item = item
        super.init(coder: coder)
    }
    
}

extension VenueMapViewController: MKMapViewDelegate {
    func createAnnotations(item: Sections.Item) {
            let annotation = MKPointAnnotation()
            annotation.title = item.venueName
            annotation.coordinate = CLLocationCoordinate2D(latitude: item.locationCoordinate2D.latitude, longitude: item.locationCoordinate2D.longitude)
            mapView.addAnnotation(annotation)
    }
}
