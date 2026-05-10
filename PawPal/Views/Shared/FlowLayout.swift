//
//  FlowLayout.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//
import SwiftUI

struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], alignment: alignment, spacing: spacing) {
            content()
        }
    }
}
