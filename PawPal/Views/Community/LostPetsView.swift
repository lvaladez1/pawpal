//
//  LostPetsView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

// LostPetsView.swift
import SwiftUI
import Firebase
import FirebaseAuth
import MapKit
import FirebaseFirestore

struct LostPetsView: View {
    @State private var lostPets: [LostPet] = []
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    @State private var showFilters = false
    
    enum ViewMode {
        case list
        case map
    }

    private var filteredPets: [LostPet] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return lostPets
        }
        return lostPets.filter { pet in
            pet.petName.localizedCaseInsensitiveContains(query) ||
            pet.description.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern header with segmented control
                if !lostPets.isEmpty && !isLoading {
                    VStack(spacing: 12) {
                        Picker("View Mode", selection: $viewMode.animation(.easeInOut)) {
                            Label("List", systemImage: "list.bullet").tag(ViewMode.list)
                            Label("Map", systemImage: "map").tag(ViewMode.map)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.8)
                            .tint(Color.theme.babyBlue)
                        Text("Fetching lost pet reports...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if lostPets.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(Color.theme.babyBlue.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("No Reports Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Be the first to report a lost pet and help bring them home safely.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {
                    if viewMode == .list {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPets) { pet in
                                    NavigationLink(destination: LostPetDetailView(pet: pet)) {
                                        LostPetRow(pet: pet)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                    .buttonStyle(PlainButtonStyle())
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .refreshable {
                            fetchLostPets()
                        }
                    } else {
                        LostPetMapView()
                            .transition(.opacity)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(Color.theme.babyBlue)
                        .font(.headline)
                    Text("Lost Pets")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .onAppear(perform: fetchLostPets)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search by name or description"
        )
        .alert("Oops", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func fetchLostPets() {
        isLoading = true
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .order(by: FS.LostPets.timestamp, descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        alertMessage = error.localizedDescription
                        showAlert = true
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        lostPets = []
                        return
                    }

                    self.lostPets = documents.compactMap { doc in
                        let data = doc.data()
                        guard
                            let name = data[FS.LostPets.petName] as? String,
                            let desc = data[FS.LostPets.description] as? String,
                            let lat  = data[FS.LostPets.lat] as? Double,
                            let lng  = data[FS.LostPets.lng] as? Double
                        else {
                            return nil
                        }

                        let timestamp = (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue()

                        return LostPet(
                            id: doc.documentID,
                            petName: name,
                            description: desc,
                            latitude: lat,
                            longitude: lng,
                            timestamp: timestamp
                        )
                    }
                }
            }
    }
}

#Preview {
    LostPetsView()
}
