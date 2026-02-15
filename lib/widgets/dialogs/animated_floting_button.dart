// lib/widgets/common_expandable_fab.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart'; // For default colors

// --- The Model (can be in the same file or a separate one) ---
class FabActionItem {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const FabActionItem({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });
}

// --- The Reusable Widget ---
@immutable
class ExpandableFloatingActionButton extends StatefulWidget {
  final List<FabActionItem> children;
  final double distance;
  final double startAngle;
  final double spaceBetween;

  const ExpandableFloatingActionButton({
    super.key,
    required this.children,
    this.distance = 90.0,   // <<< RESTORED: Default distance from your original code
    this.startAngle = 90.0, // Start straight up
    this.spaceBetween = 40.0, // <<< RESTORED: Step value from your original code
  });

  @override
  State<ExpandableFloatingActionButton> createState() => _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState extends State<ExpandableFloatingActionButton> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _ActionButton({required FabActionItem item}) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      clipBehavior: Clip.antiAlias,
      color: item.backgroundColor,
      elevation: 4,
      child: InkWell(
        onTap: (){item.onPressed();
        _toggle();
        },
        child: Padding(
          // <<< RESTORED: Your original padding for correct button size
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Text(
            item.label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return IgnorePointer(
      ignoring: !_open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(!_open ? 0.7 : 1.0, !_open ? 0.7 : 1.0, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: !_open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "common_fab_close", // Use a unique heroTag
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.close_rounded),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final buttons = <Widget>[];
    final count = widget.children.length;

    // This loop now uses your new parameters for positioning
    for (var i = 0; i < count; i++) {
      // The angle for each button is now fully controllable
      final double angleInDegrees = widget.startAngle - (i * widget.spaceBetween);
      buttons.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: _ActionButton(item: widget.children[i]),
        ),
      );
    }
    return buttons;
  }

  // <<< RESTORED: This is your exact _buildTapToOpenFab implementation >>>
  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(_open ? 0.7 : 1.0, _open ? 0.7 : 1.0, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "common_fab_open", // Use a unique heroTag
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

// <<< RESTORED: This is your exact _ExpandingActionButton implementation with corrected positioning >>>
@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          // <<< RESTORED: Your original positioning values for correct alignment
          right: -10 + offset.dx,
          bottom: 6 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }

}