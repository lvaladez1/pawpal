//
//  LocationManager.swift
//  PawPal
//
//  Created by Juan Zavala on 8/05/25.
//

import Foundation
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    // Requests "When In Use" authorization and begins updating location.
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // Called whenever authorization changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    // Called with new location updates.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    // Called when CoreLocation encounters an error.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}


