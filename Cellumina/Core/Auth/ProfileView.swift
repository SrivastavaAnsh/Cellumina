import SwiftUI
import Supabase

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(UIConstants.accent, UIConstants.card)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.userProfile?.name ?? "Cellumina Explorer")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if let email = email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Personal Information") {
                    if let phone = authViewModel.userProfile?.phoneNumber, !phone.isEmpty {
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(phone)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let dob = authViewModel.userProfile?.dateOfBirth, !dob.isEmpty {
                        HStack {
                            Text("Date of Birth")
                            Spacer()
                            Text(dob)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if (authViewModel.userProfile?.phoneNumber ?? "").isEmpty && (authViewModel.userProfile?.dateOfBirth ?? "").isEmpty {
                        Text("No additional details provided.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                do {
                    let session = try await SupabaseManager.shared.client.auth.session
                    self.email = session.user.email
                } catch {
                    print("Could not fetch session email: \(error)")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
}
