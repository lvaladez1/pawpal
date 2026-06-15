//
//  ReportSightingView.swift
//  PawPal
//
//  Community sighting form.
//  Used when a spotter sees a loose pet that may be lost.
//
//  The submitted report is saved to Firestore.
//
//
//  Created by Luis V on 5/19/26.
//  Contributors:
//  Mariah Stinson last updated on 6/14/26
//

import SwiftUI
import MapKit
import PhotosUI
import FirebaseFirestore
import CoreLocation

struct ReportSightingView: View {
    let relatedPet: LostPet?
    
    init(relatedPet: LostPet? = nil) {
        self.relatedPet = relatedPet
    }
    
    @Environment(\.dismiss) private var dismiss

    @StateObject private var locationManager = LocationManager()
    @StateObject private var completerDelegateWrapper = CompleterDelegateWrapper()

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: Image?

    @State private var size = ""
    @State private var primaryColor = ""
    @State private var markings = ""
    @State private var coatLength = ""
    @State private var earType = ""
    @State private var tailType = ""
    @State private var petCondition = "Unknown"
    @State private var notes = ""
    @State private var otherPrimaryColor = ""
    @State private var otherMarkings = ""
    
    @State private var showEarTypeHelp = false

    @State private var searchQuery = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var showLocationSuggestions = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var hasManuallySelectedLocation = false

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let sizeOptions = ["Small", "Medium", "Large"]
    private let colorOptions = ["Black", "White", "Brown", "Tan", "Black & White", "Gray", "Golden", "Other"]
    private let markingOptions = ["White chest", "White paws", "Spotted", "Black mask", "Brindle", "Merle", "Other", "Unknown"]
    private let coatOptions = ["Short", "Medium", "Long"]
    private let earOptions = ["Erect", "Semi-erect", "Floppy"]
    private let tailOptions = ["Whip tail", "Furry tail", "Curled", "No tail", "Unknown"]
    private let conditionOptions = ["Healthy", "Injured", "Unknown"]

    var body: some View {
        ZStack {
            Color.theme.babyBlueLight
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    headerSection

                    photoSection

                    Text("About the Pet")
                        .font(.title3)
                        .fontWeight(.bold)

                    optionSection(
                        title: "Size",
                        selection: $size,
                        options: sizeOptions
                    )

                    optionSection(
                        title: "Primary Color",
                        selection: $primaryColor,
                        options: colorOptions
                    )
                    
                    otherTextView(
                        selection: primaryColor,
                        text: $otherPrimaryColor,
                        placeholder: "Enter Primary Color (if other)")

                    optionSection(
                        title: "Markings",
                        selection: $markings,
                        options: markingOptions
                    )
                    
                    otherTextView(
                        selection: markings,
                        text: $otherMarkings,
                        placeholder: "Enter Markings (if other)")

                    optionSection(
                        title: "Coat Length",
                        selection: $coatLength,
                        options: coatOptions
                    )

                    optionSection(
                        title: "Ear Type",
                        selection: $earType,
                        options: earOptions
                    ) {
                        Button {
                            showEarTypeHelp = true
                        } label: {
                            Label("What is this?", systemImage: "questionmark.circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    optionSection(
                        title: "Tail Type",
                        selection: $tailType,
                        options: tailOptions
                    )

                    optionSection(
                        title: "Pet's Condition",
                        selection: $petCondition,
                        options: conditionOptions
                    )

                    notesSection

                    locationSection

                    submitButton
                }
                .padding(20)
            }
            .sheet(isPresented: $showEarTypeHelp) {
                EarTypeHelpView()
            }
        }
        
        .navigationTitle("Report a Sighting")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupLocationSearch()
        }
        .alert("Sighting Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(relatedPet == nil ? "Help a lost pet get back home." : "Report a sighting for \(relatedPet?.petName ?? "this pet").")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .foregroundColor(Color.theme.babyBlue)

                Text("Your report helps PawPal match sightings to missing pets.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.white.opacity(0.85))
            .cornerRadius(14)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Photo

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a Photo")
                .font(.headline)

            Text("A clear photo helps guardians recognize their pet.")
                .font(.caption)
                .foregroundColor(.secondary)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundColor(Color.theme.babyBlue.opacity(0.7))
                        .frame(height: 160)

                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color.theme.babyBlue)

                            Text("Take Photo or Choose")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.theme.babyBlue)
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                loadSelectedPhoto(newItem)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Options

    private func optionSection<Content: View>(
        title: String,
        selection: Binding<String>,
        options: [String],
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        Text(option)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selection.wrappedValue == option ? Color.theme.babyBlue : Color.white)
                            .foregroundColor(selection.wrappedValue == option ? .white : .primary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            
            content()
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(18)
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Additional Notes", systemImage: "square.and.pencil")
                .font(.headline)

            TextField("Behavior, direction, surroundings, or anything else...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color.white)
                .cornerRadius(14)
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(18)
    }

    // MARK: Location Card

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                Text("Where did you see the pet?")
                    .font(.headline)
            }
                
            TextField("Search for a place or enter an address", text: $searchQuery)
                .padding()
                .background(Color.white)
                .cornerRadius(14)
                .onChange(of: searchQuery) { newValue in
                    if hasManuallySelectedLocation {
                        hasManuallySelectedLocation = false
                        return
                    }
                    
                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    showLocationSuggestions = !trimmed.isEmpty
                    searchCompleter.queryFragment = trimmed
                }
            
            if showLocationSuggestions && !completerDelegateWrapper.results.isEmpty {
                VStack(spacing: 0) {
                    ForEach(completerDelegateWrapper.results) { result in
                        VStack(alignment: .leading) {
                            Text(result.title)
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            selectSearchCompletion(result.completion)
                        }
                        
                        Divider()
                    }
                }
                .cornerRadius(14)
            }
            
            Button {
                useCurrentLocation()
            } label: {
                Label("Use My Current Location", systemImage: "location.fill")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.babyBlue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
            }
            
            Map(position: $cameraPosition) {
                if let selectedCoordinate {
                    Marker("Sighting Location", coordinate: selectedCoordinate)
                }
            }
            .frame(height: 200)
            .mapStyle(.standard(elevation: .flat))
            .tint(Color.theme.babyBlue)
            .background(Color.theme.babyBlue)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .overlay {
                if selectedCoordinate == nil {
                    ZStack {
                        Color.theme.babyBlue
                        
                        Text("Sighting Location")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.45), radius: 2, x: 0, y: 1)
                    }
                    .cornerRadius(16)
                }
            }
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            submitSighting()
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                }

                Text(isSubmitting ? "Submitting..." : "Submit Sighting")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.theme.babyBlue)
            .cornerRadius(28)
            .shadow(color: Color.theme.babyBlue.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .disabled(isSubmitting || selectedCoordinate == nil)
        .opacity(isSubmitting || selectedCoordinate == nil ? 0.6 : 1.0)
    }

    // MARK: - Actions

    private func setupLocationSearch() {
        searchCompleter.delegate = completerDelegateWrapper
        searchCompleter.resultTypes = .address

        if let coord = locationManager.location?.coordinate {
            setMapLocation(coord)
        }
    }

    private func useCurrentLocation() {
        guard let coord = locationManager.location?.coordinate else {
            alertMessage = "Unable to get your current location. Please search for a location instead."
            showAlert = true
            return
        }

        hasManuallySelectedLocation = true
        searchQuery = "Current Location"
        showLocationSuggestions = false
        completerDelegateWrapper.results = []
        setMapLocation(coord)
    }

    private func setMapLocation(_ coord: CLLocationCoordinate2D) {
        selectedCoordinate = coord
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    private func selectSearchCompletion(_ completion: MKLocalSearchCompletion) {
        hasManuallySelectedLocation = true
        showLocationSuggestions = false
        completerDelegateWrapper.results = []

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            DispatchQueue.main.async {
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    alertMessage = "Could not find that location. Please try another search."
                    showAlert = true
                    return
                }

                searchQuery = completion.title
                setMapLocation(coordinate)
            }
        }
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        Task {
            guard let item else { return }

            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = Image(uiImage: uiImage)
            }
        }
    }

    private func submitSighting() {
        guard let coordinate = selectedCoordinate else {
            alertMessage = "Please select a sighting location."
            showAlert = true
            return
        }

        guard !size.isEmpty,
              !primaryColor.isEmpty else {
            alertMessage = "Please complete at least size, primary color, and location."
            showAlert = true
            return
        }

        isSubmitting = true

        // MARK: Firestore Data
        // PawPal can later match this document against active lost pet reports.
        var data: [String: Any] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "locationNotes": searchQuery,

            "size": size,
            "primaryColor": primaryColor,
            "markings": markings,
            "coatLength": coatLength,
            "earType": earType,
            "tailType": tailType,

            // Condition helps guardians judge urgency, but should not drive matching.
            "petCondition": petCondition,

            "notes": notes,
            "createdAt": FieldValue.serverTimestamp(),
            "status": relatedPet == nil ? "unmatched" : "potential_match",
            "source": relatedPet == nil ? "general_sighting" : "lost_pet_detail_sighting"
        ]
        
        if let relatedPet {
            data["relatedLostPetId"] = relatedPet.id
            data["relatedLostPetName"] = relatedPet.petName
            data["relatedLostPetOwnerId"] = relatedPet.userId
            data["matchType"] = "direct_report"
        }

        Firestore.firestore()
            .collection("sightings")
            .addDocument(data: data) { error in
                DispatchQueue.main.async {
                    isSubmitting = false

                    if let error {
                        alertMessage = "Failed to submit sighting: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        alertMessage = "Sighting submitted successfully."
                        showAlert = true
                        resetForm()
                    }
                }
            }
    }

    private func resetForm() {
        selectedPhoto = nil
        selectedImage = nil
        size = ""
        primaryColor = ""
        markings = ""
        coatLength = ""
        earType = ""
        tailType = ""
        petCondition = "Unknown"
        notes = ""
        searchQuery = ""
        selectedCoordinate = nil
    }
    
    @ViewBuilder
    private func otherTextView(
            selection: String,
            text: Binding<String>,
            placeholder: String
        ) -> some View {
            if selection == "Other" {
                TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
            }
        }
    }

#Preview {
    NavigationStack {
        ReportSightingView()
    }
}
