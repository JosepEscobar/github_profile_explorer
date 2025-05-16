import SwiftUI

@main
struct GitHubExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadApp()
            } else {
                iPhoneApp()
            }
            #elseif os(macOS)
            MacOSApp()
            #elseif os(tvOS)
            TVOSApp()
            #elseif os(visionOS)
            VisionOSApp()
            #endif
        }
    }
}
