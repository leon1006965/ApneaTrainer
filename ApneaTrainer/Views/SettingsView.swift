import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("voiceGender") private var voiceGender = "female"
    @AppStorage("announcementInterval") private var announcementInterval = 10

    let languages = [
        ("en", "English", "🇺🇸"),
        ("pl", "Polski", "🇵🇱"),
        ("sv", "Svenska", "🇸🇪"),
        ("ru", "Русский", "🇷🇺"),
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
            .navigationTitle(L("settings"))
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
            Text(L("app_language"))
        } footer: {
            Text(L("changes_language"))
        }
    }

    private var voiceSection: some View {
        Section {
            Button {
                voiceGender = "female"
            } label: {
                HStack {
                    Label(L("female_voice"), systemImage: "person.fill")
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
                    Label(L("male_voice"), systemImage: "person.fill")
                        .foregroundColor(.primary)
                    Spacer()
                    if voiceGender == "male" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.cyan)
                    }
                }
            }
        } header: {
            Text(L("countdown_voice"))
        } footer: {
            Text(L("voice_used_for_time_announcements"))
        }
    }

    private var announcementSection: some View {
        Section {
            ForEach(intervals, id: \.self) { interval in
                Button {
                    announcementInterval = interval
                } label: {
                    HStack {
                        Text("\(L("every")) \(interval) \(L("seconds"))")
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
            Text(L("announcement_interval"))
        } footer: {
            Text(L("how_often_voice_announces"))
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(L("apnea_trainer"))
                    .font(.headline)
                Text(L("freediving_breath_hold_training"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(L("version")) 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text(L("about"))
        }
    }
}
