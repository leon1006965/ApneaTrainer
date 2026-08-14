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
            .navigationTitle(NSLocalizedString("settings", comment: ""))
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
            Text(NSLocalizedString("app_language", comment: ""))
        } footer: {
            Text(NSLocalizedString("changes_language", comment: ""))
        }
    }

    private var voiceSection: some View {
        Section {
            Button {
                voiceGender = "female"
            } label: {
                HStack {
                    Label(NSLocalizedString("female_voice", comment: ""), systemImage: "person.fill")
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
                    Label(NSLocalizedString("male_voice", comment: ""), systemImage: "person.fill")
                        .foregroundColor(.primary)
                    Spacer()
                    if voiceGender == "male" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.cyan)
                    }
                }
            }
        } header: {
            Text(NSLocalizedString("countdown_voice", comment: ""))
        } footer: {
            Text(NSLocalizedString("voice_used_for_time_announcements", comment: ""))
        }
    }

    private var announcementSection: some View {
        Section {
            ForEach(intervals, id: \.self) { interval in
                Button {
                    announcementInterval = interval
                } label: {
                    HStack {
                        Text("\(NSLocalizedString("every", comment: "")) \(interval) \(NSLocalizedString("seconds", comment: ""))")
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
            Text(NSLocalizedString("announcement_interval", comment: ""))
        } footer: {
            Text(NSLocalizedString("how_often_voice_announces", comment: ""))
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("apnea_trainer", comment: ""))
                    .font(.headline)
                Text(NSLocalizedString("freediving_breath_hold_training", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(NSLocalizedString("version", comment: "")) 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text(NSLocalizedString("about", comment: ""))
        }
    }
}
