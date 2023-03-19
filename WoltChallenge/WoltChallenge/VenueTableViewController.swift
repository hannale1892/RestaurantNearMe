//
//  VenueTableViewController.swift
//  RestaurantNearMe
//
//  Created by Hang Le on 21.1.2023.
//
import UIKit
import CoreLocation


class VenueTableViewController: UITableViewController {
    var items: [Sections.Item] = []

    enum Section { case all }
    lazy var dataSource = configureDataSource()
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    @IBAction func mapButtonTapped(_ sender: Any) {
    }

    
    @IBSegueAction func showVenueDetailView(_ coder: NSCoder) -> VenueDetailViewController? {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let item = dataSource.itemIdentifier(for: indexPath)
            else {
                fatalError("Nothing selected!")
            }
        return VenueDetailViewController(coder: coder, item: item)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
        }
        navigationController?.hidesBarsOnSwipe = true

        checkLocationAuthorization()
        checkLocationServices()
        
//        venueInfoController.fetchVenueInfo { (result) in
//            switch result {
//            case .success (let items):
//                OperationQueue.main.addOperation({ [self] in
//                    guard let userLocation = userLocation else {
//                        self.updateSnapshot(items: items)
//                        return
//                    }
//                    let sortedItems = items.sorted(by: {$0.locationCoordinate.distance(from: userLocation) < $1.locationCoordinate.distance(from: userLocation)})
//                    self.updateSnapshot(items: sortedItems)
//                })
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: - Configue TableView
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, Sections.Item> {
        let cellIdentifier = "VenueCell"
        let dataSource = UITableViewDiffableDataSource<Section, Sections.Item> (tableView: tableView, cellProvider: { [self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! VenueCell
            if let userLocation = self.userLocation {
                cell.userLocation = userLocation
            }
            cell.item = item
            return cell
        })
        return dataSource
    }
    
    func updateSnapshot(animatingChange: Bool = false, items: [Sections.Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Sections.Item>()
        snapshot.appendSections([.all])
        snapshot.appendItems(items, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }
}

// MARK: - CLLocation
extension VenueTableViewController: CLLocationManagerDelegate {
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
            getUserCoordinates()
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


    func getUserCoordinates() {
        if let coordinates = locationManager.location?.coordinate {
            print("Latitude: \(coordinates.latitude), Longitude: \(coordinates.longitude)")
            NetworkRequest.shared.fetchVenueData(location: coordinates) { (data) in
                DispatchQueue.main.async {
                    guard let userLocation = self.userLocation else {
                        self.updateSnapshot(items: data)
                        return
                    }
                    let sortedItems = data.sorted(by: {$0.locationCoordinate.distance(from: userLocation) < $1.locationCoordinate.distance(from: userLocation)})
                    self.updateSnapshot(items: sortedItems)
                }
            } onError: {errorMessage in
                print(errorMessage)
            }
        } else {
             print("unable to get coordinates")
        }
    }



    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty {
            userLocation = locations.last
            locationManager.stopUpdatingLocation()
            tableView.reloadData()
        }
    }


}
