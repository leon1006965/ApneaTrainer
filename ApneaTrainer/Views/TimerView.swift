import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    var table: TrainingTable?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 30) {
                headerSection

                Spacer()

                timerDisplay

                Spacer()

                levelInfo

                controlsSection

                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            timerManager.loadSettings()
            if timerManager.phase == .idle, let table = table {
                timerManager.startTable(table)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                backgroundColor.opacity(0.3),
                backgroundColor.opacity(0.1),
                Color(.systemBackground)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        HStack {
            Button {
                timerManager.stop()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(phaseText)
                .font(.headline)
                .foregroundColor(phaseColor)
            Spacer()
            Button {
                if timerManager.isPaused {
                    timerManager.resume()
                } else {
                    timerManager.pause()
                }
            } label: {
                Image(systemName: timerManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(.cyan)
            }
        }
    }

    private var timerDisplay: some View {
        VStack(spacing: 8) {
            Text(timerManager.timeString(timerManager.timeRemaining))
                .font(.system(size: 60, weight: .light, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()

            Text("\(timerManager.timeRemaining) \(NSLocalizedString("seconds", comment: ""))")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            Circle()
                .fill(phaseColor.opacity(0.1))
                .frame(width: 220, height: 220)
        )
    }

    private var levelInfo: some View {
        VStack(spacing: 8) {
            if let row = timerManager.currentRow {
                HStack(spacing: 20) {
                    VStack {
                        Text(NSLocalizedString("level", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(row.level)/\(timerManager.totalLevels)")
                            .font(.title3.bold())
                    }
                    VStack {
                        Text(NSLocalizedString("hold", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTime(row.holdSeconds))
                            .font(.title3.bold())
                    }
                    VStack {
                        Text(NSLocalizedString("rest_label", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTime(row.restSeconds))
                            .font(.title3.bold())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            }
        }
    }

    private var controlsSection: some View {
        HStack(spacing: 30) {
            if timerManager.phase != .finished {
                Button {
                    timerManager.stop()
                    dismiss()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                        Text(NSLocalizedString("stop", comment: ""))
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
                }
            }

            if timerManager.phase == .finished {
                Button {
                    timerManager.reset()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                        Text(NSLocalizedString("restart", comment: ""))
                            .font(.caption)
                    }
                    .foregroundColor(.cyan)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.cyan.opacity(0.1))
                    )
                }
            }

            Button {
                timerManager.stop()
                dismiss()
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                    Text(NSLocalizedString("home", comment: ""))
                        .font(.caption)
                }
                .foregroundColor(.blue)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            }
        }
    }

    private var phaseText: String {
        switch timerManager.phase {
        case .idle: return NSLocalizedString("ready", comment: "")
        case .countdown: return NSLocalizedString("get_ready", comment: "")
        case .holding: return NSLocalizedString("hold_your_breath", comment: "")
        case .resting: return NSLocalizedString("rest", comment: "")
        case .finished: return NSLocalizedString("completed", comment: "")
        }
    }

    private var phaseColor: Color {
        switch timerManager.phase {
        case .idle: return .gray
        case .countdown: return .orange
        case .holding: return .cyan
        case .resting: return .green
        case .finished: return .purple
        }
    }

    private var backgroundColor: Color {
        switch timerManager.phase {
        case .holding: return .cyan
        case .resting: return .green
        default: return .gray
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m):\(String(format: "%02d", s))" : "\(s)s"
    }
}
