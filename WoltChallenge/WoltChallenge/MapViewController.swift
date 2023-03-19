//
//  MapViewController.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 5.2.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    let locationManager = CLLocationManager()

    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorization()
        checkLocationServices()

        mapView.delegate = self
        mapView.showsUserLocation = true
    }
}

// MARK: - Get current location

extension MapViewController: CLLocationManagerDelegate {
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else {
            // Inform the user how to enable location services in iOS Settings
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            fetchVenueCoordinates()
            break
        case .denied:
            // Show an alert instructing user how to turn on permission
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Show an alert instructing user how to turn on permission
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func fetchVenueCoordinates() {
        if let coordinates = locationManager.location?.coordinate {
            print("Latitude: \(coordinates.latitude), Longitude: \(coordinates.longitude)")
            NetworkRequest.shared.fetchVenueData(location: coordinates) { (data) in
                DispatchQueue.main.async {
                    self.createAnnotations(items: data)
                }
            } onError: {errorMessage in
                print(errorMessage)
            }
        } else {
             print("unable to get coordinates")
        }
    }
    
    func createAnnotations(items: [Sections.Item]) {
        for item in items {
            let annotations = MKPointAnnotation()
            annotations.title = item.venueName
            annotations.coordinate = CLLocationCoordinate2D(latitude: item.locationCoordinate2D.latitude, longitude: item.locationCoordinate2D.longitude)
            mapView.addAnnotation(annotations)
        }
    }
    

    
}


//    func presentModal() {
//        let venueTableViewController = VenueTableViewController()
//        let nav = UINavigationController(rootViewController: venueTableViewController)
//        nav.modalPresentationStyle = .pageSheet
//        if let sheet = nav.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.prefersGrabberVisible = true
//        }
//        present(nav, animated: true, completion: nil)
//    }
