import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("home", comment: ""), systemImage: "house.fill")
                }
            TablesView()
                .tabItem {
                    Label(NSLocalizedString("tables", comment: ""), systemImage: "list.bullet.rectangle")
                }
            CustomTableView()
                .tabItem {
                    Label(NSLocalizedString("custom", comment: ""), systemImage: "slider.horizontal.3")
                }
            SettingsView()
                .tabItem {
                    Label(NSLocalizedString("settings", comment: ""), systemImage: "gearshape.fill")
                }
        }
        .accentColor(.cyan)
    }
}
