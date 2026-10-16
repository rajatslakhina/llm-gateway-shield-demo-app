# GatewayShield Demo

**Watch a real abuse-resistant LLM gateway separate people from scrapers, account farms and forgers, live, on one iOS screen.** This app is the runnable companion to **[llm-gateway-shield-kit](https://github.com/rajatslakhina/llm-gateway-shield-kit)**. It runs a real `ShieldGateway` and real `GatewayClient`s against simulated traffic, then shows what the gateway decided, and why, for every account.

## Why this matters

If your iOS app calls an LLM, the endpoint behind it is an API anyone can script. The library's README covers the design: device-bound requests, a replay window, reserve-and-settle token budgets, and explainable distillation scoring. This app makes those decisions visible:

- **Findings**: what the gateway did in this scenario, each shown with a pass or fail mark.
- **Traffic**: one row per account, with served/total calls, tokens served, how many calls hit step-up, block, budget or throttle, the final enforcement level, and a sparkline of the risk score after every call.
- **Why X scored N**: tap any row to see that account's score broken down by feature (novelty, machine cadence, length saturation, refusal probing, volume) against the step-up, throttle and block thresholds.
- **Gateway counters**: requests received and served, output tokens, and rejections by reason.

There are four scenarios, picked with a segmented control at the top:

| Scenario | What happens |
|---|---|
| **Day** | 24 virtual hours: eight people (one a heavy power user, one who asks something new every time), a fast sweep scraper, and a slower scraper with human-like timing. On the default seed, every person is served on every call; the sweep scraper is blocked after 10 requests, and the stealth scraper gets stuck at step-up. |
| **Farm** | Five accounts on one attested app install. Two are refused on every call by the accounts-per-key limit. The per-key budget stops the other three while every account still looks human. |
| **Fan-out** | One account sends 60 requests in concurrent waves against a 5,000-token budget. In-flight reservations never exceed 4, and the total charged never goes over the budget. |
| **Forgery** | 15 attacks, each refused or (for out-of-order delivery) correctly accepted: replay, rebinding, a tampered token cap, a forged counter, a stale counter, an unattested key, impersonating another account, a revoked key, and an expired challenge. |

The first time each scenario opens, it uses the configured seed (2026_10_16), so its numbers match the table in the library README. **↻ Run again** moves to the next seed and replays the scenario with different simulated traffic.

Everything runs in one process. App Attest signatures, session tokens, passkey user verification and the model vendor are all simulated stand-ins (see the library README's limits). There is no network access and no real App Attest.

## Screenshots

**There are no screenshots, because this app has not been run on a Simulator yet.** The scheduled run that built it had permission to control Xcode and Simulator on the author's Mac. But Xcode's only open window was someone else's unrelated workspace, and the run's rule is to stop rather than click through another person's work. Nothing was opened, built or launched locally.

## How to run it

1. `git clone https://github.com/rajatslakhina/llm-gateway-shield-demo-app.git`
2. Open `Demo.xcodeproj` in Xcode 16 or later.
3. Xcode fetches **llm-gateway-shield-kit** from GitHub as a remote Swift package. The requirement is "up to next major" from **1.0.0**, and no `Package.resolved` is committed, so Xcode resolves the newest 1.x tag (today that's v1.0.0).
4. Select the shared **Demo** scheme and an iOS 17+ Simulator, then Build & Run.

`Demo/DemoApp.swift` owns the `LabConfiguration` (seed plus gateway policy) that the library's `ShieldLabView` runs against. To try a different policy, change it there.

## Repo layout

```
Demo.xcodeproj/                     hand-written project (objectVersion 60), shared "Demo" scheme
  project.pbxproj                   XCRemoteSwiftPackageReference → llm-gateway-shield-kit, upToNextMajor 1.0.0
Demo/DemoApp.swift                  @main App: imports GatewayShield + GatewayShieldUI
.github/workflows/ci.yml            macos-15: resolve the remote package, build Demo for the iOS Simulator
```

## Verification: what has actually happened

- **CI (builds, does not run):** [Actions](https://github.com/rajatslakhina/llm-gateway-shield-demo-app/actions). The `macos-15` job runs two steps:
  - `xcodebuild -resolvePackageDependencies` fetches the package from GitHub.
  - `xcodebuild build -scheme Demo -destination 'generic/platform=iOS Simulator'` builds the app.

  **Result:** green on Xcode 16.4 (`macos-15` runner). The resolve step logged `GatewayShield: https://github.com/rajatslakhina/llm-gateway-shield-kit.git @ 1.0.0`, which shows the remote package really resolves from GitHub, and the app compiled against it.
- **Simulator run:** **not done.** The app has never been launched on a Simulator or a device. "It builds in CI" is the strongest claim this repo can make.
- **Library:** 81 tests pass on Linux, and the library's own CI is green on Linux and macOS at v1.0.0. That macOS job also compiles the SwiftUI screen this app shows.
- **Review:** two independent review rounds before release. Round 1 failed with 3 blocking issues, all fixed. Round 2 passed with minor notes, which were addressed.

## License

MIT
