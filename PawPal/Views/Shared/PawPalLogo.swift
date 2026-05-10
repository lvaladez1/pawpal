//
//  PawPalLogo.swift
//  PawPal
//
//  Created by Moe Karaki on 11/23/25.
//

import SwiftUI

struct PawPalLogo: View {
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 120, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        VStack(spacing: showText ? 12 : 0) {
            Text("🐾")
                .font(.system(size: size * 0.5))
            
            if showText {
                VStack(spacing: 4) {
                    Text("PawPal")
                        .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Reuniting Hearts & Paws")
                        .font(.system(size: size * 0.12, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        PawPalLogo(size: 120, showText: true)
        PawPalLogo(size: 80, showText: false)
        PawPalLogo(size: 60, showText: true)
    }
    .padding()
}