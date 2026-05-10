//
//  SearchCompleterDelegate.swift
//  PawPal
//
//  Created by Juan Zavala on 8/13/25.
//

import Foundation
import MapKit
import SwiftUI

class CompleterDelegateWrapper: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [SearchResult] = []

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("🔍 Got \(completer.results.count) suggestions")
        DispatchQueue.main.async {
            self.results = completer.results.map { SearchResult(completion: $0) }
        }
    }


    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Autocomplete error: \(error.localizedDescription)")
    }
}

struct SearchResult: Hashable, Identifiable {
    let id = UUID()
    let completion: MKLocalSearchCompletion

    var title: String { completion.title }
    var subtitle: String { completion.subtitle }

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.completion.title == rhs.completion.title &&
        lhs.completion.subtitle == rhs.completion.subtitle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(completion.title)
        hasher.combine(completion.subtitle)
    }
}


