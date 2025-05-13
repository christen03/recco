//
//  SplashScreen.swift
//  Recco
//
//  Created by Christen Xie on 8/12/24.
//

import SwiftUI
import SpriteKit

enum AuthOptions: Hashable{
    case phone
    case email
}

enum SignUpOrLoginOptions: Hashable {
    case login
    case signup
}

class SceneHolder: ObservableObject {
    @Published var scene: EmojiPhysicsScene?
    private var currentSize: CGSize = .zero
    var maxEmojis: Int

    init(maxEmojis: Int) {
        self.maxEmojis = maxEmojis
    }

    func setupScene(size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }

        if scene == nil {
            self.scene = EmojiPhysicsScene(size: size, maxEmojis: self.maxEmojis)
            self.currentSize = size
        } else if size != self.currentSize {
            self.scene?.updateSceneSize(size)
            self.currentSize = size
        }
    }
}
struct SplashScreenView: View {
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    @StateObject var authNavigation = AuthNavigation()
    @StateObject private var sceneHolder = SceneHolder(maxEmojis: 35)

    @State private var showButton = false

    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $authNavigation.navigationPath) {
                ZStack {
                    // Background layer - z-index 0 (default)
                    ReccoBackgroundText()
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(0)
                    
                    // Emoji animation layer - z-index 1
                    SpriteView(scene: sceneHolder.scene ?? SKScene(size: geometry.size),
                               options: [.allowsTransparency])
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)

                    // Button layer - z-index 2 (on top)
                    VStack {
                        Spacer()
                        NavigationLink(destination: SignUpOrLoginView()) {
                            FontedText("Get Started")
                                .foregroundColor(Colors.ButtonGray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .opacity(0.9)
                                .cornerRadius(25)
                                .padding(.horizontal, 40)
                        }
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeIn(duration: 1.0).delay(0.2), value: showButton)
                        .padding(.bottom, 40) // Add some padding at the bottom
                    }
                    .zIndex(2)
                }
                .ignoresSafeArea() // Apply to the whole ZStack
                .navigationDestination(for: AuthOptions.self) { option in AuthView(authOption: option) }
                .navigationDestination(for: Int.self) { _ in VerificationCodeView() }
                .onAppear {
                    // Use UIScreen bounds to ensure we get full screen size
                    let fullScreenSize = UIScreen.main.bounds.size
                    sceneHolder.setupScene(size: fullScreenSize)

                    let spawnDuration = Double(sceneHolder.maxEmojis) * 0.1
                    let settlingTimeGuess = 2.5
                    let buttonAppearanceDelay = spawnDuration + settlingTimeGuess

                    DispatchQueue.main.asyncAfter(deadline: .now() + buttonAppearanceDelay) {
                        self.showButton = true
                    }
                }
            }
            .environmentObject(authNavigation)
        }
        .ignoresSafeArea() // Apply to the outermost GeometryReader too
    }
}


struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}


#Preview {
    SplashScreenView()
}
