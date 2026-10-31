import Foundation

public struct FavoriteItem: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let original: String
    public let translated: String
    public let direction: String
    public let provider: String
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        original: String,
        translated: String,
        direction: String = "",
        provider: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.original = original
        self.translated = translated
        self.direction = direction
        self.provider = provider
        self.createdAt = createdAt
    }
}
