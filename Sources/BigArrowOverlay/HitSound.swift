import AppKit
import BigArrowCore

/// `--sound`: one short hit as the arrow lands, a low thump under a dry click. Synthesized in
/// memory, so the binary ships no sound file, and played without any permission.
@MainActor
public enum HitSound {
    static let sampleRate = 44_100
    static let length = 0.32
    /// Held while it plays; NSSound stops when released.
    private static var playing: NSSound?

    /// Plays the hit when the arrow lands: at once without animation.
    public static func play(look: ArrowLook, mode: AnimationMode) {
        let delay: TimeInterval = mode == .full ? (look == .drop ? Animator.dropLanding : Animator.drawOn * 0.8) : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            MainActor.assumeIsolated {
                HitSound.playing = NSSound(data: HitSound.wav(HitSound.samples()))
                HitSound.playing?.play()
            }
        }
    }

    /// A pitch drop from 150 to 45 Hz with a fast decay, plus 12 ms of decaying noise on top.
    static func samples() -> [Int16] {
        let count = Int(Double(sampleRate) * length)
        var seed: UInt32 = 0x2545_F491
        var phase = 0.0
        return (0..<count).map { index in
            let time = Double(index) / Double(sampleRate)
            phase += 2 * Double.pi * (45 + 105 * exp(-time * 28)) / Double(sampleRate)
            seed = seed &* 1_664_525 &+ 1_013_904_223
            let noise = Double(Int32(bitPattern: seed)) / Double(Int32.max) * exp(-time * 380)
            let value = sin(phase) * exp(-time * 11) * 0.9 + noise * 0.35
            return Int16(max(-1, min(1, value)) * Double(Int16.max))
        }
    }

    /// A mono 16-bit PCM WAV around the samples.
    static func wav(_ samples: [Int16]) -> Data {
        let bytes = samples.count * 2
        var data = Data("RIFF".utf8)
        append(&data, UInt32(36 + bytes))
        data.append(contentsOf: Array("WAVEfmt ".utf8))
        append(&data, UInt32(16))
        append(&data, UInt16(1))
        append(&data, UInt16(1))
        append(&data, UInt32(sampleRate))
        append(&data, UInt32(sampleRate * 2))
        append(&data, UInt16(2))
        append(&data, UInt16(16))
        data.append(contentsOf: Array("data".utf8))
        append(&data, UInt32(bytes))
        for sample in samples { append(&data, sample) }
        return data
    }

    static func append<Value: FixedWidthInteger>(_ data: inout Data, _ value: Value) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }
}
