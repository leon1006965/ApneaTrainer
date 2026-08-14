import SwiftUI

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(L("home"), systemImage: "house.fill")
                }
            TablesView()
                .tabItem {
                    Label(L("tables"), systemImage: "list.bullet.rectangle")
                }
            CustomTableView()
                .tabItem {
                    Label(L("custom"), systemImage: "slider.horizontal.3")
                }
            SettingsView()
                .tabItem {
                    Label(L("settings"), systemImage: "gearshape.fill")
                }
        }
        .accentColor(.cyan)
        .id(appLanguage)
    }
}
