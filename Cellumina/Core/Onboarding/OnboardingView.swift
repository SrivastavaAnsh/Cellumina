import SwiftUI

struct OrganicBackground: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                
                // Floating "cell" shapes using blurred circles
                Circle()
                    .fill(UIConstants.accent.opacity(0.2))
                    .frame(width: width * 0.8)
                    .blur(radius: 60)
                    .offset(x: isAnimating ? width * 0.4 : -width * 0.2,
                            y: isAnimating ? -height * 0.2 : height * 0.3)
                
                Circle()
                    .fill(UIConstants.accent.opacity(0.15))
                    .frame(width: width * 0.6)
                    .blur(radius: 50)
                    .offset(x: isAnimating ? -width * 0.3 : width * 0.5,
                            y: isAnimating ? height * 0.4 : -height * 0.1)
                
                Circle()
                    .fill(UIConstants.accent.opacity(0.1))
                    .frame(width: width * 0.9)
                    .blur(radius: 80)
                    .offset(x: isAnimating ? width * 0.1 : -width * 0.4,
                            y: isAnimating ? height * 0.1 : height * 0.5)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            OrganicBackground()
            
            TabView(selection: $selectedTab) {
                OnboardingSlide(
                    systemImageName: nil,
                    assetImageName: "OnboardingLogo",
                    title: "Welcome to Cellumina",
                    description: "Explore the microscopic world like never before. Dive deep into the building blocks of life."
                )
                .tag(0)
                
                OnboardingSlide(
                    systemImageName: "aqi.medium",
                    title: "Amoeba Lab",
                    description: "Interact with an Amoeba in a physics-based interactive sandbox."
                )
                .tag(1)
                
                OnboardingSlide(
                    systemImageName: "point.3.connected.trianglepath.dotted",
                    title: "Cell Network",
                    description: "Understand how cells communicate and transmit signals in complex networks."
                )
                .tag(2)
                
                OnboardingSlide(
                    systemImageName: "sparkles",
                    title: "AI Tutor",
                    description: "Learn biology with the help of powerful foundation models acting as your personal tutor.",
                    showButton: true,
                    buttonAction: {
                        Haptics.success()
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    }
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onChange(of: selectedTab) {
                Haptics.tap()
            }
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(UIConstants.accent)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
            }
        }
    }
}

struct OnboardingSlide: View {
    var systemImageName: String? = nil
    var assetImageName: String? = nil
    let title: String
    let description: String
    var showButton: Bool = false
    var buttonAction: (() -> Void)? = nil
    
    @State private var isAnimating = false
    
    @ViewBuilder
    var iconView: some View {
        Group {
            if let assetImageName = assetImageName {
                Image(assetImageName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.4) // Scale up to compensate for any transparent padding in the PNG
            } else if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: 150, height: 150)
        .foregroundColor(UIConstants.accent)
        .padding(30)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .shadow(color: UIConstants.shadow.opacity(0.5), radius: 15, x: 0, y: 10)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            iconView
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .offset(y: isAnimating ? -10 : 10)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            if showButton {
                Button(action: {
                    Haptics.success()
                    buttonAction?()
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(UIConstants.accent)
                        .cornerRadius(UIConstants.corner)
                        .shadow(color: UIConstants.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            } else {
                Spacer().frame(height: 100)
            }
        }
        .padding()
        // Container to limit width on iPad, adding a nice card feel
        .frame(maxWidth: 600)
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
