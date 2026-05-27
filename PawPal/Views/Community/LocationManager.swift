//
//  LocationManager.swift
//  PawPal
//
//  Created by Juan Zavala on 8/05/25.
//
//  Contributors:
//  Luis Valadez last updated on 5/20/26.
//

import Foundation
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var addressString = ""
    @Published var locationError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // Requests "When In Use" authorization and begins updating location.
    func requestLocationPermission() {
        locationError = nil

                switch manager.authorizationStatus {
                case .notDetermined:
                    manager.requestWhenInUseAuthorization()

                case .authorizedWhenInUse, .authorizedAlways:
                    manager.requestLocation()

                case .denied, .restricted:
                    locationError = "Location permission is denied."

                @unknown default:
                    locationError = "Unknown location permission status."
                }
    }

    // Called whenever authorization changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            
        case .denied, .restricted:
                    locationError = "Location permission is denied."
            
        default:
            break
        }
    }

    // Called with new location updates.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }

        location = latestLocation
        reverseGeocode(location: latestLocation)
    }

    // Called when CoreLocation encounters an error.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
        print("Location error:", error.localizedDescription)
    }
    
    private func reverseGeocode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                Task { @MainActor in
                    self.locationError = error.localizedDescription
                }
                return
            }

            guard let placemark = placemarks?.first else { return }

            let address = [
                placemark.name,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode
            ]
            .compactMap { $0 }
            .joined(separator: ", ")

            Task { @MainActor in
                self.addressString = address
            }
        }
    }
}


