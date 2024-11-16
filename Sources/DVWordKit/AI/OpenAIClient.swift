//
//  OpenAIClient.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

import Foundation

@available(macOS 10.15, *)
public class OpenAIClient {
    private let apiKey: String
    private let session: URLSession
    
    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    public func generateWord(category: String) async -> AIWordResponse? {
        return await fetchWords(category: category, count: 1).first
    }
    
    public func generateWords(category: String, count: Int) async -> [AIWordResponse] {
        return await fetchWords(category: category, count: count)
    }
    

    private func fetchWords(category: String, count: Int) async -> [AIWordResponse] {
        let endpoint = "https://api.openai.com/v1/chat/completions"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages: [[String: String]] = [
            ["role": "system", "content": """
                You are a helpful assistant for generating Pictionary words.
                Always respond in JSON format with the following structure:
                {"word": "example", "difficulty": "easy"}
                Difficulty must be one of: easy, medium, hard
                """],
            ["role": "user", "content": "Generate a word from the category '\(category)' for a Pictionary game."]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 150,
            "response_format": ["type": "json_object"]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let container = WordResponseContainer()
        
        do {
            let (data, _) = try await session.data(for: request)
            if let decodedResponse = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
                for choice in decodedResponse.choices {
                    if let jsonData = choice.message.content.data(using: .utf8),
                       let wordResponse = try? JSONDecoder().decode(WordAPIResponse.self, from: jsonData) {
                        let responseWord = AIWordResponse(
                            word: wordResponse.word,
                            difficulty: WordDifficulty(rawValue: wordResponse.difficulty.lowercased()) ?? .medium
                        )
                        await container.add(response: responseWord)
                    }
                }
            } else {
                if let errorJson = String(data: data, encoding: .utf8) {
                    print("Debug - Failed to decode response:", errorJson)
                }
            }
        } catch {
            print("Error fetching words:", error)
        }
        
        return await container.getResponses()
    }

}

@available(macOS 10.15, *)
extension OpenAIClient {
    public func generateHint(prompt: String) async -> AIHintResponse? {
        let endpoint = "https://api.openai.com/v1/chat/completions"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages: [[String: String]] = [
            ["role": "system", "content": """
                You are a helpful assistant for generating Pictionary hints.
                Respond with a short, clear hint that doesn't directly give away the word.
                """],
            ["role": "user", "content": prompt]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 50
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await session.data(for: request)
            if let decodedResponse = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
                let hintText = decodedResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No hint available"
                return AIHintResponse(hint: hintText)
            }
        } catch {
            print("Error fetching hint:", error)
        }
        
        return nil
    }
}
