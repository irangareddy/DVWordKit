//
//  Word.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

import Foundation

public struct Word: Codable, Identifiable {
    public let id: UUID
    public let value: String
    public let category: WordCategory
    public let difficulty: WordDifficulty
    public let hint: String?

    public init(value: String,
                category: WordCategory,
                difficulty: WordDifficulty = .medium,
                hint: String? = nil) {
        self.id = UUID()
        self.value = value
        self.category = category
        self.difficulty = difficulty
        self.hint = hint
    }
}

// WordCategories.swift
public enum WordCategory: String, CaseIterable, Codable {
    case animals = "Animals"
    case food = "Food"
    case sports = "Sports"
    case movies = "Movies"
    case objects = "Objects"
    case actions = "Actions"
    case places = "Places"
    case nature = "Nature"
}

// WordDifficulty.swift
public enum WordDifficulty: String, Codable, Sendable {
    case easy
    case medium
    case hard
}
