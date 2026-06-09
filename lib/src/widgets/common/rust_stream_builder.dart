import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:janus_wallet/src/rust/api/context.dart';
import 'package:janus_wallet/src/rust/utils/bridge_helper.dart';
import 'package:janus_wallet/src/utils/app_context.dart';
import 'package:janus_wallet/src/utils/bridge_helper.dart';

/// A builder signature for the Rust FFI bridge subscription.
typedef SubscriptionBuilder<T, E extends Object> =
    Future<BridgeSubscription> Function(
      Context context,
      FutureOr<void> Function(T) onNext,
      FutureOr<void> Function(E?) onTermination,
    );

/// A builder signature for generating the child widget based on the active stream data.
typedef ValueWidgetBuilder<T> = Widget Function(BuildContext context, T data);

/// A common widget that simplifies subscribing to Rust FFI observable streams
/// and reactively rendering child widgets as the stream data changes.
class RustStreamBuilder<T, E extends Object> extends StatefulWidget {
  /// The builder function that invokes the Rust subscription API.
  final SubscriptionBuilder<T, E> subscriptionBuilder;

  /// The builder function that builds the child widget using the emitted data [T].
  final ValueWidgetBuilder<T> builder;

  /// Optional initial data to render immediately before the first event is emitted.
  final T? initialData;

  /// Optional widget builder for when the stream has not yet emitted any data
  /// and no [initialData] is provided. Defaults to a standard loader.
  final WidgetBuilder? loadingBuilder;

  /// Optional widget builder for when the stream or subscription encounters an error.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// A list of keys/dependencies. If any value in this list changes during widget updates,
  /// the old subscription is disposed, and a new one is initialized.
  ///
  /// If null (default), the subscription is initialized only once during [initState]
  /// and persists for the lifetime of this widget.
  final List<Object?>? keys;

  const RustStreamBuilder({
    super.key,
    required this.subscriptionBuilder,
    required this.builder,
    this.initialData,
    this.loadingBuilder,
    this.errorBuilder,
    this.keys,
  });

  @override
  State<RustStreamBuilder<T, E>> createState() =>
      _RustStreamBuilderState<T, E>();
}

class _RustStreamBuilderState<T, E extends Object>
    extends State<RustStreamBuilder<T, E>> {
  late Stream<T> _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _stream = convertSubscriptionToStream<T, E>((onNext, onTermination) {
      return widget.subscriptionBuilder(appContext, onNext, onTermination);
    });
  }

  @override
  void didUpdateWidget(RustStreamBuilder<T, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize subscription only if the dependencies (keys) changed.
    // This avoids constant unsubscribe/resubscribe cycles on every parent build.
    if (!const ListEquality<Object?>().equals(oldWidget.keys, widget.keys)) {
      setState(() {
        _initStream();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: _stream,
      initialData: widget.initialData,
      builder: (context, snapshot) {
        // Handle stream error state
        if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!);
          }
          return Center(
            child: Text(
              'Rust Subscription Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Handle loading state
        if (!snapshot.hasData) {
          if (widget.loadingBuilder != null) {
            return widget.loadingBuilder!(context);
          }
          return const Center(child: CircularProgressIndicator());
        }

        // Render target widget with active data
        return widget.builder(context, snapshot.data as T);
      },
    );
  }
}
