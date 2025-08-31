//
//  SoundManager.swift
//  gleeming
//
//  Created by ervan on 31/08/25.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioEngine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    private var isEngineRunning = false
    
    // Musical note frequencies (in Hz) for a pentatonic scale
    private let noteFrequencies: [Double] = [
        261.63, // C4
        293.66, // D4
        329.63, // E4
        392.00, // G4
        440.00, // A4
        523.25, // C5
        587.33, // D5
        659.25, // E5
        783.99, // G5
        880.00, // A5
        1046.50, // C6
        1174.66, // D6
        1318.51, // E6
        1567.98, // G6
        1760.00, // A6
        2093.00, // C7
        2349.32, // D7
        2637.02, // E7
        3135.96, // G7
        3520.00, // A7
        4186.01, // C8
        4698.63, // D8
        5274.04, // E8
        6271.93, // G8
        7040.00  // A8
    ]
    
    private init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create player nodes for polyphonic playback
            for _ in 0..<10 {
                let playerNode = AVAudioPlayerNode()
                audioEngine.attach(playerNode)
                audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
                playerNodes.append(playerNode)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isEngineRunning = true
            
        } catch {
            print("Failed to setup audio engine: \(error)")
            isEngineRunning = false
        }
    }
    
    // MARK: - Sound Generation
    
    func playNoteForGridPosition(_ position: GridPosition, gridSize: Int) {
        guard GameSettings.shared.soundEffectsEnabled else { return }
        
        guard isEngineRunning else {
            print("Audio engine not running - cannot play sound")
            return
        }
        
        // Calculate note index based on grid position
        let noteIndex = getNoteIndexForPosition(position, gridSize: gridSize)
        let frequency = noteFrequencies[noteIndex]
        
        #if targetEnvironment(simulator)
        print("Simulator - would play note \(frequency)Hz for grid position (\(position.row), \(position.column))")
        #else
        playTone(frequency: frequency, duration: 0.3, volume: GameSettings.shared.volume)
        #endif
    }
    
    private func getNoteIndexForPosition(_ position: GridPosition, gridSize: Int) -> Int {
        // Create a mapping from grid position to note index
        // This creates a pleasant musical pattern across the grid
        let totalCells = gridSize * gridSize
        let cellIndex = position.row * gridSize + position.column
        
        // Map to available notes, cycling through the pentatonic scale
        let noteIndex = cellIndex % noteFrequencies.count
        return noteIndex
    }
    
    private func playTone(frequency: Double, duration: Double, volume: Float) {
        guard let playerNode = getAvailablePlayerNode() else {
            print("No available player nodes")
            return
        }
        
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.mainMixerNode.outputFormat(forBus: 0), frameCapacity: frameCount) else {
            print("Failed to create audio buffer")
            return
        }
        
        buffer.frameLength = frameCount
        
        // Generate sine wave
        let channelCount = Int(buffer.format.channelCount)
        for channel in 0..<channelCount {
            let channelData = buffer.floatChannelData![channel]
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                let sample = Float(sin(2.0 * Double.pi * frequency * time)) * volume * 0.3 // Reduced volume
                channelData[frame] = sample
            }
        }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
    
    private func getAvailablePlayerNode() -> AVAudioPlayerNode? {
        // Find a player node that's not currently playing
        for playerNode in playerNodes {
            if !playerNode.isPlaying {
                return playerNode
            }
        }
        
        // If all nodes are busy, return the first one (it will queue)
        return playerNodes.first
    }
    
    // MARK: - Audio Session Management
    
    func pauseAudio() {
        for playerNode in playerNodes {
            if playerNode.isPlaying {
                playerNode.pause()
            }
        }
    }
    
    func resumeAudio() {
        // Audio will resume when new sounds are played
    }
    
    func stopAllSounds() {
        for playerNode in playerNodes {
            playerNode.stop()
        }
    }
}
