//
//  LostPetRow.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//

import SwiftUI

struct LostPetRow: View {
    let pet: LostPet

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Pet Icon / Avatar
            ZStack {
                Circle()
                    .fill(Color.theme.babyBlue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.theme.babyBlue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pet.petName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let timestamp = pet.timestamp {
                        Text(timeAgoString(from: timestamp))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Text(pet.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text("Tap to see location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
    }
    
    private func timeAgoString(from date: Date) -> String {
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
            return "Now"
        }
    }
}
