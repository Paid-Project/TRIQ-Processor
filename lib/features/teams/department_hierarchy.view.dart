import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/core/models/hierarchy_node.model.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../core/locator.dart';
import '../../resources/multimedia_resources/resources.dart';
import '../employee/add_employee/add_employee.view.dart';
import 'department/team_list.vm.dart';


class HierarchyScreen extends StatelessWidget {
  final String departmentName;
  final TeamListVM viewModel;

  const HierarchyScreen({
    Key? key,
    required this.departmentName,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TeamListVM>.reactive(
      viewModelBuilder: () => viewModel,
      disposeViewModel: false,
      builder: (context, model, child) {
        return Scaffold(
          appBar: GradientAppBar(
            title: departmentName,
          ),
          backgroundColor: AppColors.scaffoldBackground,
          body: model.isBusy
              ? const Center(child: CircularProgressIndicator())
              : model.hierarchy.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No hierarchy found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ) : ListView.builder(
            padding: EdgeInsets.only(left: 30.0, right: 14.0, top: 8.0),
            itemCount: model.hierarchy.length,
            itemBuilder: (context, index) {
              final bool isLast = index == model.hierarchy.length - 1;
              return _HierarchyNodeWidget(
                node: model.hierarchy[index],
                level: 0,
                  isLast:isLast,
                index: index,
                onEmployeeTap: (employeeId) {
                  final _navigationService= locator<NavigationService>();
                  _navigationService.navigateToView(
                    AddEmployeeView(
                      attributes: AddEmployeeViewAttributes(
                        id: employeeId,
                        hasPasswordField: false,
                        hasReadOnly: true,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ... Rest of your existing UI code (_HierarchyNodeWidget, _HierarchyCard, etc.)
// Just replace StatefulHierarchyNode with HierarchyNode

class _HierarchyNodeWidget extends StatelessWidget {
  final HierarchyNode node;
  final int level;
  final int index;
  final bool isLast;
  final Function(String)? onEmployeeTap;

  const _HierarchyNodeWidget({
    Key? key,
    required this.node,
    required this.level,
    required this.index,
    this.onEmployeeTap,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: node,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (level > 0)
                  Positioned(
                    left: -15.0,
                    top: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _IncomingLinePainter(lineColor: node.color),
                    ),
                  ),
                _HierarchyCard(
                  node: node,
                  onTap: () => onEmployeeTap?.call(node.id),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              curve: Curves.easeOut,
              child: ( node.children.isNotEmpty)
                  ? Stack(
                children: [
                  Builder(
                    builder: (context) {

                      return CustomPaint(
                        painter: _TrunkLinePainter(
                          childCount: getTotalChildren(node,isLastBranch: isLast,index: index),
                          lineColor:  node.children.first.color,
                        ),
                      );
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(node.children.length, (index) {
                        // ✨ CORE LOGIC IS HERE
                        // Check if the current child is the last one in the parent's list
                        final bool isLast = index == node.children.length - 1;

                        // Create the child widget and pass the `isLast` flag down
                        return _HierarchyNodeWidget(
                          node: node.children[index],
                          level: level + 1,
                          onEmployeeTap: onEmployeeTap,
                          isLast: isLast,
                          index: index,
                        );
                      }),
                    ),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

int _subtreeCardCount(HierarchyNode node) {
  int total = 1; // this node
  for (final c in node.children) {
    total += _subtreeCardCount(c);
  }
  return total;
}

// Total height (in pixels) of the children area of a node
double _childrenAreaHeight(HierarchyNode node) {
  int tiles = 0;
  for (final c in node.children) {
    tiles += _subtreeCardCount(c);
  }
  return tiles * _kTotalCardHeight;
}

// This is the count your _TrunkLinePainter needs.
// It equals: sum(subtreeCount of all previous children) + 1
int getTotalChildren(
    HierarchyNode node, {
      required bool isLastBranch, // not needed for trunk length
      required int index,         // not needed for trunk length
    }) {
  final n = node.children.length;
  if (n == 0) return 0; // no trunk
  int sumPrev = 0;
  for (int i = 0; i < n - 1; i++) {
    sumPrev += _subtreeCardCount(node.children[i]);
  }
  return sumPrev + 1; // +1 => reach last child's center
}
class _HierarchyCard extends StatelessWidget {
  final HierarchyNode node;
  final VoidCallback? onTap;

  const _HierarchyCard({Key? key, required this.node, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: node.color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 4,
        //     offset: const Offset(0, 10))
        // ]
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:  onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Profile Image
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: node.profilePhoto != null
                    ? ClipOval(
                  child: Image.network(
                    'https://live.triqinnovations.com${node.profilePhoto}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppImages.team_default,
                        width: 40,
                        height: 40,
                      );
                    },
                  ),
                )
                    : ClipOval(
                  child: Image.asset(
                    AppImages.team_default,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      node.designation?.name.toString().capitalizeWords ?? 'No designation',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // if (node.children.isNotEmpty)
              //   AnimatedRotation(
              //     turns: node.isExpanded ? 0.25 : 0,
              //     duration: const Duration(milliseconds: 300),
              //     child: const Icon(
              //       Icons.arrow_forward_ios,
              //       size: 16,
              //       color: Colors.black54,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}


const double _kCardHeight = 72.0;
const double _kCardVerticalMargin = 6;
const double _kTotalCardHeight = _kCardHeight + (_kCardVerticalMargin * 2);
const double _kIndent = 15.0;
const double _kCurveRadius = 10.0;


class _IncomingLinePainter extends CustomPainter {
  final Color lineColor;
  _IncomingLinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    const double lineTargetY = _kTotalCardHeight / 2;

    // 1. Path ko -_kIndent se shuru karein (curve ke start point par)
    path.moveTo(-_kIndent, lineTargetY - _kCurveRadius);

    // 2. Curve ko -_kIndent se aage draw karein
    path.arcToPoint(
      // Arc ka end point ab (-_kIndent + _kCurveRadius) hoga
      Offset(-_kIndent + _kCurveRadius, lineTargetY),
      radius: const Radius.circular(_kCurveRadius),
      clockwise: false,
    );

    // 3. Horizontal line ko child (_kIndent) tak draw karein
    //    (Maine aapka extra 'lineTo(-_kIndent...)' nikal diya hai)
    path.lineTo(_kIndent, lineTargetY);

    // 4. Arrow head draw karein
    path.moveTo(_kIndent - 7, lineTargetY - 5);
    path.lineTo(_kIndent, lineTargetY);
    path.lineTo(_kIndent - 7, lineTargetY + 5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IncomingLinePainter oldDelegate) => false;
}

// --- Painter for the Vertical Trunk connecting all children ---
class _TrunkLinePainter extends CustomPainter {
  final int childCount;
  final Color lineColor;

  _TrunkLinePainter({required this.childCount, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // The vertical line starts from the top and goes down to the last child's connection point
    double startY = (_kTotalCardHeight / 2 )-85;
    double endY = (childCount - 1) * _kTotalCardHeight + (_kTotalCardHeight / 2)-7.2;

    // Draw the single vertical trunk line
    canvas.drawLine(
      Offset(-_kIndent, startY),
      Offset(-_kIndent, endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TrunkLinePainter oldDelegate) {
    return oldDelegate.childCount != childCount || oldDelegate.lineColor != lineColor;
  }
}
