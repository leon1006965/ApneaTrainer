import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            TablesView()
                .tabItem {
                    Label("Tables", systemImage: "list.bullet.rectangle")
                }
            CustomTableView()
                .tabItem {
                    Label("Custom", systemImage: "slider.horizontal.3")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.cyan)
    }
}
