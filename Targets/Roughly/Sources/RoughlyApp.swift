import SwiftUI
import RoughlyUI

@main
struct RoughlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(inputValue: "500", unit: UnitArea.squareMeters)
        }
    }
}
