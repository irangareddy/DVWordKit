//
//  WordHintGenerator.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

import Foundation

@available(macOS 10.15, *)
public class WordHintGenerator {
    private let openAIClient: OpenAIClient

    public init(apiKey: String) {
        self.openAIClient = OpenAIClient(apiKey: apiKey)
    }

    public func generateHint(for word: Word) async -> String {
        let prompt = "Provide a hint for the word '\(word.value)' in the context of the category '\(word.category.rawValue)'."
        
        guard let hintResponse = await openAIClient.generateHint(prompt: prompt) else {
            return "No hint available"
        }
        
        return hintResponse.hint
    }
}
