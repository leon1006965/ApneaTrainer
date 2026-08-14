import SwiftUI

struct CustomTableView: View {
    @StateObject private var store = TableStore()
    @StateObject private var timerManager = TimerManager()
    @State private var tableName = ""
    @State private var holdMinutes = 1
    @State private var holdSeconds = 0
    @State private var restMinutes = 1
    @State private var restSeconds = 0
    @State private var levels = 10
    @State private var showTimer = false
    @State private var showSaveAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    customBuilderSection

                    savedTablesSection
                }
                .padding()
            }
            .navigationTitle("Custom Table")
            .sheet(isPresented: $showTimer) {
                TimerView(timerManager: timerManager, table: nil)
            }
            .alert("Save Table", isPresented: $showSaveAlert) {
                TextField("Table name", text: $tableName)
                Button("Save") {
                    saveTable()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for your custom table")
            }
        }
    }

    private var customBuilderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Build Your Table")
                .font(.title2.bold())

            VStack(spacing: 12) {
                timePicker(label: "Hold Time", minutes: $holdMinutes, seconds: $holdSeconds)
                timePicker(label: "Rest Time", minutes: $restMinutes, seconds: $restSeconds)

                Stepper("Levels: \(levels)", value: $levels, in: 1...100)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }

            HStack(spacing: 12) {
                Button {
                    showSaveAlert = true
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                        .foregroundColor(.white)
                        .font(.headline)
                }

                Button {
                    startTraining()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cyan)
                        )
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }

    private var savedTablesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Tables")
                .font(.title2.bold())

            if store.customTables.isEmpty {
                Text("No saved tables yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(store.customTables) { table in
                    savedTableRow(table)
                }
                .onDelete { offsets in
                    store.deleteCustomTable(at: offsets)
                }
            }
        }
    }

    private func timePicker(label: String, minutes: Binding<Int>, seconds: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
            HStack(spacing: 12) {
                VStack {
                    Text("Min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("", selection: minutes) {
                        ForEach(0...59, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }
                Text(":")
                    .font(.title.bold())
                    .foregroundColor(.secondary)
                VStack {
                    Text("Sec")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("", selection: seconds) {
                        ForEach(0...59, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private func savedTableRow(_ table: TrainingTable) -> some View {
        Button {
            startTable(table)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(table.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(table.rows.count) levels - Hold: \(formatTime(table.rows.first?.holdSeconds ?? 0))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.1))
            )
        }
    }

    private func startTraining() {
        let holdTotal = holdMinutes * 60 + holdSeconds
        let restTotal = restMinutes * 60 + restSeconds
        guard holdTotal > 0 else { return }
        timerManager.startCustomTimer(holdSeconds: holdTotal, restSeconds: restTotal, levels: levels)
        showTimer = true
    }

    private func startTable(_ table: TrainingTable) {
        timerManager.startTable(table)
        showTimer = true
    }

    private func saveTable() {
        let holdTotal = holdMinutes * 60 + holdSeconds
        let restTotal = restMinutes * 60 + restSeconds
        let rows = (1...levels).map { TableRow(level: $0, holdSeconds: holdTotal, restSeconds: restTotal) }
        let table = TrainingTable(type: .custom, name: tableName.isEmpty ? "Custom Table" : tableName, rows: rows)
        store.addCustomTable(table)
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}
