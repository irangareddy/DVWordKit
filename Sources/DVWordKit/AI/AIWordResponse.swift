//
//  AIWordResponse.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

import Foundation

public struct OpenAIResponse: Codable {
    public struct Choice: Codable {
        public let message: Message
        public let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    public struct Message: Codable {
        public let role: String
        public let content: String
    }
    
    public let choices: [Choice]
}

public struct AIWordResponse: Sendable {
    public let word: String
    public let difficulty: WordDifficulty
}

public struct WordAPIResponse: Codable {
    let word: String
    let difficulty: String
}
