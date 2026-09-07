# GTT Player

> **Disposition: archive.** GTT Player is a preserved, read-only iOS prototype. The 2026-09-07 audit found no current application consumer, build pipeline, release, device installation, or App Store distribution. Do not treat it as a shippable player.

The two-commit project explored M3U playback, VLC, Google Cast, and a direct integration with the Springfield stream service. Its CocoaPods workspace is incomplete: `Pods/` and `Podfile.lock` are absent, so a clean checkout does not build.

See [OWNERSHIP.md](OWNERSHIP.md) for the evidence, residual unknowns, and recovery requirements.

## Current contract

- **Product owner:** none; historical source is held by the Gaulatti organization.
- **Delivery target:** none.
- **Release command:** none.
- **Health proof:** none. The public App Store has no result for `com.gaulatti.ios.GTTPlayer`, and no local Xcode archive or simulator installation was found.
- **Recovery:** preserve Git history. Any revival must first name an owner and supported Apple platform, reconcile the current media-player portfolio, recreate dependencies reproducibly, secure the Springfield mutation contract, restore transport security, and add CI plus physical-device release proof.

GitHub archival is intentionally deferred until this notice is merged to `main`.
