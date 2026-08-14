import SwiftUI

struct TablesView: View {
    @StateObject private var store = TableStore()
    @StateObject private var timerManager = TimerManager()
    @State private var selectedType: TableType = .o2
    @State private var showTimer = false
    @State private var selectedTable: TrainingTable?
    @AppStorage("appLanguage") private var appLanguage = "en"

    var filteredTables: [TrainingTable] {
        store.tables.filter { $0.type == selectedType }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                typePicker
                List(filteredTables) { table in
                    Button {
                        selectedTable = table
                        timerManager.startTable(table)
                        showTimer = true
                    } label: {
                        tableRow(table)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .navigationTitle(L("tables"))
            .sheet(isPresented: $showTimer) {
                TimerView(timerManager: timerManager, table: selectedTable)
            }
        }
        .id(appLanguage)
    }

    private var typePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TableType.allCases.filter { $0 != .custom }, id: \.self) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    } label: {
                        Text(type.rawValue)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedType == type ? typeColor(type) : Color(.systemGray5))
                            )
                            .foregroundColor(selectedType == type ? .white : .primary)
                    }
                }
            }
            .padding()
        }
    }

    private func tableRow(_ table: TrainingTable) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(table.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack(spacing: 12) {
                    Label("\(table.rows.count) \(L("levels"))", systemImage: "number")
                    Label(formatTime(table.rows.first?.holdSeconds ?? 0), systemImage: "timer")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(typeColor(table.type))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }

    private func typeColor(_ type: TableType) -> Color {
        switch type {
        case .o2: return .blue
        case .co2: return .red
        case .mix: return .green
        case .firstContraction: return .orange
        case .custom: return .purple
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}
