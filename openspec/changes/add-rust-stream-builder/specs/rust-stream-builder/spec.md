## ADDED Requirements

### Requirement: RustStreamBuilder creation and generic typing
The system SHALL provide a generic Flutter widget named `RustStreamBuilder<T, E extends Object>` that facilitates subscribing to Rust FFI streams. The widget MUST require:
- A `subscriptionBuilder` function taking `Context` (the Rust API context), `onNext`, and `onTermination` callbacks and returning a `Future<BridgeSubscription>`.
- A `builder` function taking `BuildContext` and data `T` and returning a `Widget`.

#### Scenario: Instantiating the builder with data and child builders
- **WHEN** the `RustStreamBuilder` is instantiated with valid `subscriptionBuilder` and `builder` parameters
- **THEN** the widget is successfully constructed with type parameters `<T>` and `<E>` matching the Rust stream signatures

### Requirement: Stream lifecycle management
The widget SHALL manage the lifecycle of the underlying Rust stream by converting the subscription builder to a stream on initialization, subscribing to it, and disposing of the subscription automatically when the widget is removed from the widget tree.

#### Scenario: Stream subscription and automatic disposal
- **WHEN** the `RustStreamBuilder` enters the widget tree and is subsequently disposed of
- **THEN** the Rust subscription is initialized, and upon disposal, the `.dispose()` method of the `BridgeSubscription` is invoked to prevent memory leaks

### Requirement: Parent rebuild stability via dependency keys
The widget SHALL support an optional `keys` dependency list. The underlying Rust stream subscription SHALL NOT be re-created during parent widget rebuilds unless the values in the `keys` list change.

#### Scenario: Rebuilding parent without key changes
- **WHEN** the parent widget rebuilds but the `keys` list of `RustStreamBuilder` remains unchanged
- **THEN** the existing Rust stream subscription persists and is not recreated or disposed of

#### Scenario: Rebuilding parent with key changes
- **WHEN** the parent widget rebuilds and one or more values in the `keys` list of `RustStreamBuilder` changes
- **THEN** the previous Rust subscription is disposed of and a new subscription is initialized

### Requirement: Loading and error state presentation
The widget SHALL support optional parameters for customizable UI presentation during loading and error states:
- `initialData` of type `T?`.
- `loadingBuilder` of type `WidgetBuilder?`.
- `errorBuilder` of type `Widget Function(BuildContext, Object)?`.

#### Scenario: Custom loading widget before stream emits
- **WHEN** the stream has not yet emitted any data, `initialData` is null, and a custom `loadingBuilder` is provided
- **THEN** the custom widget returned by `loadingBuilder` is rendered

#### Scenario: Custom error widget on stream error
- **WHEN** the Rust stream emits an error of type `E` and a custom `errorBuilder` is provided
- **THEN** the widget returned by `errorBuilder` is rendered with the error object
