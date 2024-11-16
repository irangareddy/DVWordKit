//
//  AIWordProvider.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

import Foundation
 
public protocol WordProvider {
        func getRandomWord(category: WordCategory) async -> Word
        func getWordBatch(category: WordCategory, count: Int) async -> [Word]
    }

@available(macOS 10.15, *)
public class AIWordProvider: WordProvider {
    private let openAIClient: OpenAIClient
    private let hintGenerator: WordHintGenerator

    public init(apiKey: String) {
        self.openAIClient = OpenAIClient(apiKey: apiKey)
        self.hintGenerator = WordHintGenerator(apiKey: apiKey)
    }

    public func getRandomWord(category: WordCategory) async -> Word {
        // Try up to 3 times to get a valid word
        for _ in 0..<3 {
            if let wordResponse = await openAIClient.generateWord(category: category.rawValue) {
                let wordHint = await hintGenerator.generateHint(for: Word(value: wordResponse.word, 
                                                                         category: category, 
                                                                         difficulty: wordResponse.difficulty))
                
                return Word(value: wordResponse.word, 
                           category: category, 
                           difficulty: wordResponse.difficulty, 
                           hint: wordHint)
            }
        }
        
        // Only return fallback after multiple failed attempts
        print("Warning: Failed to generate word after 3 attempts, returning fallback word")
        return Word(value: "fallback", category: category)
    }

    public func getWordBatch(category: WordCategory, count: Int) async -> [Word] {
        let wordsResponse = await openAIClient.generateWords(category: category.rawValue, count: count)
        
        var wordsWithHints: [Word] = []
        
        for response in wordsResponse {
            let word = Word(value: response.word, category: category, difficulty: response.difficulty)
            let hint = await hintGenerator.generateHint(for: word)
            wordsWithHints.append(Word(value: word.value, category: word.category, difficulty: word.difficulty, hint: hint))
        }
        
        return wordsWithHints
    }

}

