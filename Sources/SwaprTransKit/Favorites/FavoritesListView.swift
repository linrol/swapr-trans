import SwiftUI
import AppKit

public struct FavoritesListView: View {
    @ObservedObject public var favoritesManager: FavoritesManager = FavoritesManager.shared
    @State private var searchText: String = ""
    @State private var showClearConfirmation: Bool = false
    @State private var copiedItemId: UUID? = nil
    @State private var showingExportMenu: Bool = false

    public init() {}

    private var filteredItems: [FavoriteItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return favoritesManager.items
        }
        let query = searchText.lowercased()
        return favoritesManager.items.filter {
            $0.original.lowercased().contains(query) || $0.translated.lowercased().contains(query)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerBar
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()

            // Search Bar
            searchBar
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()
                .opacity(0.5)

            // Content List or Empty State
            if favoritesManager.items.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredItems.isEmpty {
                noMatchStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredItems) { item in
                        favoriteCard(for: item)
                            .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }

            Divider()

            // Footer Bar
            footerBar
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
        }
        .frame(minWidth: 440, minHeight: 480)
        .alert(isPresented: $showClearConfirmation) {
            Alert(
                title: Text("Clear All Favorites?"),
                message: Text("This will permanently remove all \(favoritesManager.items.count) saved translations. This action cannot be undone."),
                primaryButton: .destructive(Text("Clear All")) {
                    favoritesManager.clearAll()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Subviews

    private var headerBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 15))
                Text("Saved Translations")
                    .font(.system(size: 14, weight: .semibold))
            }

            Spacer()

            Text("\(favoritesManager.items.count) items")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.secondary.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 12))

            TextField("Search in original or translation...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
        )
    }

    private func favoriteCard(for item: FavoriteItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top metadata row
            HStack(spacing: 6) {
                if !item.direction.isEmpty {
                    Text(item.direction)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .cornerRadius(4)
                }

                if !item.provider.isEmpty {
                    Text(item.provider)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(item.createdAt, style: .date)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)

                // TTS Pronounce
                Button(action: {
                    favoritesManager.toggleSpeech(for: item.translated)
                }) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Pronounce translated text")

                // Copy translated text
                Button(action: {
                    copyToPasteboard(text: item.translated)
                    copiedItemId = item.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        if copiedItemId == item.id {
                            copiedItemId = nil
                        }
                    }
                }) {
                    Image(systemName: copiedItemId == item.id ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(copiedItemId == item.id ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .help("Copy translation")

                // Delete button
                Button(action: {
                    favoritesManager.removeFavorite(id: item.id)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("Remove from favorites")
            }

            // Original Text
            Text(item.original)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .textSelection(.enabled)
                .lineLimit(4)

            // Divider line inside card
            Rectangle()
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 1)

            // Translated Text
            Text(item.translated)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .lineLimit(6)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.slash")
                .font(.system(size: 38))
                .foregroundColor(.secondary.opacity(0.6))
            Text("No Favorites Yet")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            Text("Click the star (⭐️) button in the translation popup\nto save words or sentences here.")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }

    private var noMatchStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No Matching Items")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(24)
    }

    private var footerBar: some View {
        HStack {
            Menu {
                Button("Export as CSV (.csv)") {
                    saveFile(content: favoritesManager.exportCSV(), defaultFilename: "swapr_favorites.csv")
                }
                Button("Export as JSON (.json)") {
                    saveFile(content: favoritesManager.exportJSON(), defaultFilename: "swapr_favorites.json")
                }
                Divider()
                Button("Copy All as CSV") {
                    copyToPasteboard(text: favoritesManager.exportCSV())
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
                .font(.system(size: 11))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .disabled(favoritesManager.items.isEmpty)

            Spacer()

            Button(role: .destructive, action: {
                showClearConfirmation = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Clear All")
                }
                .font(.system(size: 11))
                .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .disabled(favoritesManager.items.isEmpty)
        }
    }

    // MARK: - Helpers

    private func copyToPasteboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func saveFile(content: String, defaultFilename: String) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = defaultFilename
        savePanel.begin { result in
            if result == .OK, let targetURL = savePanel.url {
                try? content.write(to: targetURL, atomically: true, encoding: .utf8)
            }
        }
    }
}

