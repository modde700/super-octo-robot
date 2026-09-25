import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var notifier = NotificationManager.shared
    @StateObject private var tone = ToneGenerator()
    @State private var delay: Double = 3
    @State private var lastFired: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        tone.toggle()
                    } label: {
                        Label(tone.isPlaying ? "Stop attention tone" : "Preview attention tone",
                              systemImage: tone.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    }
                    VStack(alignment: .leading) {
                        Text("Notification delay: \(Int(delay))s")
                            .font(.caption).foregroundStyle(.secondary)
                        Slider(value: $delay, in: 1...10, step: 1)
                    }
                } header: {
                    Text("Preview")
                } footer: {
                    Text("Tap an event below to fire a local notification after the delay. Lock or background the app to see it arrive with the alert sound. Everything here is local to this device — nothing is transmitted.")
                }

                Section("Event codes") {
                    ForEach(EASCatalog.all) { event in
                        Button {
                            notifier.fire(event: event, delay: delay)
                            lastFired = "\(event.code) queued — \(Int(delay))s"
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(event.code)
                                        .font(.system(.body, design: .monospaced)).bold()
                                    Text(event.name)
                                }
                                Text(event.sampleMessage)
                                    .font(.caption).foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("EAS Tester")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { notifier.cancelAll() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let lastFired {
                    Text(lastFired)
                        .font(.footnote).padding(8)
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
