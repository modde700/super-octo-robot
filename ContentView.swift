import SwiftUI
import AudioToolbox
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var notifier = NotificationManager.shared
    @StateObject private var sounds = SoundLibrary.shared
    @StateObject private var tone = ToneGenerator()

    @State private var title = "Emergency Alert"
    @State private var message = "This is a test message."
    @State private var sound: AlertSound = .attention
    @State private var delay: Double = 5
    @State private var systemSoundID = 1005
    @State private var showImporter = false
    @State private var status: String?

    var body: some View {
        NavigationStack {
            Form {
                // 1. What the notification says
                Section("Message") {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(3...8)
                }

                // 2. Which sound it plays
                Section {
                    Picker("Sound", selection: $sound) {
                        ForEach(sounds.all) { s in
                            Text(s.label).tag(s)
                        }
                    }
                    Button {
                        notifier.fire(title: title, body: message, sound: sound, delay: 1)
                        status = "Playing: \(sound.label)"
                    } label: {
                        Label("Hear this sound now", systemImage: "speaker.wave.2.fill")
                    }
                    Button {
                        showImporter = true
                    } label: {
                        Label("Import a sound from Files…", systemImage: "square.and.arrow.down")
                    }
                    if !sounds.imported.isEmpty {
                        ForEach(sounds.imported, id: \.self) { name in
                            Text((name as NSString).deletingPathExtension)
                                .foregroundStyle(.secondary)
                        }
                        .onDelete { offsets in
                            for i in offsets {
                                let name = sounds.imported[i]
                                if sound == .imported(name) { sound = .attention }
                                sounds.delete(name)
                            }
                        }
                    }
                } header: {
                    Text("Sound")
                } footer: {
                    Text("Imported sounds are trimmed to 29 seconds. Swipe left on one to delete it.")
                }

                // 3. Send it
                Section {
                    Stepper("Delay: \(Int(delay)) s", value: $delay, in: 1...60)
                    Button {
                        notifier.fire(title: title, body: message, sound: sound, delay: delay)
                        status = "Sending in \(Int(delay)) s. Lock your phone now."
                    } label: {
                        Label("Send notification", systemImage: "bell.badge.fill")
                            .bold()
                    }
                } footer: {
                    Text("Tap Send, then lock the phone to see it on the Lock Screen.")
                }

                // 4. Quick-fill templates
                Section("Templates (tap to fill the message)") {
                    ForEach(EASCatalog.all) { event in
                        Button {
                            title = event.name
                            message = event.sampleMessage
                            status = "Loaded \(event.code)"
                        } label: {
                            HStack {
                                Text(event.code)
                                    .font(.system(.body, design: .monospaced)).bold()
                                Text(event.name)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }

                // 5. Built-in sounds you can listen to in the app
                Section {
                    Stepper("System sound #\(systemSoundID)", value: $systemSoundID, in: 1000...1400)
                    Button {
                        AudioServicesPlaySystemSound(SystemSoundID(systemSoundID))
                    } label: {
                        Label("Play system sound", systemImage: "play.circle")
                    }
                    Button {
                        tone.toggle()
                    } label: {
                        Label(tone.isPlaying ? "Stop attention tone" : "Play attention tone in app",
                              systemImage: tone.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    }
                } header: {
                    Text("Built-in iPhone sounds (listen only)")
                } footer: {
                    Text("iOS lets apps play these inside the app, but not use them as the notification sound. Some numbers are silent.")
                }

                // 6. Do Not Disturb
                Section("Getting through Do Not Disturb") {
                    Text("Settings > Focus > Do Not Disturb > Apps > Add > EAS Tester. Do the same for any other Focus you use (Sleep, Work…).")
                    Text("Silent mode (the switch or Action button) still mutes notification sounds. Turn the ringer on to hear them.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("EAS Tester")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { notifier.cancelAll() }
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.audio]) { result in
                switch result {
                case .success(let url):
                    do {
                        let name = try sounds.importSound(from: url)
                        sound = .imported(name)
                        status = "Imported \((name as NSString).deletingPathExtension)"
                    } catch {
                        status = "Import failed: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    status = "Import failed: \(error.localizedDescription)"
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let status {
                    Text(status)
                        .font(.footnote)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
