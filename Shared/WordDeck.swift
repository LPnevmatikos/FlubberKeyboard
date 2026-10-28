import Foundation

/// In-memory shuffled bag. The UI owns one instance and calls tap once per touch-up.
public struct WordDeck {
    public private(set) var visibleWords: [String]
    private let words: [String]
    private var bag: [String]
    private let shuffle: ([String]) -> [String]

    public static let fallbackWords = [
        "cooking", "vibing", "discombobulating", "flabbergasting", "percolating",
        "pondering", "marinating", "noodling", "ruminating", "simmering",
        "oscillating", "cogitating", "contemplating", "concocting", "brewing",
        "fermenting", "meandering", "scheming", "recalibrating", "untangling",
        "transmogrifying", "frolicking", "befuddling", "bamboozling"
    ]

    /// Trim each line, normalize case, reject non-word entries, preserve first occurrence.
    public static func sanitize(_ entries: [String]) -> [String] {
        var seen = Set<String>()
        return entries.compactMap { entry in
            let word = entry.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !word.isEmpty,
                  word.utf8.allSatisfy({ (97...122).contains($0) }),
                  seen.insert(word).inserted else { return nil }
            return word
        }
    }

    static var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }

    public static func loadWords(from bundle: Bundle? = nil) -> [String] {
        let resourceBundle = bundle ?? Self.resourceBundle
        guard let url = resourceBundle.url(forResource: "words", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return fallbackWords
        }
        let result = sanitize(text.components(separatedBy: .newlines))
        return result.count > 9 ? result : fallbackWords
    }

    public init(words: [String] = WordDeck.loadWords(), visibleCount: Int = 9,
                shuffle: @escaping ([String]) -> [String] = { $0.shuffled() }) {
        let count = min(9, max(1, visibleCount))
        let clean = Self.sanitize(words)
        self.words = clean.count > count ? clean : Self.fallbackWords
        self.shuffle = shuffle
        self.bag = shuffle(self.words)
        self.visibleWords = []
        for _ in 0..<count {
            visibleWords.append(bag.removeFirst())
        }
    }

    /// Returns exactly what to insert; only this slot changes. No host context is read.
    @discardableResult
    public mutating func tap(at index: Int) -> String? {
        guard visibleWords.indices.contains(index) else { return nil }
        let tapped = visibleWords[index]
        let excluded = Set(visibleWords) // Includes the tapped word until replacement.
        if !bag.contains(where: { !excluded.contains($0) }) {
            bag = shuffle(words.filter { !excluded.contains($0) })
        }
        // The source always has more words than slots, so an eligible word exists.
        guard let next = bag.firstIndex(where: { !excluded.contains($0) }) else { return nil }
        visibleWords[index] = bag.remove(at: next)
        return tapped + " "
    }
}
