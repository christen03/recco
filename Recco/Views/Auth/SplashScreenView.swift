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
                    // Your actual background
                    ReccoBackgroundText()
                        .edgesIgnoringSafeArea(.all)

                    // SpriteKit View for Physics Emojis
                    // Use a default empty scene if sceneHolder.scene is nil initially
                    SpriteView(scene: sceneHolder.scene ?? SKScene(size: geometry.size),
                               options: [.allowsTransparency])
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all) // Let emojis use the whole area


                    // Your "Get Started" Button
                    VStack {
                        Spacer()
                        NavigationLink(destination: SignUpOrLoginView()) { // Placeholder destination
                            FontedText("Get Started") // Placeholder text view
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(25)
                                .padding(.horizontal, 40)
                        }
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeIn(duration: 1.0).delay(0.2), value: showButton)
                    }
                }
                .navigationDestination(for: AuthOptions.self) { option in AuthView(authOption: option) } // Placeholder
                .navigationDestination(for: Int.self) { _ in VerificationCodeView() } // Placeholder
                .onAppear {
                    sceneHolder.setupScene(size: CGSize(width: geometry.size.width*2, height: geometry.size.height*2))

                    // Calculate delay for button appearance
                    // (maxEmojis * spawnInterval) + estimated settling time
                    let spawnDuration = Double(sceneHolder.maxEmojis) * 0.1 // From spawnInterval in EmojiPhysicsScene
                    let settlingTimeGuess = 2.5 // Seconds for emojis to settle
                    let buttonAppearanceDelay = spawnDuration + settlingTimeGuess

                    DispatchQueue.main.asyncAfter(deadline: .now() + buttonAppearanceDelay) {
                        self.showButton = true
                    }
                }
            }
            .environmentObject(authNavigation) // Pass along your actual object
        }
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
