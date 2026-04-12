import SwiftUI

@main
struct FitQuestT14App: App {
    @StateObject private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(auth.store)
        }
    }
}
