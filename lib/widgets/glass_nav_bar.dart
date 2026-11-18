import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/color.dart';

/// One button of the bottom bar.
class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating frosted-glass bottom bar.
/// - A soft pill slides under the selected tab.
/// - The selected icon grows and the label brightens.
/// - The button at [centerIndex] is a glowing action button.
/// - A light tap feedback is played on every selection.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.centerIndex,
    required this.onSelected,
  });

  static const double _height = 72;

  final List<GlassNavItem> items;
  final int selectedIndex;
  final int centerIndex;
  final ValueChanged<int> onSelected;

  void _tap(int index) {
    HapticFeedback.selectionClick();
    onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(34);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: _height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: ColoredBox(
                  color: AppColors.sheetFill.withValues(alpha: 0.5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(color: AppColors.glassBorder),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x33FFFFFF), Color(0x0FFFFFFF)],
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / items.length;
                        final showPill = selectedIndex != centerIndex;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 380),
                              curve: Curves.easeOutCubic,
                              left: selectedIndex * itemWidth + 6,
                              top: 8,
                              bottom: 8,
                              width: itemWidth - 12,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: showPill ? 1 : 0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    color: Colors.white.withValues(alpha: 0.16),
                                    border: Border.all(
                                      color: AppColors.glassBorder,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                for (var i = 0; i < items.length; i++)
                                  Expanded(
                                    child: i == centerIndex
                                        ? _CenterButton(
                                            item: items[i],
                                            onTap: () => _tap(i),
                                          )
                                        : _NavButton(
                                            item: items[i],
                                            selected: i == selectedIndex,
                                            onTap: () => _tap(i),
                                          ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                key: ValueKey(selected),
                size: 24,
                color: selected ? AppColors.onGlass : AppColors.onGlassMuted,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? AppColors.onGlass : AppColors.onGlassMuted,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatefulWidget {
  const _CenterButton({required this.item, required this.onTap});

  final GlassNavItem item;
  final VoidCallback onTap;

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.glassButtonStart,
                    AppColors.glassButtonEnd,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glassButtonStart.withValues(alpha: 0.55),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                widget.item.selectedIcon,
                color: AppColors.onGlass,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.item.label,
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.onGlassMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
