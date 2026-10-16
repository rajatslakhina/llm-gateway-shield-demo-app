import SwiftUI
import GatewayShield
import GatewayShieldUI

/// Entry point. The app owns the gateway configuration that every lab run uses.
/// That configuration is a `GatewayShield` (core) type, which is why the app
/// imports the core module as well as the UI one: to ship a different policy,
/// change it here, not inside the library.
@main
struct DemoApp: App {
    private let configuration = LabConfiguration(
        seed: 2026_10_16,          // fixed seed: every launch replays the same traffic
        gateway: .standard         // 60k tokens/day per account, 120k per device, 3 accounts per key
    )

    var body: some Scene {
        WindowGroup {
            ShieldLabView(configuration: configuration)
        }
    }
}
