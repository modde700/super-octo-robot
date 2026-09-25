import AVFoundation

/// Plays the classic two-tone EAS attention signal (853 Hz + 960 Hz) locally,
/// in-app, for previewing the sound. This is purely local audio playback — it
/// never transmits anything over any radio, cellular, or broadcast path.
final class ToneGenerator: ObservableObject {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let sampleRate: Double = 44_100

    @Published var isPlaying = false

    private var phase1: Double = 0
    private var phase2: Double = 0

    func toggle(duration: TimeInterval = 8) {
        isPlaying ? stop() : play(duration: duration)
    }

    func play(duration: TimeInterval = 8) {
        stop()
        configureSession()

        let twoPi = 2 * Double.pi
        let inc1 = twoPi * 853.0 / sampleRate
        let inc2 = twoPi * 960.0 / sampleRate

        let node = AVAudioSourceNode { [weak self] (_, _, frameCount, audioBufferList) -> OSStatus in
            guard let self else { return noErr }
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sample = Float(0.5 * sin(self.phase1) + 0.5 * sin(self.phase2))
                self.phase1 += inc1; if self.phase1 > twoPi { self.phase1 -= twoPi }
                self.phase2 += inc2; if self.phase2 > twoPi { self.phase2 -= twoPi }
                for buffer in abl {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }

        sourceNode = node
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            isPlaying = true
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.stop()
            }
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        guard isPlaying || engine.isRunning else { return }
        engine.stop()
        if let node = sourceNode { engine.detach(node) }
        sourceNode = nil
        isPlaying = false
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true)
    }
}
