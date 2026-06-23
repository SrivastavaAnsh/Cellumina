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
                    VStack(spacing: 12) {
                        let name = authViewModel.userProfile?.name ?? "Profile"
                        let initials = name.components(separatedBy: .whitespacesAndNewlines)
                            .filter { !$0.isEmpty }
                            .compactMap { $0.first }
                            .prefix(2)
                            .map { String($0) }
                            .joined()
                            .uppercased()
                        
                        ZStack {
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.indigo.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Text(initials.isEmpty ? "P" : initials)
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: 4) {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if let email = email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
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
