Vitrine Music — standalone iOS app

This is a separate native SwiftUI application inspired by Vitrine's Liquid Glass design. The existing Vitrine tweak modifies Spotify internals; this directory is a clean app and does not inject into or replace Spotify.

## Starter milestone
- SwiftUI navigation and a dark glass-inspired interface.
- Playlist URL entry with basic URL validation (no YouTube API calls yet).
- Import local audio files from Files and copy them into the app's Documents directory.
- Basic playback for imported formats supported by AVFoundation.
- GitHub Actions cloud build using Xcode 27.

## Cloud build
Open Actions → Vitrine Music — iOS Build → Run workflow. The build artifact is unsigned and is only a compile check; it is not an installable IPA. A supported signing/provisioning route is still required to install on iPhone.

## Planned modules
- PlaylistImportService: parse playlist URLs and retrieve permitted metadata.
- YouTubePlaylistClient: OAuth and documented YouTube Data API playlist operations.
- ArtworkStore: cache artwork only where permitted; prefer a genuine JPEG XL source when available and preserve a compatible fallback.
- LyricsProvider: licensed provider or user-imported lyrics files; do not scrape and store full lyrics without permission.
- LocalAudioLibrary: import and index user-provided audio.
- AudioConversionService: optional ALAC/AAC conversion; preserve originals by default.
- NowPlayingModel: playback state, queue, metadata, and artwork.

## Boundaries
YouTube API access does not grant unrestricted rights to download/cache YouTube audiovisual content or extract music. YouTube-linked tracks should remain links/playlist entries and use the official playback experience where required. Local playback is for audio files the user is permitted to store. ALAC conversion cannot restore information lost in lossy audio; Dolby Atmos is a separate spatial-audio format. Keep OAuth tokens and credentials out of source control.

The parent Vitrine project is GPL-3.0. Review its license and notices before distributing a derivative or combining code. This starter uses newly written SwiftUI code and does not reuse Spotify-specific implementation.
