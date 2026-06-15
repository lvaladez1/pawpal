//
//  TailTypeHelpView.swift
//  PawPal
//
//  Created by Claudia Fierro on 6/14/26.
//

import SwiftUI

struct TailTypeHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    TailTypeExample(
                        title: "Whip Tail",
                        imageName: "whip-tail",
                        description: "Long, thin tail that tapers to a point and is usually carried straight or slightly curved."
                    )

                    TailTypeExample(
                        title: "Curled Tail",
                        imageName: "curled-tail",
                        description: "Curves upward or loops over the dog’s back in a loose or tight curl."
                    )

                    TailTypeExample(
                        title: "Furry Tail",
                        imageName: "furry-tail",
                        description: "Covered in thick, fluffy fur that makes it look full and bushy."
                    )
                    
                    TailTypeExample(
                        title: "No Tail",
                        imageName: "no-tail",
                        description: "No visible tail or a very short natural tail."
                    )
                }
                .padding()
            }
            .navigationTitle("Tail Types")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

private struct TailTypeExample: View {
    let title: String
    let imageName: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}
