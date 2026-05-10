//
//  MapViewController.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modifed by Moe Karaki on 7/18/25.
//  Modified by Juan Zavala on 7/30/25

/*
 *  The current map in LostPetReportView could and should be refactored here in the future. 
 */

//
import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(coordinateRegion: $region)
            .ignoresSafeArea()
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
    }
}
