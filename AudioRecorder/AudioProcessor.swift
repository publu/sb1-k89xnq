import Foundation
import AVFoundation

class AudioProcessor {
    private let sampleRate: Int = 16000
    private let channels: Int = 1
    private var audioFile: AVAudioFile?
    private var lastPacketIndex: Int = -1
    private var lastFrameId: Int = -1
    private var pendingData = Data()
    private var audioFrames: [Data] = []
    
    init() {
        setupAudioFile()
    }
    
    private func setupAudioFile() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        let audioUrl = documentsPath.appendingPathComponent("recording_\(timestamp).wav")
        
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Double(sampleRate),
            channels: AVAudioChannelCount(channels),
            interleaved: false
        )!
        
        do {
            audioFile = try AVAudioFile(forWriting: audioUrl, settings: format.settings)
        } catch {
            print("Error creating audio file: \(error)")
        }
    }
    
    func processAudioData(_ data: Data) {
        let bytes = [UInt8](data)
        guard bytes.count >= 4 else { return }
        
        let index = Int(bytes[0]) + (Int(bytes[1]) << 8)
        let internal = bytes[2]
        let content = data.subdata(in: 3..<data.count)
        
        if lastPacketIndex == -1 && internal == 0 {
            lastPacketIndex = index
            lastFrameId = Int(internal)
            pendingData = content
            return
        }
        
        if lastPacketIndex == -1 { return }
        
        if index != lastPacketIndex + 1 || (internal != 0 && internal != UInt8(lastFrameId + 1)) {
            print("Lost frame")
            lastPacketIndex = -1
            pendingData = Data()
            return
        }
        
        if internal == 0 {
            audioFrames.append(pendingData)
            pendingData = content
            lastFrameId = Int(internal)
            lastPacketIndex = index
            return
        }
        
        pendingData.append(content)
        lastFrameId = Int(internal)
        lastPacketIndex = index
        
        // When we have enough frames, process them
        if audioFrames.count >= 10 {
            processFrames()
        }
    }
    
    private func processFrames() {
        // Note: In a real implementation, you would need to add Opus decoding here
        // Since iOS doesn't have native Opus support, you'd need to use a third-party
        // library or framework for Opus decoding
        
        guard let audioFile = audioFile else { return }
        
        // Convert decoded PCM data to AVAudioPCMBuffer and write to file
        // This is a placeholder for the actual Opus decoding implementation
        audioFrames.removeAll()
    }
}