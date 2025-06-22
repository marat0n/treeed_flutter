import 'package:flutter/widgets.dart';
import 'package:treeed/treeed.dart';

class TreeedObservable extends StatefulWidget {
  const TreeedObservable({
    super.key,
    required this.stateToWatch,
    required this.builder,
  });

  final TreeedUpdatable stateToWatch;
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

class TreeedAnimatedObservable extends StatefulWidget {
  const TreeedAnimatedObservable({
    super.key,
    required this.changingDuration,
    required this.stateToWatch,
    required this.builder,
    this.transitionBuilder,
  });

  final TreeedUpdatable stateToWatch;
  final Widget Function(BuildContext) builder;
  final Duration changingDuration;
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
