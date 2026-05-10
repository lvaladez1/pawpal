# PawPal
**Helping reunite lost pets with their families**

PawPal is an iOS app built with **SwiftUI**, **Firebase**, and **MapKit**.  
It allows users to report, browse, and locate lost pets through a clean, community-driven interface.

This document is a **comprehensive developer guide and tutorial** explaining the app’s architecture, SwiftUI navigation, Firebase/Firestore integration, MapKit usage, and Swift development fundamentals.

---

## Table of Contents

1. [Overview](#overview)  
2. [Tech Stack](#tech-stack)  
3. [Project Structure](#project-structure)  
4. [Dependencies](#dependencies)  
5. [App Flow](#app-flow)  
6. [Firebase Integration Examples](#firebase-integration-examples)  
7. [Firestore in Swift Tutorial](#firestore-in-swift-tutorial)  
8. [Understanding Firestore in PawPal](#understanding-firestore-in-pawpal)  
9. [Swift Language Overview](#swift-language-overview)  
10. [Swift Development Guide](#swift-development-guide)  
11. [Navigation in SwiftUI](#navigation-in-swiftui)  
12. [MapKit Tutorial](#mapkit-tutorial)  
13. [Dynamic Visual Elements](#dynamic-visual-elements)  
14. [Known Issues](#known-issues)  
15. [Modules Explained](#modules-explained)  
16. [Data Flow Overview](#data-flow-overview)  
17. [Future Improvements](#future-improvements)  
18. [Additional Learning Resources](#additional-learning-resources)

---

## Overview

PawPal connects local pet owners and rescuers by combining **Firebase authentication** and **Firestore storage** with **SwiftUI and MapKit** for real-time reporting and viewing of lost pets.  

Users can:
- Create an account via email or Google.
- Report lost pets with a name, photo, and map location.
- Browse nearby lost pets.
- Create and view pet profiles.

---

## Tech Stack

| Layer | Technology | Purpose |
|--------|-------------|----------|
| Language | Swift 5.10+ | Core language |
| UI | SwiftUI | Declarative UI |
| Backend | Firebase | Authentication, Firestore, Storage |
| Maps | MapKit | Displays markers and map regions |
| Location | CoreLocation | GPS data |
| Auth Provider | Google Sign-In | OAuth login |
| Bridge | UIKit | Used for `ImagePicker` integration |

---

## Project Structure

```
PawPal/
├── PawPalApp.swift
├── AppDelegate.swift
│
├── Services/
│   └── AuthService.swift
│
├── Views/
│   ├── Home/ (WelcomeView.swift)
│   ├── Main/ (LoginView, RegisterView, MainTabView)
│   ├── Community/ (LostPet*.swift)
│   ├── Profile/ (EnterProfileView, ProfileView)
│   ├── Shared/ (ImagePicker, FlowLayout)
│   └── Map/ (MapView)
│
└── Resources/
    ├── Info.plist
    └── Assets.xcassets
```

---

## Dependencies

| Framework | Purpose |
|------------|----------|
| FirebaseAuth | Authentication |
| Firestore | Database for reports and profiles |
| FirebaseStorage | Image uploads |
| GoogleSignIn | Google OAuth |
| MapKit | Map rendering |
| CoreLocation | GPS tracking |
| SwiftUI | UI framework |
| UIKit | Used in ImagePicker bridging |

---

## App Flow

**1. App Launch (`PawPalApp.swift`)**  
Initializes Firebase and presents `WelcomeView`.

**2. WelcomeView**  
Landing screen with “Get Started” button → navigates to `LoginView`.

**3. LoginView**  
Handles:
- Email/password login  
- Google Sign-In  

If user exists → `MainTabView`  
If new user → `EnterProfileView`

**4. RegisterView**  
Creates Firebase user → `EnterProfileView`

**5. EnterProfileView**  
- Creates pet profile  
- Uploads image to Storage  
- Writes user profile to Firestore (`users/{uid}`)  
→ Navigates to `MainTabView`

**6. MainTabView**
- Tab 1: `LostPetsView` — list of all pets  
- Tab 2: `LostPetMapView` — map visualization  
- Tab 3: `LostPetReportView` — submit a report  

**7. Logout**  
`Auth.auth().signOut()` → returns to `WelcomeView`

---

## Firebase Integration Examples

```swift
// Register
Auth.auth().createUser(withEmail: email, password: password)

// Log in
Auth.auth().signIn(withEmail: email, password: password)

// Firestore write
Firestore.firestore().collection("lost_pets").addDocument(data: [
    "petName": "Bella",
    "description": "Small brown dog",
    "lat": 38.5449,
    "lng": -121.7405,
    "timestamp": FieldValue.serverTimestamp()
])
```

---

## Firestore in Swift Tutorial

Firestore is a **NoSQL document database**.  
It stores data in **collections** (like tables), containing **documents** (like rows), each with **fields** (key-value pairs).

### 1. Setup
```swift
import FirebaseFirestore
let db = Firestore.firestore()
```

### 2. Writing Data
```swift
let data = [
    "petName": "Luna",
    "description": "Gray cat, very shy",
    "lat": 37.7749,
    "lng": -122.4194,
    "timestamp": FieldValue.serverTimestamp()
] as [String : Any]

db.collection("lost_pets").addDocument(data: data)
```

### 3. Reading Data
```swift
db.collection("lost_pets").getDocuments { snapshot, error in
    guard let docs = snapshot?.documents else { return }
    for doc in docs {
        print(doc.documentID, doc.data())
    }
}
```

### 4. Listening for Updates
```swift
db.collection("lost_pets").addSnapshotListener { snapshot, _ in
    guard let docs = snapshot?.documents else { return }
    print("Updated documents: \(docs.count)")
}
```

### 5. Codable Example
```swift
struct LostPet: Codable {
    var petName: String
    var description: String
}
try db.collection("lost_pets").document("pet1").setData(from: LostPet(petName: "Milo", description: "Golden retriever"))
```

---

## Understanding Firestore in PawPal

Firestore is **document-oriented**, not relational.  
Instead of rows and columns, data is stored as **collections → documents → fields**.

Example structure:
```
lost_pets (collection)
│
├── doc_123 (document)
│   ├── petName: "Bella"
│   ├── description: "Small brown dog"
│   ├── lat: 38.5449
│   ├── lng: -121.7405
│   ├── timestamp: 2025-10-26
```

Firestore doesn’t enforce schemas, so consistent naming is important.  
Swift structs map naturally to Firestore fields when using `Codable` or manual mapping.

---

## Swift Language Overview

Official reference:  
[The Swift Programming Language (Swift.org)](https://www.swift.org/documentation/tspl/)

| Keyword | Description |
|----------|-------------|
| `func` | Defines a function. |
| `let` | Constant value. |
| `var` | Mutable variable. |
| `guard` | Validates conditions early and exits if false. |
| `struct` | Defines a value type. |
| `class` | Defines a reference type. |
| `if / else` | Conditional logic. |
| `return` | Exits function. |
| `@State` | Local reactive variable. |
| `@Binding` | Links child view state to parent. |

---

## Swift Development Guide

SwiftUI uses a **declarative approach**: you describe what the UI should look like, not how to draw it.

### Basic View
```swift
struct ProfileView: View {
    var body: some View {
        VStack {
            Image("dog_photo")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            Text("Bella")
                .font(.title)
            Text("Friendly golden retriever")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
```

### Using Guard for Validation
```swift
func registerUser(email: String, password: String) {
    guard !email.isEmpty, !password.isEmpty else {
        print("Email and password cannot be empty")
        return
    }
    Auth.auth().createUser(withEmail: email, password: password)
}
```

### Conditional and Dynamic Views
```swift
if pets.isEmpty {
    Text("No pets available")
} else {
    List(pets) { pet in
        Text(pet.petName)
    }
}
```

### View Types
| Type | Description |
|-------|-------------|
| `VStack` | Vertical layout |
| `HStack` | Horizontal layout |
| `ZStack` | Overlapping layout |
| `ScrollView` | Scrollable container |
| `NavigationStack` | Screen-based navigation |

---

## Navigation in SwiftUI

### Basic Navigation
```swift
NavigationStack {
    NavigationLink("Go to Details", destination: DetailView())
}
```

### Programmatic Navigation
```swift
@State private var goToMain = false

Button("Login") {
    goToMain = true
}
.navigationDestination(isPresented: $goToMain) {
    MainTabView()
}
```

### Nested Navigation
```swift
NavigationStack {
    List(pets) { pet in
        NavigationLink(destination: LostPetDetailView(pet: pet)) {
            Text(pet.petName)
        }
    }
}
```

### Back Navigation
```swift
@Environment(\.dismiss) var dismiss
Button("Back") { dismiss() }
```

### Passing Data Between Views
```swift
struct DetailView: View {
    let pet: LostPet
    var body: some View { Text(pet.petName) }
}
```

---

## MapKit Tutorial

Learn more:  
[Google Maps Swift Codelab](https://developers.google.com/codelabs/maps-platform/maps-platform-101-swift#0)

### Displaying a Map
```swift
@State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
)
Map(coordinateRegion: $region)
```

### Adding Markers
```swift
Map(position: $cameraPosition) {
    ForEach(lostPets) { pet in
        Marker(pet.petName, coordinate: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude))
    }
}
```

---

## Dynamic Visual Elements

```swift
@State private var pets = ["Bella", "Max"]

VStack {
    List(pets, id: \.self) { Text($0) }
    Button("Add Pet") { pets.append("New Pet \(pets.count + 1)") }
}
```

---

## Known Issues

### 1. Truncated Views on iPhone 16 Pro
Some screens appear visually clipped on iPhone 16 Pro due to new safe area insets and Dynamic Island layout changes.  
Planned fix: rework layouts using `.safeAreaInset()` and `.scrollDismissesKeyboard()`.

### 2. Google OAuth Sign-In Intermittently Fails
Occasional authentication failures occur due to:  
- ClientID mismatch  
- Scene delegate timing issues  
- Interrupted network callback  

Temporary workaround: verify `FirebaseApp.app()?.options.clientID` matches your Google Cloud Console config and retry sign-in after a short delay.

---

## Modules Explained

- **Home:** Welcome and onboarding  
- **Main:** Authentication and navigation  
- **Community:** Firestore-powered lost pet system  
- **Profile:** Pet setup and display  
- **Shared:** Reusable SwiftUI components  
- **Map:** Common MapKit logic  

---

## Data Flow Overview

```
WelcomeView → Login/Register → EnterProfileView → MainTabView
  ↓                            ↓
AuthService                Firestore (users)
  ↓                            ↓
MainTabView → LostPetsView / LostPetMapView / LostPetReportView
                         ↓
                   Firestore (lost_pets)
```

---

## Future Improvements
- Safe area fixes for new iPhones  
- OAuth reliability improvements  
- Firestore real-time updates  
- Offline data caching  
- Extended profile editing features  

---

## Additional Learning Resources
- **Swift Language Reference:** [https://www.swift.org/documentation/tspl/](https://www.swift.org/documentation/tspl/)  
- **Apple MapKit Documentation:** [https://developer.apple.com/documentation/mapkit](https://developer.apple.com/documentation/mapkit)  
- **Google Maps Swift Codelab:** [https://developers.google.com/codelabs/maps-platform/maps-platform-101-swift#0](https://developers.google.com/codelabs/maps-platform/maps-platform-101-swift#0)
