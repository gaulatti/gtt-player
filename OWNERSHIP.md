# GTT Player ownership and disposition audit

Historical audit notes dated: 2026-09-07

Default branch and audited commit: `main` at `66fc324ca1c6ec1fe160c29cc381a373c6e54079`

## Decision

**Disposition: archive after this audit lands on the default branch.**

No live application, distribution, package, or repository consumer was verified. The repository is an incomplete two-commit prototype whose only external product dependency is the separately owned Springfield service. Source and history remain available for recovery; GitHub archival is a post-merge step so this notice reaches `main` first.

## Historical audit notes and evidence limits

The following table preserves the September observations. Their underlying
GitHub, consumer-search, Apple, local-distribution, HTTP, and build command
outputs are not retained with this PR and have not been reproduced in the
2026-10-19 documentation review. They are unverified historical reports, not
proof of current absence, a passing build, or exhaustive distribution coverage.
Immutable repository source can establish source contents and missing tracked
workspace inputs; it cannot establish external installation or ownership.

| Surface | Recorded method | Recorded result (external/build reports unverified) |
| --- | --- | --- |
| Git source | GitHub repository, branch, commit, tag, and tree APIs | Public, unarchived repository with one unprotected `main` branch, two commits ending 2025-05-27, no tags, no description, and no homepage. |
| Application identity | Inspected Xcode project settings and `Info.plist` | iOS application `GTTPlayer`, version 1.0 build 1, bundle identifier `com.gaulatti.ios.GTTPlayer`; no store identifier or release metadata. |
| Source behavior | Inspected all Swift files, the project/workspace, and Podfile | Prototype M3U browser/player using Google Cast and MobileVLCKit. It directly performs unauthenticated GET/POST/DELETE requests against Springfield stream routes and allows arbitrary transport loads. |
| Build reproducibility | `xcodebuild -list` and a code-signing-disabled generic iOS Simulator build from a clean checkout | Project and scheme enumerate, but the build fails before compilation because the referenced CocoaPods xcconfig is absent. `Pods/` and `Podfile.lock` are not committed. |
| Tests | Inspected unit and UI test targets | Only generated placeholder tests exist; they prove no product behavior. |
| Actions and schedules | GitHub Actions workflow and run APIs | No workflow and no run exists. |
| Releases, deployments, and environments | GitHub releases, deployments, and environments APIs | No tag, release, deployment, or environment exists. |
| Pages, webhooks, and credentials | GitHub Pages, hooks, Actions secrets, and variables APIs | No Pages site, webhook, Actions secret name, or variable exists. No credential value was requested or read. |
| Rules and security | Branch-protection and vulnerability-alert APIs | `main` is unprotected and vulnerability alerts are disabled. |
| Portfolio consumers | Exact local searches under `/Users/gaulatti/source` plus authenticated GitHub code searches for the repository, product, bundle identifier, parser, VLC dependency, and Springfield route | No external application target, import, package reference, documentation link, or copied implementation was found. Matches are confined to this repository. |
| Apple distribution | Public App Store lookup for the exact bundle identifier | The dated lookup reportedly returned no result; this does not establish universal public absence or exclude private distribution. |
| Local distribution artifacts | Searched local Xcode Archives and installed simulator application metadata for the product/bundle identifier | No archive or simulator installation was found. |
| External runtime | Resolved the hard-coded Springfield hostname and sent only `GET /streams` | The hostname resolves, but the HTTPS route returns 502. Springfield is a separate service dependency, not evidence that GTT Player is installed or distributed. No POST or DELETE was sent. |
| Cloud/package surface | Source and portfolio identifier search | The repository defines no server infrastructure, cloud resource, package manifest, DNS name for itself, or package/store publication path. |

## Before and after

Before this audit, the repository had no README, ownership contract, build/release instructions, or warning that the checked-in workspace cannot build cleanly.

After this audit:

- the README records the archive disposition and absent delivery contract;
- this ledger preserves the checked surfaces, build failure, security concerns, and residual unknowns;
- no application source, Xcode setting, dependency declaration, signing identity, external service, or historical commit is changed;
- no executable deployment or scheduled workflow exists to disable.

## Historical validation notes (not current-run receipts)

| Check | Result |
| --- | --- |
| `xcodebuild -list -project GTTPlayer.xcodeproj` | Passed; the app, unit-test, and UI-test targets and the `GTTPlayer` scheme enumerate. |
| Generic iOS Simulator build with signing disabled | Fails because `Pods/Target Support Files/Pods-GTTPlayer/Pods-GTTPlayer.debug.xcconfig` is missing. This is the clean-checkout baseline, not a regression from the documentation-only audit. |
| `ruby -c Podfile` | Validates the Podfile syntax without installing dependencies. |
| `plutil -lint` for `Info.plist` and scheme-management metadata | Passed. |
| `xmllint --noout` for both workspace documents | Validates the committed workspace XML without resolving dependencies. |
| `git diff --check` | Must pass before handoff. |

## Residual unknowns

- App Store Connect and TestFlight inventory were unavailable; only the public store was queried.
- Physical devices outside the local host could retain an old development build.
- External developer machines or private artifacts were not inventoried.
- Springfield's current ownership, authorization, and retention contracts are outside this repository audit.

These unknowns establish neither a current delivery contract nor universal
absence. Before changing the repository archive setting, the owner must refresh
GitHub and distribution state, retain the results, and stop if ownership or a
recovery dependency appears. Merging this documentation does not archive it.

## Recovery contract

Recovery begins from Git history on a new branch. A named owner must first decide whether GTT Player has a distinct role from the current Gaulatti media applications. If it does, recovery must define supported Apple platforms and devices, replace the unpinned CocoaPods workspace with a reproducible dependency graph, remove blanket arbitrary-load transport policy, authenticate and authorize Springfield mutations, add functional parser/playback tests, establish CI, define signing and secrets ownership, and prove an immutable build on a named physical device before distribution.

There is no production rollback for archival because no production installation or distribution was verified. If authoritative ownership evidence appears, unarchive the repository and revert the audit commit before beginning recovery.
