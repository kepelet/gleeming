# Gleeming

A memory training iOS game built with Swift and SwiftUI where players memorize and repeat sequences of highlighted grid cells.

## Features

### Core Gameplay

- Grid-based memory sequences with progressive difficulty
- Two difficulty modes: Random and Progressive
- Customizable grid sizes (3x3, 4x4, 5x5)
- Score tracking with streak counters
- Timed mode with progressive time limits

### Audio & Visual

- Musical sound effects with pentatonic scale notes
- Haptic feedback for game events
- Confetti celebrations every 3 levels
- Theme system (Auto/Light/Dark modes)
- Volume control with real-time preview

### Social Features

- Share results to social media platforms
- Generate visual game summaries for sharing
- Show off high scores and achievements
- Challenge friends with your best streaks

## Project Structure

```
gleeming/
├── Models/
│   ├── GameModels.swift      # Core game data structures
│   └── GameSettings.swift    # Global settings management
├── ViewModels/
│   └── GameViewModel.swift   # Main game logic and state
├── Views/
│   ├── GameView.swift        # Primary game interface
│   ├── WelcomeView.swift     # Landing screen
│   ├── SettingsView.swift    # Configuration interface
│   └── Components/           # Reusable UI components
├── Utilities/
│   ├── HapticManager.swift   # Haptic feedback system
│   ├── SoundManager.swift    # Audio management
│   └── ThemeManager.swift    # Theme and color management
└── ContentView.swift         # Navigation coordinator
```

## Game Mechanics

### Difficulty Modes

- **Random**: Each level generates a completely new sequence
- **Progressive**: Each level adds one step to the previous sequence

### Timed Mode

- Base time: 10 seconds
- Time increase: 2 seconds per level
- Visual countdown with color-coded urgency
- Haptic warnings at 3 seconds remaining
