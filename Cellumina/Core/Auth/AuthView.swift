import SwiftUI
import AuthenticationServices
import CryptoKit

struct AuthView: View {
    @State private var isSignUp = false
    
    // Sign In/Up Fields
    @State private var email = ""
    @State private var password = ""
    
    // Additional Sign Up Fields
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var dob = Date()
    
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var currentNonce: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "aqi.medium")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(UIConstants.accent)
                        
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isSignUp ? "Join Cellumina today" : "Sign in to continue exploring")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                    
                    // Form
                    VStack(spacing: 16) {
                        if isSignUp {
                            // Extra fields for sign up
                            customTextField(placeholder: "Full Name", text: $name, icon: "person")
                            
                            DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                                .padding()
                                .background(UIConstants.card)
                                .cornerRadius(UIConstants.corner)
                                .overlay(
                                    RoundedRectangle(cornerRadius: UIConstants.corner)
                                        .stroke(UIConstants.stroke, lineWidth: 1)
                                )
                            
                            customTextField(placeholder: "Phone Number", text: $phoneNumber, icon: "phone", keyboardType: .phonePad)
                        }
                        
                        customTextField(placeholder: "Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            SecureField("Password", text: $password)
                        }
                        .padding()
                        .background(UIConstants.card)
                        .cornerRadius(UIConstants.corner)
                        .overlay(
                            RoundedRectangle(cornerRadius: UIConstants.corner)
                                .stroke(UIConstants.stroke, lineWidth: 1)
                        )
                    }
                    
                    // Error Message
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Main Action Button
                    Button {
                        Task {
                            if isSignUp {
                                await authViewModel.signUp(email: email, password: password, name: name, dob: dob, phoneNumber: phoneNumber)
                            } else {
                                await authViewModel.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isSignUp ? "Sign Up" : "Sign In")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(UIConstants.accent)
                        .foregroundColor(.white)
                        .cornerRadius(UIConstants.corner)
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty || (isSignUp && (name.isEmpty || phoneNumber.isEmpty)))
                    
                    // Toggle Sign In / Sign Up
                    Button {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundStyle(UIConstants.accent)
                    }
                    
                    // Dividers
                    HStack {
                        VStack { Divider() }
                        Text("OR").font(.caption).foregroundStyle(.secondary)
                        VStack { Divider() }
                    }
                    .padding(.vertical)
                    
                    // Social Login
                    VStack(spacing: 16) {
                        SignInWithAppleButton(.signIn) { request in
                            let nonce = randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                   let nonce = currentNonce,
                                   let appleIDToken = appleIDCredential.identityToken,
                                   let idTokenString = String(data: appleIDToken, encoding: .utf8) {
                                    
                                    Task {
                                        await authViewModel.signInWithApple(idToken: idTokenString, nonce: nonce, fullName: appleIDCredential.fullName)
                                    }
                                }
                            case .failure(let error):
                                print("Apple Sign In failed: \(error)")
                            }
                        }
                        .frame(height: 50)
                        .signInWithAppleButtonStyle(.black)
                        .cornerRadius(UIConstants.corner)
                        
                        Button {
                            authViewModel.startGoogleSignIn()
                        } label: {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                Text("Sign in with Google")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(UIConstants.corner)
                            .overlay(
                                RoundedRectangle(cornerRadius: UIConstants.corner)
                                    .stroke(UIConstants.stroke, lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(UIConstants.pad)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    // Helper view for text fields
    private func customTextField(placeholder: String, text: Binding<String>, icon: String, keyboardType: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(UIConstants.card)
        .cornerRadius(UIConstants.corner)
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.corner)
                .stroke(UIConstants.stroke, lineWidth: 1)
        )
    }
}

// MARK: - Crypto Helpers
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce.")
            }
            return random
        }
        randoms.forEach { random in
            if remainingLength == 0 { return }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    return hashString
}

#Preview {
    AuthView()
        .environment(AuthViewModel())
}
