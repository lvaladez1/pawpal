//
//  LostPetDetailView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

import SwiftUI
import MapKit

struct LostPetDetailView: View {
    let pet: LostPet
    @State private var showContent = false
    @State private var showContactAlert = false
    @State private var showShareSheet = false

    private var region: MKCoordinateRegion? {
        guard (-90.0...90.0).contains(pet.latitude),
              (-180.0...180.0).contains(pet.longitude) else {
            return nil
        }

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude),
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
                            Text(pet.petName)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if let date = pet.timestampDate {
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
                    
                    // Description Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(Color.theme.babyBlue)
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Text(pet.description)
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
                    
                    // Location Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text("Last Seen Location")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        if let region = region {
                            Map(initialPosition: .region(region)) {
                                Marker(pet.petName, coordinate: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude))
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
        .alert("Contact Reporter", isPresented: $showContactAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Contact information will be available in a future update. For now, you can share this report with others who might help.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [generateShareText()])
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
    
    private func generateShareText() -> String {
        let locationText = "Location: \(pet.latitude), \(pet.longitude)"
        let timeText = pet.timestampDate.map { "Reported: \(formatted(date: $0))" } ?? ""
        
        return """
        🐾 Lost Pet Alert: \(pet.petName)
        
        \(pet.description)
        
        \(locationText)
        \(timeText)
        
        Please help reunite \(pet.petName) with their family! 🏡
        
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
        description: "Last seen near Elm Street.",
        latitude: 38.5449,
        longitude: -121.7405,
        timestamp: Date()
    ))
}
