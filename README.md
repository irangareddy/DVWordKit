# DVWordKit

A Swift package for creating word-based games like Pictionary, with AI-powered word generation and hints.

## Features

- AI-powered word generation using OpenAI
- Category-based word selection
- Difficulty levels (easy, medium, hard)
- Automatic hint generation
- Used word tracking to prevent repetition
- SwiftUI compatible

## Installation

Add DVWordKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/irangareddy/DVWordKit.git", from: "1.0.0")
]
```

## Usage in SwiftUI


1. First, initialize the `WordGameController` with your OpenAI API key:

```swift
class GameViewModel: ObservableObject {
    private let gameController: WordGameController
    @Published var currentWord: Word?
    @Published var currentHint: String = ""
    
    init(apiKey: String) {
        self.gameController = WordGameController(apiKey: apiKey)
    }
    
    func getNextWord(category: WordCategory) async {
        currentWord = await gameController.nextWord(category: category)
        if let word = currentWord {
            currentHint = gameController.getHint(for: word)
        }
    }
    
    func resetGame() async {
        await gameController.resetUsedWords()
    }
}
```


2. Use the ViewModel in your SwiftUI view:

```swift
struct GameView: View {
    @StateObject private var viewModel = GameViewModel(apiKey: "your-api-key")
    
    var body: some View {
        VStack {
            if let word = viewModel.currentWord {
                Text("Word: \(word.value)")
                Text("Category: \(word.category.rawValue)")
                Text("Difficulty: \(word.difficulty.rawValue)")
                Text("Hint: \(viewModel.currentHint)")
            }
            
            Button("Next Word") {
                Task {
                    await viewModel.getNextWord(category: .animals)
                }
            }
            
            Button("Reset Game") {
                Task {
                    await viewModel.resetGame()
                }
            }
        }
    }
}
```


## Key Components

For detailed implementation, refer to WordGameController (lines 8-68), which shows:

- Word generation and management
- Hint retrieval
- Used word tracking
- Game state management

## Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.5+
- OpenAI API key

## Important Notes

- You need a valid OpenAI API key
- Keep your API key secure and never commit it to source control
- Consider rate limits and costs associated with OpenAI API usage

## Best Practices

- Initialize WordGameController once and reuse it
- Handle errors appropriately in production code
- Consider caching generated words for offline use
- Implement proper error handling for network requests

For more details about the implementation, check the WordGameController class in the source code.
