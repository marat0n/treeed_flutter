import 'package:flutter/widgets.dart';
import 'package:treeed/treeed.dart';

/// Widget for rebuilding content by `builder` when `stateToWatch` is updated.
class TreeedObservable extends StatefulWidget {
  /// Widget for rebuilding content by `builder` when `stateToWatch` is updated.
  /// Example:
  /// ```dart
  /// Center(
  ///   child: TreeedObservable(
  ///     stateToWatch: someState,
  ///     builder: (context) => Text(someState.toString())
  ///   ),
  /// )
  /// ```
  const TreeedObservable({
    super.key,
    required this.stateToWatch,
    required this.builder,
  });

  /// Provided state will be watched for updates.
  /// If any update is triggered then content will be rebuilt by `builder` function.
  final TreeedUpdatable stateToWatch;

  /// Function for rebuilding updatable content. Rebuilds when `stateToWatch` fires an update event.
  final Widget Function(BuildContext) builder;

  @override
  State<StatefulWidget> createState() => _TreeedObservableState();
}

class _TreeedObservableState extends State<TreeedObservable> {
  @override
  void initState() {
    super.initState();
    widget.stateToWatch.listen(wrappedSetState);
  }

  void wrappedSetState(dynamic _) => (context as Element).markNeedsBuild();

  @override
  void dispose() {
    super.dispose();
    widget.stateToWatch.unlisten(wrappedSetState);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: widget.builder(context));
  }
}

/// Same as `TreeedObservable` but with animation feature.
class TreeedAnimatedObservable extends StatefulWidget {
  const TreeedAnimatedObservable({
    super.key,
    required this.changingDuration,
    required this.stateToWatch,
    required this.builder,
    this.transitionBuilder,
  });

  /// Provided state will be watched for updates. If any update is triggered then content will be rebuilt by `builder` function.
  final TreeedUpdatable stateToWatch;

  /// Function for rebuilding updatable content. Rebuilds when `stateToWatch` fires an update event.
  final Widget Function(BuildContext) builder;

  /// Time of the animation from `transitionBuilder` to complete.
  final Duration changingDuration;

  // Animation building function for transitioned animation between two `builder` calls.
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  @override
  State<StatefulWidget> createState() => _TreeedAnimatedObservableState();
}

class _TreeedAnimatedObservableState extends State<TreeedAnimatedObservable> {
  @override
  void initState() {
    super.initState();
    widget.stateToWatch.listen(wrappedSetState);
  }

  void wrappedSetState(dynamic _) => (context as Element).markNeedsBuild();

  @override
  void dispose() {
    super.dispose();
    widget.stateToWatch.unlisten(wrappedSetState);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.changingDuration,
      transitionBuilder:
          widget.transitionBuilder ??
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child: widget.builder(context),
    );
  }
}

/// Mixin for widget's `State` that enables `TreeedGroup`-like functionality.
/// Every state created with `treeedState` function will automatically fire the `callUpdateState` event which calls `setState` if any that state's values has been changed.
mixin TreeedWidget<TWidget extends StatefulWidget> on State<TWidget> {
  void callUpdateState(_) => setState(() {});

  TreeedState<T> treeedState<T>(T value) =>
      TreeedState(value)..listen(callUpdateState);
}
