import Foundation
import Supabase
import Observation
import AuthenticationServices
import UIKit

struct UserProfile: Codable, Equatable {
    let id: UUID
    let name: String?
    let phoneNumber: String?
    let dateOfBirth: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber = "phone_number"
        case dateOfBirth = "date_of_birth"
    }
}

class AuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first ?? UIWindow()
    }
}

@Observable
@MainActor
class AuthViewModel {
    var isAuthenticated = false
    var userProfile: UserProfile?
    var isLoading = false
    var errorMessage: String?
    
    private var authContextProvider = AuthPresentationContextProvider()
    
    init() {
        Task {
            for await (event, session) in SupabaseManager.shared.client.auth.authStateChanges {
                if [.initialSession, .signedIn, .tokenRefreshed].contains(event) {
                    self.isAuthenticated = session != nil
                    if let user = session?.user {
                        await fetchUserProfile(userId: user.id)
                    }
                } else if event == .signedOut {
                    self.isAuthenticated = false
                    self.userProfile = nil
                }
            }
        }
    }
    
    func fetchUserProfile(userId: UUID) async {
        do {
            let profile: UserProfile = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            self.userProfile = profile
        } catch {
            print("Error fetching user profile: \(error)")
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func signUp(email: String, password: String, name: String, dob: Date, phoneNumber: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dobString = formatter.string(from: dob)
            
            let profile = UserProfile(id: response.user.id, name: name, phoneNumber: phoneNumber, dateOfBirth: dobString)
            
            try await SupabaseManager.shared.client
                .from("users")
                .upsert(profile)
                .execute()
                
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async {
        isLoading = true
        errorMessage = nil
        do {
            try await SupabaseManager.shared.client.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce))
            
            if let name = fullName {
                let nameString = [name.givenName, name.familyName].compactMap { $0 }.joined(separator: " ")
                if !nameString.isEmpty, let userId = try? await SupabaseManager.shared.client.auth.session.user.id {
                    let profile = UserProfile(id: userId, name: nameString, phoneNumber: nil, dateOfBirth: nil)
                    try? await SupabaseManager.shared.client.from("users").upsert(profile).execute()
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func startGoogleSignIn() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let url = try await SupabaseManager.shared.client.auth.getOAuthSignInURL(
                    provider: .google,
                    redirectTo: URL(string: "cellumina://auth-callback")
                )
                
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "cellumina") { [weak self] callbackURL, error in
                    guard let self = self else { return }
                    if let error = error {
                        Task { @MainActor in
                            self.isLoading = false
                            if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                                self.errorMessage = error.localizedDescription
                            }
                        }
                        return
                    }
                    if let callbackURL = callbackURL {
                        Task {
                            do {
                                try await SupabaseManager.shared.client.auth.session(from: callbackURL)
                                await MainActor.run { self.isLoading = false }
                            } catch {
                                await MainActor.run {
                                    self.isLoading = false
                                    self.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
                }
                
                session.presentationContextProvider = authContextProvider
                session.start()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func updateUserProfile(name: String, phoneNumber: String, dateOfBirth: String) async {
        var currentUserId = userProfile?.id
        if currentUserId == nil {
            currentUserId = try? await SupabaseManager.shared.client.auth.session.user.id
        }
        guard let userId = currentUserId else { return }
        isLoading = true
        errorMessage = nil
        do {
            let profile = UserProfile(id: userId, name: name, phoneNumber: phoneNumber, dateOfBirth: dateOfBirth)
            try await SupabaseManager.shared.client
                .from("users")
                .upsert(profile)
                .execute()
            
            await fetchUserProfile(userId: userId)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
