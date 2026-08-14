import SwiftUI

struct HomeView: View {
    @StateObject private var store = TableStore()
    @StateObject private var timerManager = TimerManager()
    @State private var showTimer = false
    @State private var selectedTable: TrainingTable?
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    quickStartSection
                    recentTablesSection
                }
                .padding()
            }
            .navigationTitle(L("apnea_trainer"))
            .sheet(isPresented: $showTimer) {
                TimerView(timerManager: timerManager, table: selectedTable)
            }
        }
        .id(appLanguage)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "wind")
                .font(.system(size: 60))
                .foregroundColor(.cyan)
            Text(L("breathe_hold_conquer"))
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cyan.opacity(0.1))
        )
    }

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("quick_start"))
                .font(.title2.bold())
            NavigationLink(destination: TablesView()) {
                quickStartCard(title: L("training_tables"), subtitle: "O2, CO2, Mix & First Contraction", icon: "list.bullet.rectangle", color: .blue)
            }
            NavigationLink(destination: CustomTableView()) {
                quickStartCard(title: L("custom"), subtitle: L("build_your_table"), icon: "slider.horizontal.3", color: .green)
            }
        }
    }

    private var recentTablesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("preset_tables"))
                .font(.title2.bold())
            ForEach(store.tables.prefix(4)) { table in
                Button {
                    selectedTable = table
                    timerManager.startTable(table)
                    showTimer = true
                } label: {
                    tableCard(table)
                }
            }
        }
    }

    private func quickStartCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }

    private func tableCard(_ table: TrainingTable) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(table.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(table.rows.count) \(L("levels"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(.cyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
