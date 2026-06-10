import SwiftUI
import FirebaseFirestore

struct EditLostPetView: View {
    let pet: LostPet
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var petName: String
    @State private var petNotes: String
    @State private var primaryColor: String
    @State private var secondaryColor: String
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let primaryColorOptions = ["black", "white", "brown"]
    let secondaryColorOptions = ["none", "black", "white", "brown"]
    
    init(pet: LostPet) {
        self.pet = pet
        _petName = State(initialValue: pet.petName)
        _petNotes = State(initialValue: pet.description)
        _primaryColor = State(initialValue: pet.primaryColor ?? "")
        _secondaryColor = State(initialValue: pet.secondaryColor ?? "")
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pet Name")
                            .font(.headline)
                        
                        TextField("Pet name", text: $petName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Color")
                            .font(.headline)
                        
                        Picker(selection: $primaryColor) {
                            Text("Select a color").tag("")
                            
                            ForEach(primaryColorOptions, id: \.self) { color in
                                Text(color.capitalized).tag(color)
                            }
                        } label: {
                            Text(primaryColor.isEmpty ? "Select a color" : primaryColor.capitalized)
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Secondary Color")
                            .font(.headline)
                        
                        Picker(selection: $secondaryColor) {
                            Text("Select a color").tag("")
                            
                            ForEach(secondaryColorOptions, id: \.self) { color in
                                Text(color.capitalized).tag(color)
                            }
                        } label: {
                            Text(secondaryColor.isEmpty ? "Select a color" : secondaryColor.capitalized)
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextField("Distinct markings, personality, or other helpful notes...", text: $petNotes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: saveChanges) {
                        Text(isSaving ? "Saving..." : "Save Changes")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.theme.babyBlue)
                            .foregroundColor(.white)
                            .cornerRadius(28)
                    }
                    .disabled(isSaving)
                }
                .padding()
            }
        }
        .navigationTitle("Edit Lost Pet")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Update Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage == "Lost pet report updated successfully." {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveChanges() {
        guard let petId = pet.id else {
            alertMessage = "Unable to update this report because the pet ID is missing."
            showAlert = true
            return
        }
        
        isSaving = true
        
        let updatedData: [String: Any] = [
            FS.LostPets.petName: petName,
            FS.LostPets.description: petNotes,
            FS.LostPets.primaryColor: primaryColor,
            FS.LostPets.secondaryColor: secondaryColor
        ]
        
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .document(petId)
            .updateData(updatedData) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    
                    if let error = error {
                        alertMessage = "Failed to update: \(error.localizedDescription)"
                    } else {
                        alertMessage = "Lost pet report updated successfully."
                    }
                    
                    showAlert = true
                }
            }
    }
}
