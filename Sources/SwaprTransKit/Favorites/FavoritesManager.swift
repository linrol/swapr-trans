import Foundation
import Combine
import AVFoundation

@MainActor
public final class FavoritesManager: ObservableObject {
    public static let shared = FavoritesManager()

    @Published public private(set) var items: [FavoriteItem] = []

    private var speechSynthesizer: AVSpeechSynthesizer?
    private let database: FavoritesDatabase

    private static var storageDirectoryURL: URL {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let bundleId = Bundle.main.bundleIdentifier ?? "SwaprTrans"
        let folderURL = appSupport.appendingPathComponent(bundleId, isDirectory: true)

        if !fileManager.fileExists(atPath: folderURL.path) {
            try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        return folderURL
    }

    private init() {
        let folder = Self.storageDirectoryURL
        let dbURL = folder.appendingPathComponent("swapr_favorites.sqlite3")
        self.database = FavoritesDatabase(fileURL: dbURL)

        // Perform legacy JSON migration if needed
        migrateLegacyJSONIfNeeded(in: folder)

        // Load initial dataset from SQLite
        self.items = database.fetchAll()
    }

    // MARK: - Query & Mutation

    public func isFavorited(original: String) -> Bool {
        let trimmed = original.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return items.contains { $0.original.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed }
    }

    @discardableResult
    public func toggleFavorite(original: String, translated: String, direction: String, provider: String) -> Bool {
        let trimmedOrig = original.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOrig.isEmpty else { return false }

        if let index = items.firstIndex(where: { $0.original.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedOrig }) {
            let item = items.remove(at: index)
            database.delete(id: item.id)
            return false
        } else {
            let newItem = FavoriteItem(
                original: trimmedOrig,
                translated: translated.trimmingCharacters(in: .whitespacesAndNewlines),
                direction: direction,
                provider: provider,
                createdAt: Date()
            )
            items.insert(newItem, at: 0)
            database.upsert(item: newItem)
            return true
        }
    }

    public func removeFavorite(id: UUID) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: idx)
            database.delete(id: id)
        }
    }

    public func removeFavorites(ids: Set<UUID>) {
        items.removeAll { ids.contains($0.id) }
        for id in ids {
            database.delete(id: id)
        }
    }

    public func clearAll() {
        items.removeAll()
        database.deleteAll()
    }

    // MARK: - Speech Synthesis

    public func toggleSpeech(for text: String) {
        if speechSynthesizer == nil {
            speechSynthesizer = AVSpeechSynthesizer()
        }
        guard let synth = speechSynthesizer else { return }
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        } else {
            let utterance = AVSpeechUtterance(string: text)
            synth.speak(utterance)
        }
    }

    // MARK: - Export

    public func exportCSV() -> String {
        var lines: [String] = ["\"Original\",\"Translated\",\"Direction\",\"Provider\",\"Date\""]
        let formatter = ISO8601DateFormatter()

        for item in items {
            let orig = item.original.replacingOccurrences(of: "\"", with: "\"\"")
            let trans = item.translated.replacingOccurrences(of: "\"", with: "\"\"")
            let dir = item.direction.replacingOccurrences(of: "\"", with: "\"\"")
            let prov = item.provider.replacingOccurrences(of: "\"", with: "\"\"")
            let date = formatter.string(from: item.createdAt)
            lines.append("\"\(orig)\",\"\(trans)\",\"\(dir)\",\"\(prov)\",\"\(date)\"")
        }
        return lines.joined(separator: "\n")
    }

    public func exportJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }

    // MARK: - Migration from JSON

    private func migrateLegacyJSONIfNeeded(in folder: URL) {
        let legacyJsonURL = folder.appendingPathComponent("swapr_favorites.json")
        guard FileManager.default.fileExists(atPath: legacyJsonURL.path),
              let data = try? Data(contentsOf: legacyJsonURL) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let legacyItems = try? decoder.decode([FavoriteItem].self, from: data) {
            for item in legacyItems {
                database.upsert(item: item)
            }
            // Archive or remove legacy JSON
            let archivedURL = folder.appendingPathComponent("swapr_favorites.json.migrated")
            try? FileManager.default.removeItem(at: archivedURL)
            try? FileManager.default.moveItem(at: legacyJsonURL, to: archivedURL)
        }
    }
}
