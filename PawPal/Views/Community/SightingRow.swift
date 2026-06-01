//
//  SightingRow.swift
//  PawPal
//
//  Created by Luis V on 5/26/26.
//

import SwiftUI

struct SightingRow: View {
    
    let sighting: PossiblePetSighting
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                
                Text("Possible Sighting")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if let score = sighting.matchScore {
                    
                    Text("\(score)% Match")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.babyBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.theme.babyBlue.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            
            Text(sighting.locationNotes)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text("Direction: \(sighting.directionTraveled)")
                Text("Behavior: \(sighting.behavior)")
                Text("Condition: \(sighting.petCondition)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if let distance = sighting.distanceMiles {
                
                Text(String(format: "%.2f miles from original report", distance))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 6,
            x: 0,
            y: 3
        )
    }
}
