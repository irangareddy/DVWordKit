//
//  WordResponseContainer.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

import Foundation

actor WordResponseContainer {
    private var responses: [AIWordResponse] = []

    func add(response: AIWordResponse) {
        responses.append(response)
    }

    func getResponses() -> [AIWordResponse] {
        return responses
    }
}
