//
//  BackgroundMusicManager.swift
//  gleeming
//
//  Created by ervan on 16/09/25.
//

import Foundation
import AVFoundation

class BackgroundMusicManager: ObservableObject {
    static let shared = BackgroundMusicManager()
    
    private var gameAudioPlayer: AVAudioPlayer? // For actual gameplay
    private var previewAudioPlayer: AVAudioPlayer? // For settings preview
    private var gameSettings = GameSettings.shared
    
    // Available background music tracks
    enum MusicTrack: String, CaseIterable {
        case calmingRain = "calming-rain"
        case ambientPads = "ambient-pads-loop-296968"
        case forestNature = "forest-nature-322637"
        case publicProtest = "public-protest"
        case trafficInCity = "traffic-in-city-309236"
        
        var displayName: String {
            switch self {
            case .calmingRain:
                return "Calming Rain"
            case .ambientPads:
                return "Ambient Pads"
            case .forestNature:
                return "Forest Nature"
            case .publicProtest:
                return "Public Protest"
            case .trafficInCity:
                return "Traffic in City"
            }
        }
        
        var fileName: String {
            return rawValue
        }
    }
    
    @Published var currentTrack: MusicTrack = .calmingRain
    @Published var isGameMusicPlaying: Bool = false
    @Published var isPreviewPlaying: Bool = false
    @Published var currentPreviewTrack: MusicTrack? = nil
    
    private init() {
        setupAudioSession()
        syncWithSettings()
    }
    
    private func syncWithSettings() {
        if let track = MusicTrack(rawValue: gameSettings.selectedBackgroundMusic) {
            currentTrack = track
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session for background music: \(error)")
        }
    }
    
    // MARK: - Game Music Control
    
    func playGameMusic(_ track: MusicTrack? = nil) {
        guard gameSettings.backgroundMusicEnabled else { return }
        
        let trackToPlay = track ?? currentTrack
        
        guard let url = Bundle.main.url(forResource: trackToPlay.fileName, withExtension: "mp3") else {
            print("Could not find music file: \(trackToPlay.fileName).mp3")
            return
        }
        
        do {
            // Stop current game music if playing
            stopGameMusic()
            
            // Create new player for game music
            gameAudioPlayer = try AVAudioPlayer(contentsOf: url)
            gameAudioPlayer?.numberOfLoops = -1 // Infinite loop
            gameAudioPlayer?.volume = calculateMusicVolume()
            gameAudioPlayer?.prepareToPlay()
            gameAudioPlayer?.play()
            
            currentTrack = trackToPlay
            isGameMusicPlaying = true
            
        } catch {
            print("Failed to play background music: \(error)")
        }
    }
    
    func stopGameMusic() {
        gameAudioPlayer?.stop()
        gameAudioPlayer = nil
        isGameMusicPlaying = false
    }
    
    func pauseGameMusic() {
        gameAudioPlayer?.pause()
        isGameMusicPlaying = false
    }
    
    func resumeGameMusic() {
        guard gameSettings.backgroundMusicEnabled else { return }
        gameAudioPlayer?.play()
        isGameMusicPlaying = true
    }
    
    // MARK: - Preview Music Control
    
    func playPreview(_ track: MusicTrack) {
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
            print("Could not find music file: \(track.fileName).mp3")
            return
        }
        
        do {
            // Stop current preview if playing
            stopPreview()
            
            // Create new player for preview (no loop, just 30 seconds preview)
            previewAudioPlayer = try AVAudioPlayer(contentsOf: url)
            previewAudioPlayer?.numberOfLoops = 0 // Play once
            previewAudioPlayer?.volume = calculatePreviewVolume()
            previewAudioPlayer?.prepareToPlay()
            previewAudioPlayer?.play()
            
            currentPreviewTrack = track
            isPreviewPlaying = true
            
            // Auto-stop preview after 30 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
                if self?.currentPreviewTrack == track {
                    self?.stopPreview()
                }
            }
            
        } catch {
            print("Failed to play preview music: \(error)")
        }
    }
    
    func stopPreview() {
        previewAudioPlayer?.stop()
        previewAudioPlayer = nil
        isPreviewPlaying = false
        currentPreviewTrack = nil
    }
    
    func togglePreview(for track: MusicTrack) {
        if isPreviewPlaying && currentPreviewTrack == track {
            stopPreview()
        } else {
            playPreview(track)
        }
    }
    
    func setTrack(_ track: MusicTrack) {
        let wasPlaying = isGameMusicPlaying
        currentTrack = track
        
        // Update settings
        gameSettings.selectedBackgroundMusic = track.fileName
        gameSettings.saveSettings()
        
        if wasPlaying {
            playGameMusic(track)
        }
    }
    
    // MARK: - Volume Control
    
    private func calculateMusicVolume() -> Float {
        // Background music should be softer than sound effects
        let baseVolume = gameSettings.volume * 0.6 // 60% of main volume
        return min(baseVolume, 0.5) // Cap at 50% to be safe
    }
    
    private func calculatePreviewVolume() -> Float {
        // Preview music can be a bit louder for better demonstration
        let baseVolume = gameSettings.volume * 0.8 // 80% of main volume
        return min(baseVolume, 0.7) // Cap at 70% for preview
    }
    
    func updateVolume() {
        gameAudioPlayer?.volume = calculateMusicVolume()
        previewAudioPlayer?.volume = calculatePreviewVolume()
    }
    
    // MARK: - Settings Integration
    
    func handleBackgroundMusicSettingChanged() {
        // Don't auto-start music when setting is enabled, only during gameplay
        if !gameSettings.backgroundMusicEnabled {
            stopGameMusic()
        }
    }
    
    // MARK: - Game State Integration
    
    func startGameMusic() {
        guard gameSettings.backgroundMusicEnabled else { return }
        playGameMusic()
    }
    
    func stopAllMusic() {
        stopGameMusic()
        stopPreview()
    }
}
