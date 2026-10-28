import Foundation
import XCTest
@testable import FlubberCore

final class WordDeckTests: XCTestCase {
    func testSanitization() {
        XCTAssertEqual(WordDeck.sanitize([" vibing \n", "VIBING", "", "   ", "two words", "bad!", "42", "cooking\t"]), ["vibing", "cooking"])
    }

    func testBundledResourceIsPresentAndCurated() throws {
        // Check the resource directly so fallback cannot conceal a broken target membership.
        let url = try XCTUnwrap(WordDeck.resourceBundle.url(forResource: "words", withExtension: "txt"))
        let raw = try String(contentsOf: url, encoding: .utf8)
        let words = WordDeck.sanitize(raw.components(separatedBy: .newlines))
        XCTAssertGreaterThanOrEqual(words.count, 100)
        XCTAssertEqual(words.count, raw.split(whereSeparator: \.isNewline).count)
        XCTAssertEqual(Set(words), Set(WordDeck.loadWords()))
        for word in ["cooking", "vibing", "discombobulating", "flabbergasting"] {
            XCTAssertTrue(words.contains(word))
        }
    }

    func testSmallDeterministicBagExhaustionAndRefill() {
        var deck = WordDeck(words: ["one", "two", "three", "four", "five"], visibleCount: 2, shuffle: { $0 })
        XCTAssertEqual(deck.visibleWords, ["one", "two"])
        XCTAssertEqual(deck.tap(at: 0), "one ")
        XCTAssertEqual(deck.visibleWords, ["three", "two"])
        XCTAssertEqual(deck.tap(at: 0), "three ")
        XCTAssertEqual(deck.visibleWords, ["four", "two"])
        XCTAssertEqual(deck.tap(at: 0), "four ")
        XCTAssertEqual(deck.visibleWords, ["five", "two"])
        // All eligible unconsumed words were used before the first refill.
        XCTAssertEqual(deck.tap(at: 0), "five ")
        XCTAssertEqual(deck.visibleWords, ["one", "two"])
    }

    func testThirtyRapidSynchronousTapsPreserveInsertionOrder() {
        var deck = WordDeck(shuffle: { $0 })
        var actual = ""
        var expected = ""
        for _ in 0..<30 {
            expected += deck.visibleWords[2] + " "
            actual += deck.tap(at: 2) ?? ""
        }
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.split(separator: " ").count, 30)
        XCTAssertFalse(actual.contains("  "))
        XCTAssertTrue(actual.hasSuffix(" "))
    }

    func testThousandsOfReplacementsOnlyChangeTappedSlot() {
        for source in [["one", "two", "three", "four"], WordDeck.loadWords()] {
            let count = min(9, source.count - 1)
            var deck = WordDeck(words: source, visibleCount: count, shuffle: { $0 })
            for tap in 0..<5000 {
                let index = tap % count
                let before = deck.visibleWords
                XCTAssertEqual(deck.tap(at: index), before[index] + " ")
                XCTAssertNotEqual(deck.visibleWords[index], before[index])
                XCTAssertEqual(Set(deck.visibleWords).count, count)
                XCTAssertFalse(deck.visibleWords.contains(""))
                for other in 0..<count where other != index {
                    XCTAssertEqual(deck.visibleWords[other], before[other])
                }
            }
        }
    }

    func testFullBagUsedBeforeRepeat() {
        let words = WordDeck.loadWords()
        var deck = WordDeck(words: words, shuffle: { $0 })
        var seen = Set(deck.visibleWords)
        for _ in 0..<(words.count - 9) {
            deck.tap(at: 2)
            XCTAssertTrue(seen.insert(deck.visibleWords[2]).inserted)
        }
        XCTAssertEqual(seen, Set(words))
        let before = deck.visibleWords
        deck.tap(at: 2)
        XCTAssertFalse(before.contains(deck.visibleWords[2]))
    }

    func testInvalidInputAndMissingResourceUseFallback() {
        var deck = WordDeck(words: ["", "bad entry", "cooking", "COOKING"], shuffle: { $0 })
        XCTAssertEqual(deck.visibleWords.count, 9)
        XCTAssertEqual(Set(deck.visibleWords).count, 9)
        for _ in 0..<100 { XCTAssertNotNil(deck.tap(at: 2)) }
        XCTAssertEqual(WordDeck.loadWords(from: Bundle(for: WordDeckTests.self)), WordDeck.fallbackWords)
    }

    func testInvalidResourceContentsUseFallback() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".bundle")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let info: [String: Any] = ["CFBundleIdentifier": "test.flubber.invalid", "CFBundleName": "InvalidDeck"]
        let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try data.write(to: directory.appendingPathComponent("Info.plist"))
        let url = directory.appendingPathComponent("words.txt")
        try " \nCOOKING\ncooking\nbad entry\n".write(to: url, atomically: true, encoding: .utf8)
        let bundle = try XCTUnwrap(Bundle(url: directory))
        XCTAssertEqual(WordDeck.loadWords(from: bundle), WordDeck.fallbackWords)
        try Data([0xff, 0xfe, 0xff]).write(to: url)
        XCTAssertEqual(WordDeck.loadWords(from: bundle), WordDeck.fallbackWords)
    }

    func testInvalidSlotDoesNotMutate() {
        var deck = WordDeck()
        let before = deck.visibleWords
        XCTAssertNil(deck.tap(at: -1))
        XCTAssertNil(deck.tap(at: 9))
        XCTAssertEqual(deck.visibleWords, before)
    }
}
