//
//  UserProfileView.swift
//  PawPal
//
//  Created by Kevin Crapo on 11/28/25.
//


//
//  UserProfileView.swift
//  PawPal
//
// 
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var pets: [LostPet] = []
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Profile Header Card
                        if let user = authVM.user {
                            VStack(spacing: 20) {
                                ZStack {
                                    let gradientColors = [Color.theme.babyBlue, Color.theme.babyBlue.opacity(0.7)]
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: gradientColors),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .shadow(color: Color.theme.babyBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    Text(String(user.email?.prefix(1).uppercased() ?? "U"))
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(showContent ? 1.0 : 0.8)
                                .opacity(showContent ? 1.0 : 0.0)
                                
                                VStack(spacing: 8) {
                                    Text(user.email ?? "Unknown")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.caption)
                                        Text("Verified Account")
                                            .font(.caption)
                                    }
                                    .foregroundColor(Color.theme.babyBlue)
                                }
                                .opacity(showContent ? 1.0 : 0.0)
                            }
                            .padding(.vertical, 30)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        
                        // Stats Card
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("\(pets.count)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color.theme.babyBlue)
                                Text("Reports")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                Text("Helping")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        
                        // My Reports Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(Color.theme.babyBlue)
                                Text("My Reports")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            if isLoading {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .tint(Color.theme.babyBlue)
                                        Text("Loading your reports...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 40)
                                    Spacer()
                                }
                            } else if pets.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 60))
                                        .foregroundColor(Color.theme.babyBlue.opacity(0.5))
                                    
                                    VStack(spacing: 8) {
                                        Text("No Reports Yet")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Your reported lost pets will appear here")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(pets) { pet in
                                        NavigationLink(destination: LostPetDetailView(pet: pet)) {
                                            HStack(spacing: 16) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.theme.babyBlue.opacity(0.15))
                                                        .frame(width: 50, height: 50)
                                                    
                                                    Image(systemName: "pawprint.fill")
                                                        .foregroundColor(Color.theme.babyBlue)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(pet.petName)
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(pet.description)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                    
                                                    if let date = pet.timestampDate {
                                                        Text(timeAgo(from: date))
                                                            .font(.caption)
                                                            .foregroundColor(Color.theme.babyBlue)
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.gray.opacity(0.5))
                                            }
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                deletePet(pet)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Logout Button
                        Button(action: {
                            authVM.signOut()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadPets()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    showContent = true
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }

    private func loadPets() {
        guard let uid = authVM.user?.uid else { return }

        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .whereField("userId", isEqualTo: uid)
            .order(by: FS.LostPets.timestamp, descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    isLoading = false
                    return
                }

                self.pets = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    return LostPet(
                        id: doc.documentID,
                        petName: data[FS.LostPets.petName] as? String ?? "",
                        description: data[FS.LostPets.description] as? String ?? "",
                        latitude: data[FS.LostPets.lat] as? Double ?? 0,
                        longitude: data[FS.LostPets.lng] as? Double ?? 0,
                        timestamp: (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue(),
                        userId: data["userId"] as? String
                    )
                } ?? []

                isLoading = false
            }
    }

    private func deletePet(_ pet: LostPet) {
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .document(pet.id)
            .delete { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }

                pets.removeAll { $0.id == pet.id }
            }
    }
}
