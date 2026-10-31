import Foundation
import SQLite3

final class FavoritesDatabase: @unchecked Sendable {
    private var db: OpaquePointer?
    private let dbQueue = DispatchQueue(label: "com.swapr.trans.favorites.sqlite", qos: .userInitiated)

    init(fileURL: URL) {
        let parentDir = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try? FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        let path = fileURL.path
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
            // Enable WAL mode for crash-resilience and concurrent reads/writes
            sqlite3_exec(db, "PRAGMA journal_mode=WAL;", nil, nil, nil)
            sqlite3_exec(db, "PRAGMA synchronous=NORMAL;", nil, nil, nil)
            createTable()
        } else {
            if let db = db {
                let errMsg = String(cString: sqlite3_errmsg(db))
                NSLog("[FavoritesDatabase] Failed to open SQLite at \(path): \(errMsg)")
            }
        }
    }

    deinit {
        if let db = db {
            sqlite3_close_v2(db)
        }
    }

    private func createTable() {
        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS favorites (
            id TEXT PRIMARY KEY,
            original TEXT NOT NULL,
            translated TEXT NOT NULL,
            direction TEXT NOT NULL,
            provider TEXT NOT NULL,
            created_at REAL NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_favorites_created_at ON favorites (created_at DESC);
        CREATE INDEX IF NOT EXISTS idx_favorites_original ON favorites (original);
        """
        sqlite3_exec(db, createTableSQL, nil, nil, nil)
    }

    // MARK: - Queries & Operations

    func fetchAll() -> [FavoriteItem] {
        return dbQueue.sync {
            guard let db = db else { return [] }
            let sql = "SELECT id, original, translated, direction, provider, created_at FROM favorites ORDER BY created_at DESC;"
            var statement: OpaquePointer?

            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                return []
            }
            defer { sqlite3_finalize(statement) }

            var results: [FavoriteItem] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                if let idString = sqlite3_column_text(statement, 0),
                   let origString = sqlite3_column_text(statement, 1),
                   let transString = sqlite3_column_text(statement, 2),
                   let dirString = sqlite3_column_text(statement, 3),
                   let provString = sqlite3_column_text(statement, 4) {

                    let idVal = UUID(uuidString: String(cString: idString)) ?? UUID()
                    let original = String(cString: origString)
                    let translated = String(cString: transString)
                    let direction = String(cString: dirString)
                    let provider = String(cString: provString)
                    let timestamp = sqlite3_column_double(statement, 5)
                    let date = Date(timeIntervalSince1970: timestamp)

                    results.append(FavoriteItem(
                        id: idVal,
                        original: original,
                        translated: translated,
                        direction: direction,
                        provider: provider,
                        createdAt: date
                    ))
                }
            }
            return results
        }
    }

    func upsert(item: FavoriteItem) {
        dbQueue.async { [weak self] in
            guard let self = self, let db = self.db else { return }
            // Remove existing by original text to ensure uniqueness and freshness
            let deleteSQL = "DELETE FROM favorites WHERE original = ?;"
            var delStmt: OpaquePointer?
            if sqlite3_prepare_v2(db, deleteSQL, -1, &delStmt, nil) == SQLITE_OK {
                sqlite3_bind_text(delStmt, 1, (item.original as NSString).utf8String, -1, nil)
                sqlite3_step(delStmt)
            }
            sqlite3_finalize(delStmt)

            let insertSQL = "INSERT INTO favorites (id, original, translated, direction, provider, created_at) VALUES (?, ?, ?, ?, ?, ?);"
            var insStmt: OpaquePointer?
            if sqlite3_prepare_v2(db, insertSQL, -1, &insStmt, nil) == SQLITE_OK {
                sqlite3_bind_text(insStmt, 1, (item.id.uuidString as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insStmt, 2, (item.original as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insStmt, 3, (item.translated as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insStmt, 4, (item.direction as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insStmt, 5, (item.provider as NSString).utf8String, -1, nil)
                sqlite3_bind_double(insStmt, 6, item.createdAt.timeIntervalSince1970)
                sqlite3_step(insStmt)
            }
            sqlite3_finalize(insStmt)
        }
    }

    func delete(id: UUID) {
        dbQueue.async { [weak self] in
            guard let self = self, let db = self.db else { return }
            let sql = "DELETE FROM favorites WHERE id = ?;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (id.uuidString as NSString).utf8String, -1, nil)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }

    func deleteByOriginal(original: String) {
        dbQueue.async { [weak self] in
            guard let self = self, let db = self.db else { return }
            let sql = "DELETE FROM favorites WHERE original = ?;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (original as NSString).utf8String, -1, nil)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }

    func deleteAll() {
        dbQueue.async { [weak self] in
            guard let self = self, let db = self.db else { return }
            sqlite3_exec(db, "DELETE FROM favorites;", nil, nil, nil)
            sqlite3_exec(db, "VACUUM;", nil, nil, nil)
        }
    }
}

