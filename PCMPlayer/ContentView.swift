//
//  ContentView.swift
//  PCMPlayer
//
//  Created by Jia-Han Wu on 2024/12/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pcmPlayer = PCMPlayer()
    @State       var base64encodedPCMData = example1
    @State       var sampleRate = "24000"
    @State       var channels = 1.0
    @State       var error: Error?
    
    var body: some View {
        VStack {
            TextEditor(text: $base64encodedPCMData)
            
            TextField("Sample Rate", text: $sampleRate)
                .labelsVisibility(.visible)
            
            Slider(
                value: $channels,
                in: 1...2,
                step: 1
            ) {
                Text("Channels")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text("2")
            }
            
            Text("Sample Rate: \(sampleRate) Channels: \(Int(channels))")
                .font(.caption)
            
            if let error {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Button("Play") {
                error = nil
                
                do {
                    try pcmPlayer.play(base64encodedPCMData: base64encodedPCMData)
                } catch {
                    self.error = error
                }
                
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(base64encodedPCMData, forType: .string)
            }
        }
        .padding()
        .onAppear {
            do {
                try pcmPlayer.configure(
                    sampleRate: Double(sampleRate) ?? 44100,
                    channels: UInt32(channels)
                )
            } catch {
                self.error = error
            }
        }
        .onChange(of: sampleRate) {
            error = nil
            
            do {
                try pcmPlayer.configure(
                    sampleRate: Double(sampleRate) ?? 44100.0,
                    channels: UInt32(channels)
                )
            } catch {
                self.error = error
            }
        }
        .onChange(of: channels) {
            error = nil
            
            do {
                try pcmPlayer.configure(
                    sampleRate: Double(sampleRate) ?? 44100.0,
                    channels: UInt32(channels)
                )
            } catch {
                self.error = error
            }
        }
    }
}

#Preview {
    ContentView()
}
