//
//  LostPetRow.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//
//  Contributors:
//  Luis Valadez last updated on 5/20/26.
//

import SwiftUI

struct LostPetRow: View {
    let pet: LostPet
    
    private var petTags: [String] {
        [
            pet.primaryColor?.capitalized,
            pet.secondaryColor?.capitalized,
        ]
        .compactMap { $0 }
        .filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            $0.lowercased() != "unknown" &&
            $0.lowercased() != "none"
        }
    }

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
                
                if !petTags.isEmpty {
                    TagFlowLayout(tags: petTags)
                }
                
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
    
    struct PetTag: View {
        let title: String

        var body: some View {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.babyBlue)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .stroke(Color.theme.babyBlue, lineWidth: 1)
                )
        }
    }

    struct TagFlowLayout: View {
        let tags: [String]

        var body: some View {
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    PetTag(title: tag)
                }
            }
        }
    }
    
    struct FlowLayout: Layout {
        var spacing: CGFloat = 8
        
        func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) -> CGSize {
            let maxWidth = proposal.width ?? 0
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            
            return CGSize(width: maxWidth, height: y + rowHeight)
        }
        
        func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) {
            var x = bounds.minX
            var y = bounds.minY
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > bounds.maxX {
                    x = bounds.minX
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(size)
                )
                
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
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
