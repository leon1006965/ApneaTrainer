import Foundation
import AVFoundation
import Combine

enum TimerPhase {
    case idle
    case ready
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
    private let readyDuration = 5

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
        startReady()
    }

    func startCustomTimer(holdSeconds: Int, restSeconds: Int, levels: Int) {
        loadSettings()
        let rows = (1...levels).map { TableRow(level: $0, holdSeconds: holdSeconds, restSeconds: restSeconds) }
        self.table = TrainingTable(type: .custom, name: "Custom", rows: rows)
        currentLevel = 0
        startReady()
    }

    private func startReady() {
        guard currentRow != nil else {
            finish()
            return
        }
        phase = .ready
        timeRemaining = readyDuration
        isPaused = false
        lastAnnouncementTime = readyDuration
        startTimer()
    }

    private func startHold() {
        guard let row = currentRow else {
            finish()
            return
        }
        phase = .holding
        timeRemaining = row.holdSeconds
        lastAnnouncementTime = timeRemaining
        isPaused = false
        speakLocalized("start")
        startTimer()
    }

    private func startRest() {
        guard let row = currentRow else {
            finish()
            return
        }
        phase = .resting
        timeRemaining = row.restSeconds
        lastAnnouncementTime = timeRemaining
        speakLocalized("relax")
        speak(timeString(timeRemaining), rate: 0.45, pitch: 0.85, delay: 1.0)
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
        if timeRemaining <= 5 && timeRemaining > 0 {
            speakCountdown(timeRemaining)
        }

        timeRemaining -= 1

        if timeRemaining <= 0 {
            switchPhase()
            return
        }

        if phase != .ready && shouldAnnounce(timeRemaining) {
            speakTime(timeRemaining, isResting: phase == .resting)
            lastAnnouncementTime = timeRemaining
        }
    }

    private func shouldAnnounce(_ seconds: Int) -> Bool {
        return seconds <= lastAnnouncementTime && seconds > 0 && seconds % announcementInterval == 0
    }

    private func switchPhase() {
        switch phase {
        case .ready:
            startHold()
        case .holding:
            startRest()
        case .resting:
            currentLevel += 1
            if currentLevel >= currentTable.count {
                finish()
            } else {
                startHold()
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

    private func speak(_ text: String, rate: Float = 0.45, pitch: Float = 1.0, delay: TimeInterval = 0.1) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voiceForLocale(selectedLanguage)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.preUtteranceDelay = delay
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance)
    }

    private func speakLocalized(_ key: String) {
        speak(L(key))
    }

    private func speakCountdown(_ seconds: Int) {
        let numberWords: [String: [String: String]] = [
            "en": ["1": "one", "2": "two", "3": "three", "4": "four", "5": "five"],
            "pl": ["1": "jeden", "2": "dwa", "3": "trzy", "4": "cztery", "5": "pięć"],
            "sv": ["1": "ett", "2": "två", "3": "tre", "4": "fyra", "5": "fem"],
            "ru": ["1": "один", "2": "два", "3": "три", "4": "четыре", "5": "пять"],
        ]
        let words = numberWords[selectedLanguage] ?? numberWords["en"]!
        let word = words["\(seconds)"] ?? "\(seconds)"
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = voiceForLocale(selectedLanguage)
        utterance.rate = 0.7
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0
        utterance.postUtteranceDelay = 0.05
        synthesizer.speak(utterance)
    }

    private func speakTime(_ seconds: Int, isResting: Bool) {
        let text = localizedTimeString(seconds)
        speak(text, rate: 0.45, pitch: isResting ? 0.85 : 1.0)
    }

    private func speakFinish() {
        speak(L("done_great_job"), rate: 0.5, pitch: 1.1)
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
                return "\(mins) минут \(secs) секунд"
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
