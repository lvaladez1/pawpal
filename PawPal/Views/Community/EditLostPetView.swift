//
//  EditLostPetView.swift
//  PawPal
//
//  Created by Mariah Stinson on 6/9/26.
//

import SwiftUI
import FirebaseFirestore

struct EditLostPetView: View {
    let pet: LostPet
    let onSave: ((LostPet) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var petName: String
    @State private var petNotes: String
    @State private var size: String
    @State private var markings: String
    @State private var coatLength: String
    @State private var earType: String
    @State private var tailType: String
    @State private var primaryColor: String
    @State private var secondaryColor: String
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let sizeOptions = ["Small", "Medium", "Large"]
    private let colorOptions = ["Black", "White", "Brown", "Tan", "Black & White", "Gray", "Golden", "Other"]
    private let secondaryColorOptions = ["None", "Black", "White", "Brown", "Tan", "Black & White", "Gray", "Golden", "Other"]
    private let markingOptions = ["White chest", "White paws", "Spotted", "Black mask", "Brindle", "Merle", "Other", "Unknown"]
    private let coatOptions = ["Short", "Medium", "Long"]
    private let earOptions = ["Erect", "Semi-erect", "Floppy"]
    private let tailOptions = ["Whip tail", "Furry tail", "Curled", "No tail", "Unknown"]
    
    init(pet: LostPet, onSave: ((LostPet) -> Void)? = nil) {
        self.pet = pet
        self.onSave = onSave
        _petName = State(initialValue: pet.petName)
        _petNotes = State(initialValue: pet.description)
        _size = State(initialValue: pet.size)
        _markings = State(initialValue: pet.markings)
        _coatLength = State(initialValue: pet.coatLength)
        _earType = State(initialValue: pet.earType)
        _tailType = State(initialValue: pet.tailType)
        _primaryColor = State(initialValue: pet.primaryColor ?? "")
        _secondaryColor = State(initialValue: pet.secondaryColor ?? "")
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    editableTextField(
                        title: "Pet Name",
                        placeholder: "Pet name",
                        text: $petName
                    )
                    
                    editableDropdown(
                        title: "Size",
                        placeholder: "Select a size",
                        selection: $size,
                        options: sizeOptions
                    )
                    
                    editableDropdown(
                        title: "Primary Color",
                        placeholder: "Select a primary color",
                        selection: $primaryColor,
                        options: colorOptions
                    )
                    
                    editableDropdown(
                        title: "Secondary Color",
                        placeholder: "Select a secondary color",
                        selection: $secondaryColor,
                        options: secondaryColorOptions
                    )
                    
                    editableDropdown(
                        title: "Markings",
                        placeholder: "Select markings",
                        selection: $markings,
                        options: markingOptions
                    )
                    
                    editableDropdown(
                        title: "Coat Length",
                        placeholder: "Select coat length",
                        selection: $coatLength,
                        options: coatOptions
                    )
                    
                    editableDropdown(
                        title: "Ear Type",
                        placeholder: "Select ear type",
                        selection: $earType,
                        options: earOptions
                    )
                    
                    editableDropdown(
                        title: "Tail Type",
                        placeholder: "Select tail type",
                        selection: $tailType,
                        options: tailOptions
                    )
                    
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
    
    private func editableTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    
    private func editableDropdown(title: String, placeholder: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Picker(selection: selection) {
                Text(placeholder)
                    .tag("")
                
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .tag(option)
                }
            } label: {
                Text(selection.wrappedValue.isEmpty ? placeholder : selection.wrappedValue)
            }
            .pickerStyle(.menu)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    private func saveChanges() {
        guard pet.userId == authVM.user?.uid else {
            alertMessage = "You can only edit lost pet reports that you created."
            showAlert = true
            return
        }
        
        let petId = pet.id
        
        isSaving = true
        
        let updatedData: [String: Any] = [
            "petName": petName,
            "description": petNotes,
            "size": size,
            "primaryColor": primaryColor,
            "secondaryColor": secondaryColor,
            "markings": markings,
            "coatLength": coatLength,
            "earType": earType,
            "tailType": tailType
        ]
        
        print("Pet ID:", petId)
        print("Updated data:", updatedData)
        
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .document(petId)
            .updateData(updatedData) { error in
                DispatchQueue.main.async {
                    isSaving = false
                    
                    if let error = error {
                        alertMessage = "Failed to update: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    
                    let updatedPet = LostPet(
                        id: pet.id,
                        petName: petName,
                        size: size,
                        markings: markings,
                        coatLength: coatLength,
                        earType: earType,
                        tailType: tailType,
                        description: petNotes,
                        latitude: pet.latitude,
                        longitude: pet.longitude,
                        timestamp: pet.timestampDate,
                        userId: pet.userId,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor
                    )
                    
                    onSave?(updatedPet)
                    
                    alertMessage = "Lost pet report updated successfully."
                    showAlert = true
                }
            }
    }
}
