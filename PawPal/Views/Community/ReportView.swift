//
//  ReportView.swift
//  PawPal
//
//  Created by Luis V on 5/31/26.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.babyBlueLight
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color.theme.babyBlue)
                                .padding()
                                .background(Color.theme.babyBlue.opacity(0.15))
                                .clipShape(Circle())

                            Text("What would you like to do?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            Text("Choose an option below to help our community reunite pets with their families.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 24)

                        // Missing pet option
                        NavigationLink {
                            LostPetReportView()
                        } label: {
                            ReportOptionCard(
                                icon: "dog.fill",
                                iconColor: Color.theme.babyBlue,
                                title: "Enter a Missing Pet",
                                subtitle: "Let the community know your pet is missing.",
                                bullets: [
                                    "Create a lost pet report",
                                    "Share on the map",
                                    "Get notified of sightings"
                                ],
                                buttonText: "Enter Missing Pet",
                                buttonColor: Color.theme.babyBlue
                            )
                        }
                        .buttonStyle(.plain)

                        // Sighting option
                        NavigationLink {
                            ReportSightingView()
                        } label: {
                            ReportOptionCard(
                                icon: "binoculars.fill",
                                iconColor: .green,
                                title: "Report a Sighting",
                                subtitle: "Saw a pet that might be lost? Submit a sighting to help.",
                                bullets: [
                                    "Add a photo",
                                    "Share location and details",
                                    "Help reunite a pet with their family"
                                ],
                                buttonText: "Report Sighting",
                                buttonColor: .green
                            )
                        }
                        .buttonStyle(.plain)

                        // Footer message
                        HStack(spacing: 12) {
                            Image(systemName: "shield.fill")
                                .font(.title2)
                                .foregroundColor(Color.theme.babyBlue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your reports make a difference.")
                                    .font(.headline)

                                Text("Thank you for helping pets get home safe.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(18)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Card

struct ReportOptionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let bullets: [String]
    let buttonText: String
    let buttonColor: Color

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top, spacing: 18) {

                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundColor(iconColor)
                    .frame(width: 88, height: 88)
                    .background(iconColor.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(bullets, id: \.self) { bullet in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(iconColor)

                                Text(bullet)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Spacer()
            }

            HStack {
                Text(buttonText)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding()
            .background(buttonColor)
            .cornerRadius(24)
        }
        .padding()
        .background(Color.white.opacity(0.92))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(iconColor.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    ReportView()
}
