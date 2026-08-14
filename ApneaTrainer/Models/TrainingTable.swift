import Foundation
import Combine

struct TableRow: Identifiable, Codable {
    let id: UUID
    let level: Int
    let holdSeconds: Int
    let restSeconds: Int

    init(level: Int, holdSeconds: Int, restSeconds: Int) {
        self.id = UUID()
        self.level = level
        self.holdSeconds = holdSeconds
        self.restSeconds = restSeconds
    }
}

enum TableType: String, CaseIterable, Codable {
    case o2 = "O2"
    case co2 = "CO2"
    case mix = "Mix"
    case firstContraction = "First Contraction"
    case custom = "Custom"
}

struct TrainingTable: Identifiable, Codable {
    let id: UUID
    let type: TableType
    var name: String
    var rows: [TableRow]

    init(type: TableType, name: String, rows: [TableRow]) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.rows = rows
    }
}

class TableStore: ObservableObject {
    @Published var tables: [TrainingTable] = []
    @Published var customTables: [TrainingTable] = []

    init() {
        loadPresetTables()
        loadCustomTables()
    }

    func loadPresetTables() {
        tables = [
            TrainingTable(type: .o2, name: "O2 Table - Beginner", rows: Self.o2Beginner),
            TrainingTable(type: .o2, name: "O2 Table - Intermediate", rows: Self.o2Intermediate),
            TrainingTable(type: .o2, name: "O2 Table - Advanced", rows: Self.o2Advanced),
            TrainingTable(type: .co2, name: "CO2 Table - Beginner", rows: Self.co2Beginner),
            TrainingTable(type: .co2, name: "CO2 Table - Intermediate", rows: Self.co2Intermediate),
            TrainingTable(type: .co2, name: "CO2 Table - Advanced", rows: Self.co2Advanced),
            TrainingTable(type: .mix, name: "Mix Table - Beginner", rows: Self.mixBeginner),
            TrainingTable(type: .mix, name: "Mix Table - Intermediate", rows: Self.mixIntermediate),
            TrainingTable(type: .mix, name: "Mix Table - Advanced", rows: Self.mixAdvanced),
            TrainingTable(type: .firstContraction, name: "First Contraction - Beginner", rows: Self.fcBeginner),
            TrainingTable(type: .firstContraction, name: "First Contraction - Intermediate", rows: Self.fcIntermediate),
            TrainingTable(type: .firstContraction, name: "First Contraction - Advanced", rows: Self.fcAdvanced),
        ]
    }

    func saveCustomTables() {
        if let data = try? JSONEncoder().encode(customTables) {
            UserDefaults.standard.set(data, forKey: "customTables")
        }
    }

    func loadCustomTables() {
        if let data = UserDefaults.standard.data(forKey: "customTables"),
           let decoded = try? JSONDecoder().decode([TrainingTable].self, from: data) {
            customTables = decoded
        }
    }

    func addCustomTable(_ table: TrainingTable) {
        customTables.append(table)
        saveCustomTables()
    }

    func deleteCustomTable(at offsets: IndexSet) {
        customTables.remove(atOffsets: offsets)
        saveCustomTables()
    }

    // MARK: - O2 Tables (Fixed hold, decreasing rest)

    static let o2Beginner: [TableRow] = [
        TableRow(level: 1, holdSeconds: 60, restSeconds: 120),
        TableRow(level: 2, holdSeconds: 60, restSeconds: 110),
        TableRow(level: 3, holdSeconds: 60, restSeconds: 100),
        TableRow(level: 4, holdSeconds: 60, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 60, restSeconds: 80),
        TableRow(level: 6, holdSeconds: 60, restSeconds: 70),
        TableRow(level: 7, holdSeconds: 60, restSeconds: 60),
        TableRow(level: 8, holdSeconds: 60, restSeconds: 50),
        TableRow(level: 9, holdSeconds: 60, restSeconds: 40),
        TableRow(level: 10, holdSeconds: 60, restSeconds: 30),
    ]

    static let o2Intermediate: [TableRow] = [
        TableRow(level: 1, holdSeconds: 90, restSeconds: 120),
        TableRow(level: 2, holdSeconds: 90, restSeconds: 110),
        TableRow(level: 3, holdSeconds: 90, restSeconds: 100),
        TableRow(level: 4, holdSeconds: 90, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 90, restSeconds: 80),
        TableRow(level: 6, holdSeconds: 90, restSeconds: 70),
        TableRow(level: 7, holdSeconds: 90, restSeconds: 60),
        TableRow(level: 8, holdSeconds: 90, restSeconds: 50),
        TableRow(level: 9, holdSeconds: 90, restSeconds: 40),
        TableRow(level: 10, holdSeconds: 90, restSeconds: 30),
    ]

    static let o2Advanced: [TableRow] = [
        TableRow(level: 1, holdSeconds: 120, restSeconds: 150),
        TableRow(level: 2, holdSeconds: 120, restSeconds: 140),
        TableRow(level: 3, holdSeconds: 120, restSeconds: 130),
        TableRow(level: 4, holdSeconds: 120, restSeconds: 120),
        TableRow(level: 5, holdSeconds: 120, restSeconds: 110),
        TableRow(level: 6, holdSeconds: 120, restSeconds: 100),
        TableRow(level: 7, holdSeconds: 120, restSeconds: 90),
        TableRow(level: 8, holdSeconds: 120, restSeconds: 80),
        TableRow(level: 9, holdSeconds: 120, restSeconds: 70),
        TableRow(level: 10, holdSeconds: 120, restSeconds: 60),
    ]

    // MARK: - CO2 Tables (Increasing hold, fixed rest)

    static let co2Beginner: [TableRow] = [
        TableRow(level: 1, holdSeconds: 60, restSeconds: 90),
        TableRow(level: 2, holdSeconds: 70, restSeconds: 90),
        TableRow(level: 3, holdSeconds: 80, restSeconds: 90),
        TableRow(level: 4, holdSeconds: 90, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 100, restSeconds: 90),
        TableRow(level: 6, holdSeconds: 110, restSeconds: 90),
        TableRow(level: 7, holdSeconds: 120, restSeconds: 90),
        TableRow(level: 8, holdSeconds: 130, restSeconds: 90),
        TableRow(level: 9, holdSeconds: 140, restSeconds: 90),
        TableRow(level: 10, holdSeconds: 150, restSeconds: 90),
    ]

    static let co2Intermediate: [TableRow] = [
        TableRow(level: 1, holdSeconds: 90, restSeconds: 90),
        TableRow(level: 2, holdSeconds: 100, restSeconds: 90),
        TableRow(level: 3, holdSeconds: 110, restSeconds: 90),
        TableRow(level: 4, holdSeconds: 120, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 130, restSeconds: 90),
        TableRow(level: 6, holdSeconds: 140, restSeconds: 90),
        TableRow(level: 7, holdSeconds: 150, restSeconds: 90),
        TableRow(level: 8, holdSeconds: 160, restSeconds: 90),
        TableRow(level: 9, holdSeconds: 170, restSeconds: 90),
        TableRow(level: 10, holdSeconds: 180, restSeconds: 90),
    ]

    static let co2Advanced: [TableRow] = [
        TableRow(level: 1, holdSeconds: 120, restSeconds: 90),
        TableRow(level: 2, holdSeconds: 135, restSeconds: 90),
        TableRow(level: 3, holdSeconds: 150, restSeconds: 90),
        TableRow(level: 4, holdSeconds: 165, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 180, restSeconds: 90),
        TableRow(level: 6, holdSeconds: 195, restSeconds: 90),
        TableRow(level: 7, holdSeconds: 210, restSeconds: 90),
        TableRow(level: 8, holdSeconds: 225, restSeconds: 90),
        TableRow(level: 9, holdSeconds: 240, restSeconds: 90),
        TableRow(level: 10, holdSeconds: 255, restSeconds: 90),
    ]

    // MARK: - Mix Tables (Both increase)

    static let mixBeginner: [TableRow] = [
        TableRow(level: 1, holdSeconds: 60, restSeconds: 60),
        TableRow(level: 2, holdSeconds: 70, restSeconds: 70),
        TableRow(level: 3, holdSeconds: 80, restSeconds: 80),
        TableRow(level: 4, holdSeconds: 90, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 100, restSeconds: 100),
        TableRow(level: 6, holdSeconds: 110, restSeconds: 110),
        TableRow(level: 7, holdSeconds: 120, restSeconds: 120),
        TableRow(level: 8, holdSeconds: 130, restSeconds: 130),
        TableRow(level: 9, holdSeconds: 140, restSeconds: 140),
        TableRow(level: 10, holdSeconds: 150, restSeconds: 150),
    ]

    static let mixIntermediate: [TableRow] = [
        TableRow(level: 1, holdSeconds: 90, restSeconds: 60),
        TableRow(level: 2, holdSeconds: 100, restSeconds: 70),
        TableRow(level: 3, holdSeconds: 110, restSeconds: 80),
        TableRow(level: 4, holdSeconds: 120, restSeconds: 90),
        TableRow(level: 5, holdSeconds: 130, restSeconds: 100),
        TableRow(level: 6, holdSeconds: 140, restSeconds: 110),
        TableRow(level: 7, holdSeconds: 150, restSeconds: 120),
        TableRow(level: 8, holdSeconds: 160, restSeconds: 130),
        TableRow(level: 9, holdSeconds: 170, restSeconds: 140),
        TableRow(level: 10, holdSeconds: 180, restSeconds: 150),
    ]

    static let mixAdvanced: [TableRow] = [
        TableRow(level: 1, holdSeconds: 120, restSeconds: 60),
        TableRow(level: 2, holdSeconds: 135, restSeconds: 75),
        TableRow(level: 3, holdSeconds: 150, restSeconds: 90),
        TableRow(level: 4, holdSeconds: 165, restSeconds: 105),
        TableRow(level: 5, holdSeconds: 180, restSeconds: 120),
        TableRow(level: 6, holdSeconds: 195, restSeconds: 135),
        TableRow(level: 7, holdSeconds: 210, restSeconds: 150),
        TableRow(level: 8, holdSeconds: 225, restSeconds: 165),
        TableRow(level: 9, holdSeconds: 240, restSeconds: 180),
        TableRow(level: 10, holdSeconds: 255, restSeconds: 195),
    ]

    // MARK: - First Contraction Tables

    static let fcBeginner: [TableRow] = [
        TableRow(level: 1, holdSeconds: 30, restSeconds: 60),
        TableRow(level: 2, holdSeconds: 45, restSeconds: 60),
        TableRow(level: 3, holdSeconds: 60, restSeconds: 60),
        TableRow(level: 4, holdSeconds: 75, restSeconds: 60),
        TableRow(level: 5, holdSeconds: 90, restSeconds: 60),
        TableRow(level: 6, holdSeconds: 105, restSeconds: 60),
        TableRow(level: 7, holdSeconds: 120, restSeconds: 60),
        TableRow(level: 8, holdSeconds: 135, restSeconds: 60),
        TableRow(level: 9, holdSeconds: 150, restSeconds: 60),
        TableRow(level: 10, holdSeconds: 165, restSeconds: 60),
    ]

    static let fcIntermediate: [TableRow] = [
        TableRow(level: 1, holdSeconds: 60, restSeconds: 60),
        TableRow(level: 2, holdSeconds: 75, restSeconds: 60),
        TableRow(level: 3, holdSeconds: 90, restSeconds: 60),
        TableRow(level: 4, holdSeconds: 105, restSeconds: 60),
        TableRow(level: 5, holdSeconds: 120, restSeconds: 60),
        TableRow(level: 6, holdSeconds: 135, restSeconds: 60),
        TableRow(level: 7, holdSeconds: 150, restSeconds: 60),
        TableRow(level: 8, holdSeconds: 165, restSeconds: 60),
        TableRow(level: 9, holdSeconds: 180, restSeconds: 60),
        TableRow(level: 10, holdSeconds: 195, restSeconds: 60),
    ]

    static let fcAdvanced: [TableRow] = [
        TableRow(level: 1, holdSeconds: 90, restSeconds: 60),
        TableRow(level: 2, holdSeconds: 105, restSeconds: 60),
        TableRow(level: 3, holdSeconds: 120, restSeconds: 60),
        TableRow(level: 4, holdSeconds: 135, restSeconds: 60),
        TableRow(level: 5, holdSeconds: 150, restSeconds: 60),
        TableRow(level: 6, holdSeconds: 165, restSeconds: 60),
        TableRow(level: 7, holdSeconds: 180, restSeconds: 60),
        TableRow(level: 8, holdSeconds: 195, restSeconds: 60),
        TableRow(level: 9, holdSeconds: 210, restSeconds: 60),
        TableRow(level: 10, holdSeconds: 225, restSeconds: 60),
    ]
}
