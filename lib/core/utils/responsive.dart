import 'package:flutter/widgets.dart';

/// Returns true when the current device is tablet-sized.
///
/// Uses the shortest side of the screen so it stays correct in both
/// portrait and landscape. 600dp is the conventional Material breakpoint
/// separating phones from tablets / iPads.
bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;
