//
//  EarTypeHelpView.swift
//  PawPal
//
//  Created by Claudia Fierro on 6/14/26.
//

import SwiftUI

struct EarTypeHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    EarTypeExample(
                        title: "Erect",
                        imageName: "erect-ears",
                        description: "Ears stand upright and point upward."
                    )

                    EarTypeExample(
                        title: "Semi-erect",
                        imageName: "semi-erect-ears",
                        description: "Ears are mostly upright with tips that fold over."
                    )

                    EarTypeExample(
                        title: "Floppy",
                        imageName: "floppy_ears",
                        description: "Ears hang down alongside the head."
                    )
                }
                .padding()
            }
            .navigationTitle("Ear Types")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

private struct EarTypeExample: View {
    let title: String
    let imageName: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 78, height: 78)
                .clipped()
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
