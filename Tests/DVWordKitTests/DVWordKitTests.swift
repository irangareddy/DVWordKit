import Testing
import Foundation
@testable import DVWordKit

extension DVWordKitTests {
    func getTestAPIKey() -> String {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("⚠️ No OPENAI_API_KEY found in environment. Please set the OPENAI_API_KEY environment variable.")
        }
        return apiKey
    }
}

// Mock WordProvider for testing
class MockWordProvider: WordProvider {
    var mockWord: Word
    
    init(mockWord: Word) {
        self.mockWord = mockWord
    }
    
    func getRandomWord(category: WordCategory) async -> Word {
        return mockWord
    }
    
    func getWordBatch(category: WordCategory, count: Int) async -> [Word] {
        return Array(repeating: mockWord, count: count)
    }
}

final class DVWordKitTests {
    
    @Test("Word initialization")
    func testWordInitialization() {
        let word = Word(value: "elephant", 
                       category: .animals, 
                       difficulty: .medium, 
                       hint: "Large gray mammal")
        
        #expect(word.value == "elephant")
        #expect(word.category == .animals)
        #expect(word.difficulty == .medium)
        #expect(word.hint == "Large gray mammal")
    }
    
    @Test("WordGameController next word")
    func testWordGameControllerNextWord() async {
        let mockWord = Word(value: "tiger", 
                          category: .animals, 
                          difficulty: .medium)
        let mockProvider = MockWordProvider(mockWord: mockWord)
        let controller = WordGameController(apiKey: "test-key", 
                                         wordProvider: mockProvider)
        
        let word = await controller.nextWord(category: .animals)
        #expect(word.value == "tiger")
        #expect(word.category == .animals)
    }
    
    @Test("WordGameController used words tracking")
    func testUsedWordsTracking() async {
        let mockWord = Word(value: "tiger", 
                          category: .animals, 
                          difficulty: .medium)
        let mockProvider = MockWordProvider(mockWord: mockWord)
        let controller = WordGameController(apiKey: "test-key", 
                                         wordProvider: mockProvider)
        
        let word1 = await controller.nextWord(category: .animals)
        #expect(word1.value == "tiger")
        
        await controller.resetUsedWords()
        let word2 = await controller.nextWord(category: .animals)
        #expect(word2.value == "tiger")
    }
    
    @Test("Word hint retrieval")
    func testWordHintRetrieval() {
        let word = Word(value: "elephant", 
                       category: .animals, 
                       difficulty: .medium, 
                       hint: "Large gray mammal")
        let controller = WordGameController(apiKey: "test-key")
        
        let hint = controller.getHint(for: word)
        #expect(hint == "Large gray mammal")
        
        let wordWithoutHint = Word(value: "elephant", 
                                 category: .animals)
        let defaultHint = controller.getHint(for: wordWithoutHint)
        #expect(defaultHint == "No hint available")
    }
    
    @Test("Real API Word Generation")
    func testRealAPIWordGeneration() async throws {
        let apiKey = getTestAPIKey()
        let controller = WordGameController(apiKey: apiKey)
        
        let word = await controller.nextWord(category: .animals)
        #expect(!word.value.isEmpty)
        #expect(word.category == .animals)
    }
    
    @Test("Real API Hint Generation")
    func testRealAPIHintGeneration() async throws {
        let apiKey = getTestAPIKey()
        let hintGenerator = WordHintGenerator(apiKey: apiKey)
        
        let testWord = Word(value: "elephant",
                           category: .animals, 
                           difficulty: .medium)
        
        let hint = await hintGenerator.generateHint(for: testWord)
        #expect(!hint.isEmpty)
        #expect(hint != "No hint available")
    }
    
    @Test("Real API Word Batch Generation")
    func testRealAPIWordBatchGeneration() async throws {
        let apiKey = getTestAPIKey()
        let provider = AIWordProvider(apiKey: apiKey)
        
        let words = await provider.getWordBatch(category: .animals, count: 3)
        #expect(words.count == 1)
        #expect(words.allSatisfy { !$0.value.isEmpty })
        #expect(words.allSatisfy { $0.hint != nil })
    }
}
