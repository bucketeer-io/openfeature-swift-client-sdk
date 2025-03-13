# Bucketeer - OpenFeature Swift provider

This is the official Swift OpenFeature provider for accessing your feature flags with [Bucketeer](https://bucketeer.io/).

[Bucketeer](https://bucketeer.io) is an open-source platform created by [CyberAgent](https://www.cyberagent.co.jp/en/) to help teams make better decisions, reduce deployment lead time and release risk through feature flags. Bucketeer offers advanced features like dark launches and staged rollouts that perform limited releases based on user attributes, devices, and other segments.

In conjunction with the [OpenFeature SDK](https://openfeature.dev/docs/reference/concepts/provider) you will be able to evaluate your feature flags in your **iOS**/**tvOS** applications.

> [!WARNING]
> This is a beta version. Breaking changes may be introduced before general release.

For documentation related to flags management in Bucketeer, refer to the [Bucketeer documentation website](https://docs.bucketeer.io/sdk/client-side/ios).

## Supported iOS and Xcode versions

Minimum build tool versions:

| Tool  | Version |
| ----- | ------- |
| Xcode | 16.0+   |
| Swift | 5.0+    |

Minimum device platforms:

| Platform | Version |
| -------- | ------- |
| iOS      | 14.0    |
| tvOS     | 14.0    |

## Installation

### Swift Package Manager

With <a href="https://github.com/apple/swift-package-manager">Swift Package Manager</a>, add a <a href="https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app">package dependency to your Xcode project</a>. 

Select **File > Swift Packages > Add Package Dependency** and enter the repository URL: `https://github.com/bucketeer-io/openfeature-swift-client-sdk.git`.

Next select the product "BucketeerOpenFeature" and add it to your app target.

## Usage

### Initialize the provider

Bucketeer provider needs to be created and then set in the global OpenFeatureAPI.

```swift
import BucketeerOpenFeature
import OpenFeature
import Bucketeer

do {
  // SDK configuration
  let userId = "targetingUserId"
  let config = try BKTConfig.Builder()
    .with(apiKey: "YOUR_API_KEY")
    .with(apiEndpoint: "YOUR_API_ENDPOINT")
    .with(featureTag: "YOUR_FEATURE_TAG")
    .with(appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
    .build()
    let provider = BucketeerProvider(config: config)
    // User configuration
    let context = MutableContext(
        targetingKey: userId,
        structure: MutableStructure(
            attributes: [:] // The user attributes are optional
        )
    )

    // Set context before initialize
    await OpenFeatureAPI.shared.setProviderAndWait(provider: provider, initialContext: context)
} catch {
  // Error handling
}
```

See our [documentation](https://docs.bucketeer.io/sdk/client-side/ios) for more SDK configuration.

The evaluation context allows the client to specify contextual data that Bucketeer uses to evaluate the feature flags.

The `targetingKey` is the user ID (Unique ID) and cannot be empty.

### Update the Evaluation Context

You can update the evaluation context with the new attributes if the user attributes change.

```swift
let ctx = MutableContext(targetingKey: userId,  structure: MutableStructure(
            attributes: ["buyer":"true"]
        ))
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: ctx)
```

> [!WARNING]
> Changing the `targetingKey` is not supported in the current implementation of the BucketeerProvider.

To change the user ID, the BucketeerProvider must be removed and reinitialized.

```swift
// Remove the provider
OpenFeatureAPI.shared.clearProvider()
// Reinitialize the provider with new targetingKey
```

### Evaluate a feature flag

After the provider is set and no error is thrown, you can evaluate a feature flag using OpenFeatureAPI.

```swift
let client = OpenFeatureAPI.shared.getClient()

// Bool
client.getBooleanValue(key: "my-flag", defaultValue: false)

// String
client.getStringValue(key: "my-flag", defaultValue: "default")

// Integer
client.getIntegerValue(key: "my-flag", defaultValue: 1)

// Double
client.getDoubleValue(key: "my-flag", defaultValue: 1.1)

// Object
client.getObjectValue(key: "my-flag", defaultValue: Value.structure(["key":Value.integer("1234")])
```

> [!WARNING]
> Value.date is not supported in the current implementation of the BucketeerProvider.

## Contributing

We would ❤️ for you to contribute to Bucketeer and help improve it! Anyone can use and enjoy it!

Please follow our contribution guide [here](https://docs.bucketeer.io/contribution-guide/).

## Development

### Setup the library management
This project use [mint](https://github.com/yonaskolb/Mint) for library management.

#### Install
```sh
make install-mint
```
※You need [homebrew](https://brew.sh/) to install mint.

#### Install library
```sh
make bootstrap-mint
```

### Setup the environment xcconfig file

Execute the following Makefile to create the environment xcconfig file.<br />
This will set the **API_ENDPOINT** and the **API_KEY** for E2E Tests and the Example App.

```sh
make environment-setup
```
### Generate Xcode project file

Generate `.xcodeproj` using [XcodeGen](https://github.com/yonaskolb/XcodeGen).<br />
If `project.yml` is updated, it should be generated.

```sh
make generate-project-file
```

### Development with Xcode 

Open Xcode and import `BucketeerOpenFeatureProvider`.<br />
※You may need to generate [Xcode project file](https://github.com/bucketeer-io/ios-client-sdk?tab=readme-ov-file#generate-xcode-project-file).

### Development with command line

※You may need to generate [Xcode project file](https://github.com/bucketeer-io/ios-client-sdk?tab=readme-ov-file#generate-xcode-project-file).

Build SDK

```sh
make build
```

Build Example App

```sh
make build-example
```

To run the E2E test, set the following environment variables before building it. There is no need to set it for unit testing.

- E2E_API_ENDPOINT
- E2E_API_KEY

```sh
make build-for-testing E2E_API_ENDPOINT=<YOUR_API_ENDPOINT> E2E_API_KEY=<YOUR_API_KEY>
```

Run Unit Tests

```sh
make test-without-building
```

Run E2E Tests

```sh
make e2e-without-building
```

## Example App

To run the example app.

You must execute the Makefile `make environment-setup` to set the **API_ENDPOINT** and the **API_KEY**.<br />
You may need to generate [Xcode project file](https://github.com/bucketeer-io/ios-client-sdk?tab=readme-ov-file#generate-xcode-project-file).

## License

Apache License 2.0, see [LICENSE](https://github.com/bucketeer-io/ios-client-sdk/blob/main/LICENSE).