//
//  LostPetDetailView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//
//  Contributors:
//  Luis Valadez last updated on 5/20/26.
//  Mariah Stinson last updated on 6/14/26
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct LinkedSighting: Identifiable {
    let id: String
    let latitude: Double
    let longitude: Double
    let notes: String
    let petCondition: String
    let createdAt: Date?
}

struct LostPetDetailView: View {
    let pet: LostPet
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var displayedPet: LostPet
    @State private var showContent = false
    @State private var showContactAlert = false
    @State private var showShareSheet = false
    @State private var linkedSightings: [LinkedSighting] = []
    @State private var isLoadingSightings = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    init(pet: LostPet) {
        self.pet = pet
        _displayedPet = State(initialValue: pet)
    }
    
    private var canEditPet: Bool {
        guard let currentUserId = authVM.user?.uid else {
            return false
        }
        
        return displayedPet.userId == currentUserId
    }

    private var region: MKCoordinateRegion? {
        guard (-90.0...90.0).contains(displayedPet.latitude),
              (-180.0...180.0).contains(displayedPet.longitude) else {
            return nil
        }

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: displayedPet.latitude, longitude: displayedPet.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Hero Section with animated pet icon
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.theme.babyBlue.opacity(0.2), Color.theme.babyBlue.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color.theme.babyBlue)
                        }
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        
                        VStack(spacing: 8) {
                            Text(displayedPet.petName)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if let date = displayedPet.timestampDate {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.caption)
                                    Text("Reported \(timeAgo(from: date))")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Notes Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(Color.theme.babyBlue)
                            Text("Notes")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Text(displayedPet.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    
                    // Pet Details Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "pawprint.fill")
                                .foregroundColor(Color.theme.babyBlue)
                            Text("Pet Details")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        detailRow(label: "Size", value: displayedPet.size)
                        detailRow(label: "Primary Color", value: displayedPet.primaryColor ?? "")
                        detailRow(label: "Secondary Color", value: displayedPet.secondaryColor ?? "")
                        detailRow(label: "Markings", value: displayedPet.markings)
                        detailRow(label: "Coat Length", value: displayedPet.coatLength)
                        detailRow(label: "Ear Type", value: displayedPet.earType)
                        detailRow(label: "Tail Type", value: displayedPet.tailType)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    
                    // MARK: Location Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text("Last Seen Location")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        if isValidCoordinate {
                            Map(position: $cameraPosition) {
                                Marker(
                                    displayedPet.petName,
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: displayedPet.latitude,
                                        longitude: displayedPet.longitude
                                    )
                                )
                                .tint(.red)
                            }
                            .frame(height: 280)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Location unavailable for this report")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    
                    // Linked Sightings Section
                    if canEditPet {
                        linkedSightingsSection
                    }
                    
                    // Contact/Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showContactAlert = true
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Contact Reporter")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.babyBlue)
                            .cornerRadius(12)
                            .shadow(color: Color.theme.babyBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        // Sighting Button
                        NavigationLink(destination: ReportSightingView(relatedPet: displayedPet)) {
                            HStack {
                                Image(systemName: "binoculars.fill")
                                
                                Text("Report Sighting")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.babyBlue)
                            .cornerRadius(12)
                            .shadow(color: Color.theme.babyBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        // Share Report Button
                        Button(action: {
                            showShareSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share This Report")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Color.theme.babyBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.babyBlue, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Pet Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if canEditPet {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: EditLostPetView(pet: displayedPet) { updatedPet in
                            displayedPet = updatedPet
                            updateCameraPosition()
                            loadLinkedSightings()
                        }
                    ) {
                        Text("Edit")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.babyBlue)
                    }
                }
            }
        }
        .alert("Contact Reporter", isPresented: $showContactAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Contact information will be available in a future update. For now, you can share this report with others who might help.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [generateShareText()])
        }
        .onAppear {
            updateCameraPosition()
            loadLinkedSightings()
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Linked Sightings
    
    private var linkedSightingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "binoculars.fill")
                    .foregroundColor(Color.theme.babyBlue)

                Text("Sightings Reported for \(displayedPet.petName)")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            if isLoadingSightings {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(Color.theme.babyBlue)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else if linkedSightings.isEmpty {
                Text("No linked sightings have been reported for this pet yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(linkedSightings) { sighting in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Potential Match")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()

                                if let createdAt = sighting.createdAt {
                                    Text(timeAgo(from: createdAt))
                                        .font(.caption)
                                        .foregroundColor(Color.theme.babyBlue)
                                }
                            }

                            if !sighting.petCondition.isEmpty {
                                Text("Condition: \(sighting.petCondition)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if !sighting.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(sighting.notes)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }

                            Text("Location: \(sighting.latitude), \(sighting.longitude)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.theme.babyBlue.opacity(0.08))
                        .cornerRadius(14)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    private func loadLinkedSightings() {
        guard canEditPet else { return }

        isLoadingSightings = true

        Firestore.firestore()
            .collection("sightings")
            .whereField("relatedLostPetId", isEqualTo: displayedPet.id)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoadingSightings = false

                    if let error {
                        print("Failed to load linked sightings: \(error.localizedDescription)")
                        return
                    }

                    linkedSightings = snapshot?.documents.compactMap { doc in
                        let data = doc.data()

                        return LinkedSighting(
                            id: doc.documentID,
                            latitude: data["latitude"] as? Double ?? 0,
                            longitude: data["longitude"] as? Double ?? 0,
                            notes: data["notes"] as? String ?? "",
                            petCondition: data["petCondition"] as? String ?? "",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                        )
                    } ?? []
                }
            }
    }
    
    // MARK: - Coordinate Helpers
    
    private var isValidCoordinate: Bool {
        (-90.0...90.0).contains(displayedPet.latitude) &&
        (-180.0...180.0).contains(displayedPet.longitude)
    }
    
    private func updateCameraPosition() {
        guard isValidCoordinate else { return }
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: displayedPet.latitude,
                    longitude: displayedPet.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    
    private func detailRow(label: String, value: String) -> some View {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Group {
            if !trimmedValue.isEmpty {
                HStack(alignment: .top) {
                    Text("\(label):")
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(trimmedValue)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
    private func generateShareText() -> String {
        let locationText = "Location: \(displayedPet.latitude), \(displayedPet.longitude)"
        let timeText = displayedPet.timestampDate.map { "Reported: \(formatted(date: $0))" } ?? ""
        
        return """
        🐾 Lost Pet Alert: \(displayedPet.petName)
        
        \(displayedPet.description)
        
        \(locationText)
        \(timeText)
        
        Please help reunite \(displayedPet.petName) with their family! 🏡
        
        Shared via PawPal
        """
    }
    
    private func timeAgo(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "just now"
        }
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Share Sheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    LostPetDetailView(pet: LostPet(
        id: "1",
        petName: "Bella",
        size: "Small",
        markings: "Spotted",
        coatLength: "Short",
        earType: "Floppy",
        tailType: "Furry tail",
        description: "Last seen near Elm Street.",
        latitude: 38.5449,
        longitude: -121.7405,
        timestamp: Date(),
        userId: "preview-user-id",
        primaryColor: "Brown",
        secondaryColor: "White"
    ))
    .environmentObject(AuthViewModel())
}
