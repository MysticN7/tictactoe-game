import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';
import '../theme.dart';

class LiquidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final EdgeInsetsGeometry? padding;

  const LiquidButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.padding,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glowColor = AppTheme.getNeonGlowColor(themeType);
    final glassColor = AppTheme.getGlassColor(themeType);
    final borderColor = AppTheme.getGlassBorderColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isPrimary ? glowColor.withOpacity(0.2) : glassColor,
            border: Border.all(
              color: widget.isPrimary ? glowColor.withOpacity(0.5) : borderColor,
              width: 1.5,
            ),
            boxShadow: [
              if (widget.isPrimary)
                BoxShadow(
                  color: glowColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.isPrimary ? glowColor : textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary ? glowColor : textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiquidSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const LiquidSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final activeColor = AppTheme.getNeonGlowColor(themeType);
    final trackColor = AppTheme.getGlassColor(themeType);
    final borderColor = AppTheme.getGlassBorderColor(themeType);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? activeColor.withOpacity(0.2) : trackColor,
          border: Border.all(
            color: value ? activeColor.withOpacity(0.5) : borderColor,
            width: 1.5,
          ),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? activeColor : Colors.white54,
              boxShadow: [
                if (value)
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const LiquidContainer({super.key, required this.child, this.padding, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = AppTheme.getGlassColor(themeType);
    final borderColor = AppTheme.getGlassBorderColor(themeType);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class LiquidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const LiquidAppBar({super.key, required this.title, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final textColor = AppTheme.getTextColor(themeType);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
