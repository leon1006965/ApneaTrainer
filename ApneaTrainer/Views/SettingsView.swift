import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("voiceGender") private var voiceGender = "female"
    @AppStorage("announcementInterval") private var announcementInterval = 10

    let languages = [
        ("en", "English", "🇺🇸"),
        ("pl", "Polish", "🇵🇱"),
        ("sv", "Swedish", "🇸🇪"),
        ("ru", "Russian", "🇷🇺"),
    ]

    let intervals = [5, 10, 15, 20, 30]

    var body: some View {
        NavigationView {
            Form {
                languageSection
                voiceSection
                announcementSection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    private var languageSection: some View {
        Section {
            ForEach(languages, id: \.0) { code, name, flag in
                Button {
                    appLanguage = code
                } label: {
                    HStack {
                        Text(flag + " " + name)
                            .foregroundColor(.primary)
                        Spacer()
                        if appLanguage == code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                        }
                    }
                }
            }
        } header: {
            Text("App Language")
        } footer: {
            Text("Changes the app interface language")
        }
    }

    private var voiceSection: some View {
        Section {
            Button {
                voiceGender = "female"
            } label: {
                HStack {
                    Label("Female Voice", systemImage: "person.fill")
                        .foregroundColor(.primary)
                    Spacer()
                    if voiceGender == "female" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.cyan)
                    }
                }
            }

            Button {
                voiceGender = "male"
            } label: {
                HStack {
                    Label("Male Voice", systemImage: "person.fill")
                        .foregroundColor(.primary)
                    Spacer()
                    if voiceGender == "male" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.cyan)
                    }
                }
            }
        } header: {
            Text("Countdown Voice")
        } footer: {
            Text("Voice used for time announcements during training")
        }
    }

    private var announcementSection: some View {
        Section {
            ForEach(intervals, id: \.self) { interval in
                Button {
                    announcementInterval = interval
                } label: {
                    HStack {
                        Text("Every \(interval) seconds")
                            .foregroundColor(.primary)
                        Spacer()
                        if announcementInterval == interval {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                        }
                    }
                }
            }
        } header: {
            Text("Announcement Interval")
        } footer: {
            Text("How often the voice announces remaining time (e.g., every 10 seconds: 30s, 20s, 10s)")
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Apnea Trainer")
                    .font(.headline)
                Text("A freediving breath-hold training app")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("About")
        }
    }
}
