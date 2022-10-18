import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

let localHelper = LocalHelper(name: "MyPlugin")

let project = Project.app(name: "Roughly",
                          platform: .iOS,
                          additionalTargets: ["RoughlyKit", "RoughlyUI"])
