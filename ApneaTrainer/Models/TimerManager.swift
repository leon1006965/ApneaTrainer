import Foundation
import AVFoundation
import Combine

enum TimerPhase {
    case idle
    case countdown
    case holding
    case resting
    case finished
}

class TimerManager: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var currentLevel = 0
    @Published var timeRemaining = 0
    @Published var isPaused = false
    @Published var announcementInterval = 10
    @Published var voiceGender: VoiceGender = .female
    @Published var selectedLanguage: String = "en"

    var table: TrainingTable?
    private var timer: Timer?
    private var lastAnnouncementTime = 0
    private let synthesizer = AVSpeechSynthesizer()

    enum VoiceGender: String, CaseIterable {
        case female = "Female"
        case male = "Male"
    }

    var currentTable: [TableRow] {
        table?.rows ?? []
    }

    var totalLevels: Int {
        currentTable.count
    }

    var currentRow: TableRow? {
        guard currentLevel < currentTable.count else { return nil }
        return currentTable[currentLevel]
    }

    func loadSettings() {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        selectedLanguage = lang
        let gender = UserDefaults.standard.string(forKey: "voiceGender") ?? "female"
        voiceGender = gender == "male" ? .male : .female
        let interval = UserDefaults.standard.integer(forKey: "announcementInterval")
        announcementInterval = interval > 0 ? interval : 10
    }

    func startTable(_ table: TrainingTable) {
        loadSettings()
        self.table = table
        currentLevel = 0
        startLevel()
    }

    func startCustomTimer(holdSeconds: Int, restSeconds: Int, levels: Int) {
        loadSettings()
        let rows = (1...levels).map { TableRow(level: $0, holdSeconds: holdSeconds, restSeconds: restSeconds) }
        self.table = TrainingTable(type: .custom, name: "Custom", rows: rows)
        currentLevel = 0
        startLevel()
    }

    private func startLevel() {
        guard let row = currentRow else {
            finish()
            return
        }
        phase = .holding
        timeRemaining = row.holdSeconds
        lastAnnouncementTime = timeRemaining
        isPaused = false
        speakTime(timeRemaining, isResting: false)
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            DispatchQueue.main.async {
                self.tick()
            }
        }
    }

    private func tick() {
        timeRemaining -= 1

        if timeRemaining <= 0 {
            switchPhase()
            return
        }

        if shouldAnnounce(timeRemaining) {
            speakTime(timeRemaining, isResting: phase == .resting)
            lastAnnouncementTime = timeRemaining
        }
    }

    private func shouldAnnounce(_ seconds: Int) -> Bool {
        return seconds <= lastAnnouncementTime && seconds > 0 && seconds % announcementInterval == 0
    }

    private func switchPhase() {
        switch phase {
        case .holding:
            guard let row = currentRow else { finish(); return }
            phase = .resting
            timeRemaining = row.restSeconds
            lastAnnouncementTime = timeRemaining
            speakRestStart(row.restSeconds)
        case .resting:
            currentLevel += 1
            if currentLevel >= currentTable.count {
                finish()
            } else {
                startLevel()
            }
        default:
            break
        }
    }

    private func finish() {
        phase = .finished
        timer?.invalidate()
        timer = nil
        speakFinish()
    }

    func pause() {
        isPaused = true
        timer?.invalidate()
    }

    func resume() {
        isPaused = false
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        phase = .idle
        currentLevel = 0
        timeRemaining = 0
        isPaused = false
        synthesizer.stopSpeaking(at: .immediate)
    }

    func reset() {
        stop()
        if let table = table {
            startTable(table)
        }
    }

    private func speakTime(_ seconds: Int, isResting: Bool) {
        let text = localizedTimeString(seconds)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceForLocale(selectedLanguage)
        utterance.rate = 0.45
        utterance.pitchMultiplier = isResting ? 0.9 : 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.3
        synthesizer.speak(utterance)
    }

    private func speakRestStart(_ seconds: Int) {
        let text: String
        switch selectedLanguage {
        case "pl":
            text = "Odpoczynek \(timeString(seconds))"
        case "sv":
            text = "Vila \(timeString(seconds))"
        case "ru":
            text = "Отдых \(timeString(seconds))"
        default:
            text = "Rest \(timeString(seconds))"
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceForLocale(selectedLanguage)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.85
        utterance.preUtteranceDelay = 0.2
        synthesizer.speak(utterance)
    }

    private func speakFinish() {
        let text: String
        switch selectedLanguage {
        case "pl":
            text = "Gotowe! Świetna robota!"
        case "sv":
            text = "Klart! Bra jobbat!"
        case "ru":
            text = "Готово! Отличная работа!"
        default:
            text = "Done! Great job!"
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceForLocale(selectedLanguage)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        synthesizer.speak(utterance)
    }

    private func localizedTimeString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        switch selectedLanguage {
        case "pl":
            if mins > 0 {
                return "\(mins) minut\(mins == 1 ? "a" : "") \(secs) sekund\(secs == 1 ? "a" : "")"
            }
            return "\(secs) sekund\(secs == 1 ? "a" : "")"
        case "sv":
            if mins > 0 {
                return "\(mins) minut\(mins == 1 ? "" : "er") \(secs) sekund\(secs == 1 ? "" : "er")"
            }
            return "\(secs) sekund\(secs == 1 ? "" : "er")"
        case "ru":
            if mins > 0 {
                return "\(mins) минут\(secs) секунд"
            }
            return "\(secs) секунд"
        default:
            if mins > 0 {
                return "\(mins) minute\(mins == 1 ? "" : "s") \(secs) second\(secs == 1 ? "" : "s")"
            }
            return "\(secs) second\(secs == 1 ? "" : "s")"
        }
    }

    private func voiceForLocale(_ locale: String) -> AVSpeechSynthesisVoice? {
        let localeMap: [String: [String]] = [
            "en": ["en-US", "en-GB", "en-AU"],
            "pl": ["pl-PL"],
            "sv": ["sv-SE"],
            "ru": ["ru-RU"],
        ]

        let locales = localeMap[locale] ?? ["en-US"]
        for loc in locales {
            if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: {
                $0.language == loc && $0.quality == .enhanced
            }) {
                return voice
            }
            if let voice = AVSpeechSynthesisVoice(language: loc) {
                return voice
            }
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    func timeString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return "\(mins):\(String(format: "%02d", secs))"
        }
        return "\(secs)s"
    }
}
