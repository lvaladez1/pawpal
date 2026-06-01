//
//  SightingsView.swift
//  PawPal
//
//  Created by Luis V on 5/26/26.
//

import SwiftUI
import FirebaseFirestore
import MapKit
import CoreLocation

struct SightingsView: View {

    @StateObject private var sightingsLocationManager = SightingsLocationManager()
    @StateObject private var searchDelegate = SightingsSearchCompleterDelegate()

    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var locationSearchText = ""
    @State private var showLocationSuggestions = false
    @State private var selectedUserCoordinate: CLLocationCoordinate2D?
    @State private var selectedAnnotation: PetMapAnnotation?

    @State private var sightings: [CommunitySighting] = []
    @State private var missingPets: [MissingPetReport] = []
    @State private var matchedSightings: [MatchedSighting] = []
    @State private var localMissingPets: [MissingPetReport] = []

    @State private var selectedMode = "Map"
    @State private var isLoading = true
    @State private var useLocalLocation = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.6002, longitude: -121.8947),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )

    private let modes = ["Map", "List"]
    private let searchRadiusMiles = 10.0

    // Combines lost pet pins and sighting pins into one annotation list for the map.
    private var mapAnnotations: [PetMapAnnotation] {
        let lostPetPins = localMissingPets.map { PetMapAnnotation.lostPet($0) }

        let sightingPins = matchedSightings.enumerated().map { index, match in
            PetMapAnnotation.sighting(match, displayOffsetIndex: index + 1)
        }

        return lostPetPins + sightingPins
    }

    var body: some View {
        ZStack {
            Color.theme.babyBlueLight
                .ignoresSafeArea()

            VStack(spacing: 12) {

                Picker("View Mode", selection: $selectedMode) {
                    ForEach(modes, id: \.self) { mode in
                        Text(mode == "Map" ? "Map View" : "List View")
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                locationSearchSection

                if selectedMode == "Map" {
                    mapSection
                } else {
                    recentSightingsList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Pet Sightings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupLocationSearch()
            fetchData()
        }
        .onChange(of: sightingsLocationManager.location) { _ in
            if useLocalLocation {
                applyLocalFilter()
            }
        }
    }

    private var locationSearchSection: some View {
        VStack(spacing: 8) {
            TextField("Enter your city, address, or ZIP code", text: $locationSearchText)
                .padding()
                .background(Color.white)
                .cornerRadius(14)
                .padding(.horizontal)
                .onChange(of: locationSearchText) { newValue in
                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    showLocationSuggestions = !trimmed.isEmpty
                    searchCompleter.queryFragment = trimmed
                }

            if showLocationSuggestions && !searchDelegate.results.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchDelegate.results) { result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .onTapGesture {
                            showLocationSuggestions = false
                            searchDelegate.results = []

                            selectSearchCompletion(result.completion)
                        }

                        Divider()
                    }
                }
                .cornerRadius(14)
                .padding(.horizontal)
            }

            Button {
                useCurrentLocation()
            } label: {
                Label("Use My Current Location", systemImage: "location.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
    }

    // MARK: Map display
    // displays both lost pets and sightings.
    private var mapSection: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: mapAnnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button {
                        selectedAnnotation = item
                    } label: {
                        switch item {
                        case .lostPet(let pet):
                            VStack(spacing: 4) {
                                Image(systemName: "pawprint.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(colorForPet(pet))

                                Text(pet.petName)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }

                        case .sighting(let match, _):
                            VStack(spacing: 4) {
                                ZStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(colorForPet(match.missingPet))

                                    Text("\(match.pinNumber)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .offset(y: -3)
                                }

                                Text(String(format: "%.1f mi", match.distanceMiles))
                                    .font(.caption2)
                                    .padding(6)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .ignoresSafeArea(edges: .bottom)

            if let selectedAnnotation {
                selectedAnnotationCard(selectedAnnotation)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Recent Sightings List
    private var recentSightingsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                localMissingPetsSection

                HStack {
                    Text(useLocalLocation ? "Local Sighting Matches" : "Potential Matches")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("\(matchedSightings.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())

                    Spacer()
                }
                .padding(.horizontal)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if matchedSightings.isEmpty {
                    Text("No matching sightings found within 10 miles.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    ForEach(matchedSightings) { match in
                        sightingCard(match)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }

    private var localMissingPetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(useLocalLocation ? "Local Missing Pets" : "Missing Pets")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("\(localMissingPets.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())

                Spacer()
            }

            if localMissingPets.isEmpty && !isLoading {
                Text("No missing pets found within 10 miles.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(localMissingPets) { pet in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Circle()
                                .fill(colorForPet(pet))
                                .frame(width: 12, height: 12)

                            Text(pet.petName)
                                .font(.headline)
                        }

                        Text("\(pet.size) • \(pet.primaryColor)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if !pet.markings.isEmpty && pet.markings != "Unknown" {
                            Text("Markings: \(pet.markings)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: Pin Card Details
    private func selectedAnnotationCard(_ annotation: PetMapAnnotation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                switch annotation {
                case .lostPet(let pet):
                    Text(pet.petName)
                        .font(.headline)

                case .sighting(let match, _):
                    Text("Possible match for \(match.missingPet.petName)")
                        .font(.headline)

                    Spacer()

                    Text(String(format: "%.1f mi", match.distanceMiles))
                        .font(.headline)
                }

                Spacer()

                Button {
                    selectedAnnotation = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            switch annotation {
            // MARK: Details Missing Pet
            case .lostPet(let pet):
                detailItem("Size", pet.size)
                detailItem("Color", pet.primaryColor)
                detailItem("Markings", pet.markings)

            // MARK: Details Possible match
            case .sighting(let match, _):
                let sighting = match.sighting

                confidenceBadge(match.confidenceLevel)
                detailItem("Color", sighting.primaryColor)
                detailItem("Condition", sighting.petCondition)
                detailItem("Markings", sighting.markings)

                if !sighting.locationNotes.isEmpty {
                    Text("Location: \(sighting.locationNotes)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button {
                    openInMaps(sighting)
                } label: {
                    Label("View on Map", systemImage: "map")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 8)
    }

    // MARK: Sighting Card
    private func sightingCard(_ match: MatchedSighting) -> some View {
        let sighting = match.sighting

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(colorForPet(match.missingPet))
                        .frame(width: 34, height: 34)

                    Text("\(match.pinNumber)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Possible match for \(match.missingPet.petName)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    Text(sighting.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)

                    confidenceBadge(match.confidenceLevel)
                }

                Spacer()

                Text(String(format: "%.1f mi", match.distanceMiles))
                    .font(.headline)
            }

            Divider()

            detailItem("Color", sighting.primaryColor)
            detailItem("Condition", sighting.petCondition)
            detailItem("Behavior", sighting.behavior)
            detailItem("Tail Shape", sighting.tailType)
            detailItem("Ears Position", sighting.earType)

            if !sighting.locationNotes.isEmpty {
                Text("Location: \(sighting.locationNotes)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Button {
                openInMaps(sighting)
            } label: {
                Label("View on Map", systemImage: "map")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private func detailItem(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.caption)
                .fontWeight(.semibold)

            Text(value.isEmpty ? "Unknown" : value)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func confidenceBadge(_ confidence: String) -> some View {
        HStack {
            Text("Confidence:")
                .font(.caption)
                .fontWeight(.semibold)

            Text(confidence)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(confidenceColor(confidence).opacity(0.2))
                .foregroundColor(confidenceColor(confidence))
                .cornerRadius(10)
        }
    }

    // MARK: Confience Level, Card
    private func confidenceColor(_ confidence: String) -> Color {
        switch confidence {
        case "Strong":
            return .green
        case "Possible":
            return .orange
        default:
            return .gray
        }
    }

    private func setupLocationSearch() {
        searchCompleter.delegate = searchDelegate
        searchCompleter.resultTypes = [.address, .pointOfInterest]
    }

    private func useCurrentLocation() {
        useLocalLocation = true
        locationSearchText = "Current Location"
        showLocationSuggestions = false
        searchDelegate.results = []

        if let location = sightingsLocationManager.location {
            selectedUserCoordinate = location.coordinate
            applyLocalFilter()
        } else {
            sightingsLocationManager.requestLocation()
        }
    }

    private func selectSearchCompletion(_ completion: MKLocalSearchCompletion) {
        showLocationSuggestions = false
        searchDelegate.results = []
        locationSearchText = completion.title

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            DispatchQueue.main.async {
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    return
                }

                selectedUserCoordinate = coordinate
                useLocalLocation = true
                applyLocalFilter()
            }
        }
    }

    // MARK: Fetches sightings and lost pets from Firestore.
    private func fetchData() {
        isLoading = true

        let db = Firestore.firestore()
        let group = DispatchGroup()

        var fetchedSightings: [CommunitySighting] = []
        var fetchedMissingPets: [MissingPetReport] = []

        group.enter()
        db.collection("sightings")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                defer { group.leave() }

                if let error = error {
                    print("Error fetching sightings: \(error.localizedDescription)")
                    return
                }

                fetchedSightings = snapshot?.documents.compactMap {
                    CommunitySighting(document: $0)
                } ?? []
            }

        group.enter()
        db.collection("lost_pets")
            .getDocuments { snapshot, error in
                defer { group.leave() }

                if let error = error {
                    print("Error fetching lost pets: \(error.localizedDescription)")
                    return
                }

                fetchedMissingPets = snapshot?.documents.compactMap {
                    MissingPetReport(document: $0)
                } ?? []
            }

        group.notify(queue: .main) {
            sightings = fetchedSightings
            missingPets = fetchedMissingPets
            localMissingPets = fetchedMissingPets

            matchedSightings = buildMatches(
                sightings: fetchedSightings,
                missingPets: fetchedMissingPets
            )

            isLoading = false

            // Center map on first lost pet first, then first sighting if no pets exist.
            if let firstPet = localMissingPets.first {
                region.center = CLLocationCoordinate2D(
                    latitude: firstPet.lastKnownLatitude,
                    longitude: firstPet.lastKnownLongitude
                )
            } else if let firstMatch = matchedSightings.first {
                region.center = CLLocationCoordinate2D(
                    latitude: firstMatch.sighting.latitude,
                    longitude: firstMatch.sighting.longitude
                )
            }

            print("Fetched sightings: \(fetchedSightings.count)")
            print("Fetched missing pets: \(fetchedMissingPets.count)")
            print("Local missing pets: \(localMissingPets.count)")
            print("Matched sightings: \(matchedSightings.count)")
        }
    }

    // MARK: Filters pets and sightings within 10 miles of searched/current location.
    private func applyLocalFilter() {
        guard let coordinate = selectedUserCoordinate ?? sightingsLocationManager.location?.coordinate else {
            return
        }

        localMissingPets = missingPets.filter { pet in
            let petCoordinate = CLLocationCoordinate2D(
                latitude: pet.lastKnownLatitude,
                longitude: pet.lastKnownLongitude
            )

            return distanceMiles(from: coordinate, to: petCoordinate) <= searchRadiusMiles
        }

        matchedSightings = buildMatches(
            sightings: sightings,
            missingPets: localMissingPets
        )
        .filter { match in
            let sightingCoordinate = CLLocationCoordinate2D(
                latitude: match.sighting.latitude,
                longitude: match.sighting.longitude
            )

            return distanceMiles(from: coordinate, to: sightingCoordinate) <= searchRadiusMiles
        }

        region.center = coordinate
        region.span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    }

    // MARK: - Pet Pin Colors
    private func colorForPet(_ pet: MissingPetReport) -> Color {
        let colors: [Color] = [
            .red,
            .blue,
            .orange,
            .green,
            .purple,
            .pink,
            .teal,
            .indigo
        ]

        let visiblePets = localMissingPets.isEmpty ? missingPets : localMissingPets

        guard let index = visiblePets.firstIndex(where: { $0.id == pet.id }) else {
            return .gray
        }

        return colors[index % colors.count]
    }

    // MARK: Match Building
    // Creates possible matches between lost pets and sightings based on distance.

    // Confidence level
    private func confidenceLevel(for score: Int) -> String {
        if score >= 70 {
            return "Strong"
        } else if score >= 40 {
            return "Possible"
        } else {
            return "Weak"
        }
    }

    private func characteristicMatchScore(
        sighting: CommunitySighting,
        pet: MissingPetReport
    ) -> Int {
        var score = 0
        // MARK: Change Scoring Here
        if matches(sighting.size, pet.size) { score += 20}
        if matches(sighting.primaryColor, pet.primaryColor) { score += 30 }
        if matches(sighting.markings, pet.markings) { score += 20 }
        if matches(sighting.coatLength, pet.coatLength) { score += 10 }
        if matches(sighting.earType, pet.earType) { score += 10 }
        if matches(sighting.tailType, pet.tailType) { score += 10 }

        return score
    }

    private func matches(_ first: String, _ second: String) -> Bool {
        let a = normalized(first)
        let b = normalized(second)

        if a.isEmpty || b.isEmpty { return false }
        if a == "unknown" || b == "unknown" { return false }

        return a == b || a.contains(b) || b.contains(a)
    }

    private func normalized(_ value: String) -> String {
        value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func buildMatches(
        sightings: [CommunitySighting],
        missingPets: [MissingPetReport]
    ) -> [MatchedSighting] {

        var results: [MatchedSighting] = []

        for pet in missingPets {
            let petCoordinate = CLLocationCoordinate2D(
                latitude: pet.lastKnownLatitude,
                longitude: pet.lastKnownLongitude
            )

            let nearbySightings = sightings.compactMap { sighting -> (CommunitySighting, Double, Int)? in
                let sightingCoordinate = CLLocationCoordinate2D(
                    latitude: sighting.latitude,
                    longitude: sighting.longitude
                )

                let distance = distanceMiles(from: petCoordinate, to: sightingCoordinate)

                // MARK: Debug pins
                print("""
                Match debug:
                Pet: \(pet.petName)
                Pet coord: \(pet.lastKnownLatitude), \(pet.lastKnownLongitude)
                Sighting coord: \(sighting.latitude), \(sighting.longitude)
                Distance: \(distance)
                """)

                // Distance is a filter only.
                guard distance <= searchRadiusMiles else {
                    return nil
                }

                let score = characteristicMatchScore(
                    sighting: sighting,
                    pet: pet
                )

                return (sighting, distance, score)
            }
            .sorted {
                $0.2 > $1.2
            }

            for index in nearbySightings.indices {
                let sighting = nearbySightings[index].0
                let distance = nearbySightings[index].1
                let score = nearbySightings[index].2
                let confidenceLevel = confidenceLevel(for: score)
                let isPotentialMatch = score >= 70

                results.append(
                    MatchedSighting(
                        id: "\(pet.id)-\(sighting.id)",
                        sighting: sighting,
                        missingPet: pet,
                        distanceMiles: distance,
                        matchScore: score,
                        confidenceLevel: confidenceLevel,
                        isPotentialMatch: isPotentialMatch,
                        pinNumber: index + 1
                    )
                )
            }
        }

        return results.sorted {
            $0.matchScore > $1.matchScore
        }
    }

    private func distanceMiles(
        from first: CLLocationCoordinate2D,
        to second: CLLocationCoordinate2D
    ) -> Double {
        let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
        let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
        return start.distance(from: end) / 1609.344
    }

    private func openInMaps(_ sighting: CommunitySighting) {
        let coordinate = CLLocationCoordinate2D(
            latitude: sighting.latitude,
            longitude: sighting.longitude
        )

        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)

        mapItem.name = "PawPal Sighting"
        mapItem.openInMaps()
    }
}

// MARK: - Map Annotation Type

enum PetMapAnnotation: Identifiable {
    case lostPet(MissingPetReport)
    case sighting(MatchedSighting, displayOffsetIndex: Int)

    var id: String {
        switch self {
        case .lostPet(let pet):
            return "lostPet-\(pet.id)"

        case .sighting(let match, _):
            return "sighting-\(match.id)"
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .lostPet(let pet):
            return CLLocationCoordinate2D(
                latitude: pet.lastKnownLatitude,
                longitude: pet.lastKnownLongitude
            )

        case .sighting(let match, let offsetIndex):
            let baseLatitude = match.sighting.latitude
            let baseLongitude = match.sighting.longitude

            // Small visual-only offset so pins do not stack exactly.
            let offset = Double(offsetIndex) * 0.00018

            return CLLocationCoordinate2D(
                latitude: baseLatitude + offset,
                longitude: baseLongitude + offset
            )
        }
    }
}

// MARK: - Location Manager

final class SightingsLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()

        case .denied, .restricted:
            print("Location permission denied or restricted.")

        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        DispatchQueue.main.async {
            self.location = locations.last
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location error: \(error.localizedDescription)")
    }
}

// MARK: - Search Completer

final class SightingsSearchCompleterDelegate: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [SightingsSearchResult] = []

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results.map {
                SightingsSearchResult(completion: $0)
            }
        }
    }
}

struct SightingsSearchResult: Identifiable {
    let id = UUID()
    let completion: MKLocalSearchCompletion

    var title: String {
        completion.title
    }

    var subtitle: String {
        completion.subtitle
    }
}

// MARK: - Match Model

struct MatchedSighting: Identifiable {
    let id: String
    let sighting: CommunitySighting
    let missingPet: MissingPetReport
    let distanceMiles: Double
    let matchScore: Int
    let confidenceLevel: String
    let isPotentialMatch: Bool
    let pinNumber: Int
}

// MARK: - Lost Pet Model

struct MissingPetReport: Identifiable {
    let id: String
    let petName: String
    let lastKnownLatitude: Double
    let lastKnownLongitude: Double

    let size: String
    let primaryColor: String
    let markings: String
    let coatLength: String
    let earType: String
    let tailType: String
    let collarSeen: String

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        let latitude =
            data["lat"] as? Double ??
            data["latitude"] as? Double ??
            data["lastKnownLatitude"] as? Double

        let longitude =
            data["lng"] as? Double ??
            data["longitude"] as? Double ??
            data["lastKnownLongitude"] as? Double

        guard let latitude, let longitude else {
            return nil
        }

        self.id = document.documentID
        self.petName = data["petName"] as? String ?? "Missing Pet"
        self.lastKnownLatitude = latitude
        self.lastKnownLongitude = longitude

        self.size = data["size"] as? String ?? "Unknown"
        self.primaryColor = data["primaryColor"] as? String ?? "Unknown"
        self.markings = data["markings"] as? String ?? "Unknown"
        self.coatLength = data["coatLength"] as? String ?? "Unknown"
        self.earType = data["earType"] as? String ?? "Unknown"
        self.tailType = data["tailType"] as? String ?? "Unknown"
        self.collarSeen = data["collarSeen"] as? String ?? "Unknown"
    }
}

// MARK: - Community Sighting Model

struct CommunitySighting: Identifiable {
    let id: String
    let latitude: Double
    let longitude: Double
    let locationNotes: String
    let createdAt: Date

    let size: String
    let primaryColor: String
    let markings: String
    let coatLength: String
    let earType: String
    let tailType: String

    let petCondition: String
    let directionTraveled: String
    let behavior: String
    let collarSeen: String
    let contactInfo: String

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double
        else {
            return nil
        }

        self.id = document.documentID
        self.latitude = latitude
        self.longitude = longitude
        self.locationNotes = data["locationNotes"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

        self.size = data["size"] as? String ?? "Unknown"
        self.primaryColor = data["primaryColor"] as? String ?? "Unknown"
        self.markings = data["markings"] as? String ?? "Unknown"
        self.coatLength = data["coatLength"] as? String ?? "Unknown"
        self.earType = data["earType"] as? String ?? "Unknown"
        self.tailType = data["tailType"] as? String ?? "Unknown"

        self.petCondition = data["petCondition"] as? String ?? "Unknown"
        self.directionTraveled = data["directionTraveled"] as? String ?? "Unknown"
        self.behavior = data["behavior"] as? String ?? "Unknown"
        self.collarSeen = data["collarSeen"] as? String ?? "Unknown"
        self.contactInfo = data["contactInfo"] as? String ?? ""
    }
}
