//
//  PCMPlayer.swift
//  PCMPlayer
//
//  Created by Jia-Han Wu on 2024/12/29.
//

import AVFAudio

class PCMPlayer: ObservableObject {
    enum Error: Swift.Error {
        case audioFormatInitializationFailed
        case base64DecodingFailed
        case pcmBufferInitializationFailed
    }
    
    private let engine = AVAudioEngine()
    
    private var playerNode: AVAudioPlayerNode?
    
    private var format: AVAudioFormat?
    
    private func detachPlayerNode() {
        for node in engine.attachedNodes where node === playerNode {
            engine.detach(node)
        }
    }
    
    func configure(sampleRate: Double, channels: UInt32) throws {
        engine.stop()
        
        detachPlayerNode()
        
        playerNode = AVAudioPlayerNode()
        
        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: channels
        ) else {
            throw Error.audioFormatInitializationFailed
        }
        
        self.format = format
        
        engine.attach(playerNode!)
        
        engine.connect(playerNode!, to: engine.mainMixerNode, format: format)
        
        try engine.start()
    }
    
    func play(base64encodedPCMData: String) throws {
        guard let data = Data(base64Encoded: base64encodedPCMData, options: [.ignoreUnknownCharacters]) else {
            throw Error.base64DecodingFailed
        }
        
        let count = data.count / 2
        
        var floatArray = [Float](repeating: 0, count: count)
        
        data.withUnsafeBytes { ptr in
            let shorts = ptr.bindMemory(to: Int16.self)
            for i in 0..<count {
                floatArray[i] = Float(shorts[i]) / Float(Int16.max)
            }
        }
        
        guard let pcmBuffer = AVAudioPCMBuffer(
            pcmFormat: format!,
            frameCapacity: AVAudioFrameCount(count)
        ) else {
            throw Error.pcmBufferInitializationFailed
        }
        
        pcmBuffer.frameLength = pcmBuffer.frameCapacity
        
        let channels = UnsafeBufferPointer(start: pcmBuffer.floatChannelData,
                                           count: Int(format!.channelCount))
        
        for i in 0..<count {
            channels[0][i] = floatArray[i]
        }
        
        playerNode?.scheduleBuffer(
            pcmBuffer,
            at: nil,
            options: .interrupts,
            completionHandler: nil
        )
        
        playerNode?.play()
    }
}
