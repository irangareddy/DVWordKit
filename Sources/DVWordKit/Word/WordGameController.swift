//
//  WordGameController.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

@available(macOS 10.15, iOS 13, *)
public class WordGameController {
    private let apiKey: String
    private let wordProvider: WordProvider
    private let usedWordsActor = UsedWordsActor()

    public init(apiKey: String, wordProvider: WordProvider? = nil) {
        self.apiKey = apiKey
        self.wordProvider = wordProvider ?? AIWordProvider(apiKey: apiKey)
    }

    public func nextWord(category: WordCategory) async -> Word {
        var word: Word
        repeat {
            word = await wordProvider.getRandomWord(category: category)
        } while await usedWordsActor.isWordUsed(word.value)
        
        await usedWordsActor.addWord(word.value)
        return word
    }

    public func resetUsedWords() async {
        await usedWordsActor.reset()
    }

    public func getHint(for word: Word) -> String {
        return word.hint ?? "No hint available"
    }
}

actor UsedWordsActor {
    private var usedWords: Set<String> = []

    func isWordUsed(_ word: String) -> Bool {
        return usedWords.contains(word)
    }

    func addWord(_ word: String) {
        usedWords.insert(word)
    }

    func reset() {
        usedWords.removeAll()
    }
}


@available(macOS 10.15, iOS 13, *)
func playGame() async {
    let controller = WordGameController(apiKey: "your_api_key")

    let category = WordCategory.animals
    let word = await controller.nextWord(category: category)
    print("Next word: \(word.value)")

    let hint = controller.getHint(for: word)
    print("Hint: \(hint)")

    await controller.resetUsedWords()
}
