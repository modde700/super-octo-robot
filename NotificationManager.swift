import Foundation
import UserNotifications
import AVFoundation

// MARK: - Sounds

/// A sound the notification can use.
enum AlertSound: Hashable, Identifiable {
    case attention              // bundled attention.wav
    case systemDefault          // iPhone's default notification sound
    case ringtone               // the ringtone set in Settings > Sounds
    case imported(String)       // a file the user imported (in Library/Sounds)

    var id: String {
        switch self {
        case .attention: return "attention"
        case .systemDefault: return "default"
        case .ringtone: return "ringtone"
        case .imported(let name): return "imported:" + name
        }
    }

    var label: String {
        switch self {
        case .attention: return "Attention tone (2-tone)"
        case .systemDefault: return "iPhone default alert"
        case .ringtone: return "Your current ringtone"
        case .imported(let name): return (name as NSString).deletingPathExtension
        }
    }

    var notificationSound: UNNotificationSound {
        switch self {
        case .attention: return UNNotificationSound(named: UNNotificationSoundName("attention.wav"))
        case .systemDefault: return .default
        case .ringtone: return .defaultRingtone
        case .imported(let name): return UNNotificationSound(named: UNNotificationSoundName(name))
        }
    }
}

struct SoundImportError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

/// Keeps imported sounds in Library/Sounds, where iOS looks for notification sounds.
final class SoundLibrary: ObservableObject {
    static let shared = SoundLibrary()

    @Published private(set) var imported: [String] = []

    var all: [AlertSound] {
        [.attention, .systemDefault, .ringtone] + imported.map { .imported($0) }
    }

    private var soundsDir: URL {
        let lib = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        return lib.appendingPathComponent("Sounds", isDirectory: true)
    }

    private init() { reload() }

    func reload() {
        try? FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true)
        let files = (try? FileManager.default.contentsOfDirectory(atPath: soundsDir.path)) ?? []
        imported = files.filter { $0.lowercased().hasSuffix(".caf") }.sorted()
    }

    /// Converts any audio file iOS can read (mp3, m4a, wav, ...) to a 16-bit PCM .caf,
    /// trimmed to 29 seconds, because notification sounds must be PCM and under 30 s.
    func importSound(from url: URL) throws -> String {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

        try FileManager.default.createDirectory(at: soundsDir, withIntermediateDirectories: true)
        let base = url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: " ", with: "_")
        let fileName = base + ".caf"
        let outURL = soundsDir.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: outURL)

        try convert(from: url, to: outURL)
        reload()
        return fileName
    }

    func delete(_ name: String) {
        try? FileManager.default.removeItem(at: soundsDir.appendingPathComponent(name))
        reload()
    }

    private func convert(from inURL: URL, to outURL: URL) throws {
        let input = try AVAudioFile(forReading: inURL)
        let format = input.processingFormat

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false,
        ]
        let output = try AVAudioFile(forWriting: outURL,
                                     settings: settings,
                                     commonFormat: format.commonFormat,
                                     interleaved: format.isInterleaved)

        let chunk: AVAudioFrameCount = 4096
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: chunk) else {
            throw SoundImportError(message: "Couldn't read that audio file.")
        }

        var remaining = min(input.length, AVAudioFramePosition(format.sampleRate * 29))
        while remaining > 0 {
            let toRead = AVAudioFrameCount(min(AVAudioFramePosition(chunk), remaining))
            try input.read(into: buffer, frameCount: toRead)
            if buffer.frameLength == 0 { break }
            try output.write(from: buffer)
            remaining -= AVAudioFramePosition(buffer.frameLength)
        }
    }
}

// MARK: - Notifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}

    @Published var status: UNAuthorizationStatus = .notDetermined

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            center.getNotificationSettings { settings in
                DispatchQueue.main.async { self.status = settings.authorizationStatus }
            }
        }
    }

    /// Schedules a local notification on this phone after `delay` seconds.
    func fire(title: String, body: String, sound: AlertSound, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound.notificationSound

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
