# RoutingKit

![iOS](https://img.shields.io/badge/iOS-v16.0%2B-blue?logo=apple&logoColor=white)
![watchOS](https://img.shields.io/badge/watchOS-v9.0%2B-green?logo=apple&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-v13.0%2B-orange?logo=apple&logoColor=white)

RoutingKit is a lightweight and modular Swift library designed to simplify navigation in SwiftUI applications. It provides tools for managing navigation stacks, sheets, and alerts while maintaining a clean and intuitive API.

## Features

- **Navigate through stacks**: Seamlessly manage a `NavigationStack` for hierarchical navigation.
- **Sheet navigation**: Present and manage modal views (sheets).
- **Alert handling**: Display and manage SwiftUI alerts with actions and custom views.
- **Custom dismiss options**: Flexible dismissal options for views, including navigating back to root or specific levels.
- **Navigation Transition**: Zoom transition available on iOS and iPadOS platform.

## Installation

RoutingKit can be integrated into your project using the Swift Package Manager (SPM) with the following URL:
```
https://github.com/marcotammaro/RoutingKit.git
```

## Usage

### Imports

Start by importing RoutingKit in your SwiftUI files.

```swift
import RoutingKit
```

### Setup

Create a `Router` and pass it to `RoutableRootView` at the highest View in your App.

```swift
@MainActor let router = Router()

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RoutableRootView(router: router) {
                ...
            }
        }
    }
}

```

### Defining Destinations

Define a `Destination` that will represents a navigable view:

```swift
let myDestination = Destination {
    Text("Hello, RoutingKit!")
}
```

You can also create alerts using `AlertDestinationProtocol` or use the convenient preconfigured `TextAlert` and it's custom actions `TextAlertAction`, sample implementations have been provided in the Example project.

### Navigation

Use the `Router` instance to handle navigation:

- **Push to destination (using `NavigationStack`):**

  ```swift
  router.push(to: myDestination)
  ```

- **Present a modal sheet (using `.sheetItem`):**

  ```swift
    router.sheet(to: myDestination)
  ```

- **Show an alert (using `.alert`):**

  ```swift
    router.showAlert(title: "Alert Title", message: "This is an alert.")
  ```

### Customizing Dismiss Behavior

With RoutingKit you can simply dismiss a view by calling:
```swift
router.dismiss()
```

Moreover, `dismiss` function provides advanced dismiss options:

```swift
router.dismiss(option: .toRoot) // Dismiss to root
router.dismiss(option: .toPreviousView) // Dismiss one level
router.dismiss(option: .toNavigationBegin) // Dismiss to the nearest path node
```

## Example

Here's a complete example, more advanced use case have been provided in Example project:

```swift
import SwiftUI
import RoutingKit

@MainActor let router = Router()

struct ContentView: View {
    var body: some View {
        RoutableRootView(router: router) {

            Button("Push View") {
                let destination = Destination {
                    Text("Hello, this page has been pushed by RoutingKit!")
                }
                router.push(to: destination)
            }

            Button("Sheet View") {
                let destination = Destination {
                    Text("Hello, this page has been displayed by RoutingKit!")
                }
                router.push(to: destination)
            }

            Button("Show Alert") {
                router.showAlert(
                  title: "This is an Alert", 
                  message: "Presented by RoutingKit!"
                )
            }

        }
    }
}
```

## License

This library is released under the MIT License. See the LICENSE file for more details.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve RoutingKit.

## Contact

Created by Marco Tammaro - [GitHub Profile](https://github.com/marcotammaro)
