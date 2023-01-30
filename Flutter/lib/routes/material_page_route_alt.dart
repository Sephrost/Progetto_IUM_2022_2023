import 'package:flutter/material.dart';

/// Alternative material page route that allows to set the transition duration
/// and the direction of the transition.
class MaterialPageRouteAlt extends MaterialPageRoute {
  /// The duration of the transition.
  final Duration duration;

  /// The direction of the transition.
  /// It can be [AxisDirection.up], [AxisDirection.down], [AxisDirection.left]
  /// or [AxisDirection.right].
  final AxisDirection direction;

  @override
  Duration get transitionDuration => duration;

  MaterialPageRouteAlt({
    required WidgetBuilder builder,
    required AxisDirection fromDirection,
    required Duration transitionDuration,
    super.settings,
  })  : direction = fromDirection,
        duration = transitionDuration,
        super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
        position:
            Tween(begin: getBeginOffset(), end: Offset.zero).animate(animation),
        child: child);
  }

  Offset getBeginOffset() {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }
}
