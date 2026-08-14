import SwiftUI

@main
struct ApneaTrainerApp: App {
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: appLanguage))
        }
    }
}
