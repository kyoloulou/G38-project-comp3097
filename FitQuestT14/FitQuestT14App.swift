import SwiftUI

@main
struct FitQuestT14App: App {
    @StateObject private var store = WorkoutStore()
    @StateObject private var auth  = AuthStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(auth)
        }
    }
}
