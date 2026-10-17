import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

private enum MusicTab: Hashable {
    case listen
    case library
    case importPlaylist
    case settings
}

struct ContentView: View {
    @State private var selectedTab: MusicTab = .listen

    var body: some View {
        TabView(selection: $selectedTab) {
            ListenView()
                .tabItem { Label("Listen", systemImage: "waveform") }
                .tag(MusicTab.listen)

            LocalAudioLibraryView()
                .tabItem { Label("Library", systemImage: "square.stack") }
                .tag(MusicTab.library)

            PlaylistImportView()
                .tabItem { Label("Import", systemImage: "link") }
                .tag(MusicTab.importPlaylist)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
                .tag(MusicTab.settings)
        }
        .tint(.white)
    }
}

private struct ListenView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VITRINE MUSIC")
                            .font(.caption.weight(.semibold))
                            .tracking(2.2)
                            .foregroundStyle(.secondary)
                        Text("Your music.\nYour space.")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .tracking(-1.5)
                        Text("A personal library for the music you love.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)

                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.28, green: 0.24, blue: 0.48),
                                        Color(red: 0.10, green: 0.36, blue: 0.39),
                                        Color(red: 0.05, green: 0.07, blue: 0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Circle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 190, height: 190)
                            .offset(x: 180, y: -70)
                        Image(systemName: "waveform")
                            .font(.system(size: 72, weight: .light))
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MADE FOR YOUR LIBRARY")
                                .font(.caption.weight(.semibold))
                                .tracking(1.5)
                                .foregroundStyle(.white.opacity(0.72))
                            Text("One home for your music")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(22)
                    }
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .glassEffect(.regular, in: .rect(cornerRadius: 30))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start here")
                            .font(.title3.bold())
                        FeatureRow(
                            icon: "folder.badge.plus",
                            title: "Bring in local music",
                            subtitle: "Import audio files from the Files app."
                        )
                        FeatureRow(
                            icon: "text.badge.plus",
                            title: "Import a playlist",
                            subtitle: "Start with a YouTube or YouTube Music playlist URL."
                        )
                    }
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 46, height: 46)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.07), lineWidth: 1)
        }
    }
}

private struct PlaylistImportView: View {
    @State private var playlistURL = ""
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Paste playlist URL", text: $playlistURL, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    Button("Check playlist link", systemImage: "link") {
                        validateURL()
                    }
                    .disabled(playlistURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } header: {
                    Text("Playlist source")
                } footer: {
                    Text("This starter checks the URL only. YouTube account connection and playlist matching are planned for a later phase.")
                }

                if let message {
                    Section("Status") {
                        Text(message).font(.subheadline)
                    }
                }

                Section("Planned import flow") {
                    Label("Read playlist metadata", systemImage: "list.bullet")
                    Label("Review matched tracks", systemImage: "checkmark.circle")
                    Label("Save supported playlist entries", systemImage: "square.and.arrow.down")
                }
            }
            .navigationTitle("Import playlist")
        }
    }

    private func validateURL() {
        let candidate = playlistURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: candidate),
              let scheme = url.scheme?.lowercased(),
              scheme == "https",
              let host = url.host?.lowercased() else {
            message = "Enter a valid HTTPS playlist URL."
            return
        }

        let allowedHosts = ["youtube.com", "www.youtube.com", "music.youtube.com", "youtu.be"]
        guard allowedHosts.contains(host) else {
            message = "For this first version, enter a YouTube or YouTube Music URL."
            return
        }

        message = "Link looks valid. Playlist retrieval and track matching are not connected yet."
    }
}

private struct LocalAudioLibraryView: View {
    @State private var audioFiles: [URL] = []
    @State private var isImporterPresented = false
    @State private var player: AVAudioPlayer?
    @State private var currentlyPlaying: String?
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if audioFiles.isEmpty {
                    ContentUnavailableView(
                        "Your library is empty",
                        systemImage: "music.note.list",
                        description: Text("Import audio files you own or are permitted to store on this iPhone.")
                    )
                } else {
                    List {
                        ForEach(audioFiles, id: \.lastPathComponent) { file in
                            HStack(spacing: 12) {
                                Image(systemName: currentlyPlaying == file.lastPathComponent ? "waveform" : "music.note")
                                    .font(.title3)
                                    .frame(width: 42, height: 42)
                                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(file.deletingPathExtension().lastPathComponent)
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text(file.pathExtension.uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    play(file)
                                } label: {
                                    Image(systemName: currentlyPlaying == file.lastPathComponent ? "speaker.wave.2.fill" : "play.fill")
                                        .frame(width: 40, height: 40)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Play \(file.lastPathComponent)")
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteFiles)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Local music")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isImporterPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Import audio files")
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.ultraThinMaterial)
                }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true,
                onCompletion: importFiles
            )
            .onAppear(perform: refreshFiles)
        }
    }

    private var libraryDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LocalAudio", isDirectory: true)
    }

    private func refreshFiles() {
        do {
            try FileManager.default.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
            audioFiles = try FileManager.default.contentsOfDirectory(
                at: libraryDirectory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            .filter { !$0.hasDirectoryPath }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            statusMessage = "Couldn't load local music: \(error.localizedDescription)"
        }
    }

    private func importFiles(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            statusMessage = "Import cancelled or failed: \(error.localizedDescription)"
        case .success(let urls):
            do {
                try FileManager.default.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
                var importedCount = 0

                for sourceURL in urls {
                    let didAccess = sourceURL.startAccessingSecurityScopedResource()
                    defer {
                        if didAccess { sourceURL.stopAccessingSecurityScopedResource() }
                    }

                    var destinationURL = libraryDirectory.appendingPathComponent(sourceURL.lastPathComponent)
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        let uniqueName = UUID().uuidString + "-" + sourceURL.lastPathComponent
                        destinationURL = libraryDirectory.appendingPathComponent(uniqueName)
                    }

                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                    importedCount += 1
                }

                refreshFiles()
                statusMessage = "Imported \(importedCount) file(s)."
            } catch {
                statusMessage = "Couldn't import file: \(error.localizedDescription)"
            }
        }
    }

    private func play(_ file: URL) {
        do {
            if currentlyPlaying == file.lastPathComponent {
                player?.pause()
                currentlyPlaying = nil
                return
            }

            player = try AVAudioPlayer(contentsOf: file)
            player?.prepareToPlay()
            guard player?.play() == true else {
                statusMessage = "This file couldn't start playback."
                return
            }
            currentlyPlaying = file.lastPathComponent
            statusMessage = "Playing \(file.deletingPathExtension().lastPathComponent)"
        } catch {
            statusMessage = "Can't play this format: \(error.localizedDescription)"
        }
    }

    private func deleteFiles(at offsets: IndexSet) {
        for index in offsets {
            let file = audioFiles[index]
            if currentlyPlaying == file.lastPathComponent {
                player?.stop()
                player = nil
                currentlyPlaying = nil
            }
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                statusMessage = "Couldn't remove \(file.lastPathComponent): \(error.localizedDescription)"
            }
        }
        refreshFiles()
    }
}

private struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Library") {
                    Label("Local audio stays on this iPhone", systemImage: "iphone")
                    Label("Original files are preserved on import", systemImage: "waveform")
                }
                Section("Coming next") {
                    Label("Google account connection", systemImage: "person.crop.circle")
                    Label("Artwork cache and JPEG XL support", systemImage: "photo")
                    Label("Lyrics provider and imported LRC files", systemImage: "text.quote")
                    Label("Audio format and conversion options", systemImage: "slider.horizontal.3")
                }
                Section {
                    Text("Vitrine Music is an independent project and is not affiliated with YouTube, Google, Apple Music, or Spotify.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
