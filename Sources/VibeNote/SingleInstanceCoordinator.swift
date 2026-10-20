import AppKit

enum SingleInstanceCoordinator {
    private static let bundleIdentifier = "com.vibenote.VibeNote"

    /// Returns true when another VibeNote process owns the application identity.
    /// LaunchServices normally enforces this through the bundle declaration; the
    /// explicit check also covers development launches of the packaged binary.
    static func activateExistingInstance() -> Bool {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        guard let existing = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            .first(where: { $0.processIdentifier != currentPID && !$0.isTerminated }) else {
            return false
        }

        existing.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        return true
    }
}
