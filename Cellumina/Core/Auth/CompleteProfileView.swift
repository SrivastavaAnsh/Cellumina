import SwiftUI

struct CompleteProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var dateOfBirth: Date = Date()
    
    var isComplete: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !Calendar.current.isDateInToday(dateOfBirth)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)
                } header: {
                    Text("Personal Information")
                } footer: {
                    Text("Please enter your full name as it appears on your official documents.")
                }
                
                Section {
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Contact")
                }
                
                Section {
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                }
            }
            .navigationTitle("Complete Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let dobString = formatter.string(from: dateOfBirth)
                            
                            await authViewModel.updateUserProfile(
                                name: name,
                                phoneNumber: phoneNumber,
                                dateOfBirth: dobString
                            )
                            dismiss()
                        }
                    }
                    .disabled(!isComplete || authViewModel.isLoading)
                }
            }
            .onAppear {
                if let profile = authViewModel.userProfile {
                    name = profile.name ?? ""
                    phoneNumber = profile.phoneNumber ?? ""
                    if let dobString = profile.dateOfBirth {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        if let date = formatter.date(from: dobString) {
                            dateOfBirth = date
                        }
                    }
                }
            }
            .interactiveDismissDisabled(true) // Force user to complete the profile
        }
    }
}

#Preview {
    CompleteProfileView()
        .environment(AuthViewModel())
}
