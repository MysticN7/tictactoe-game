import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_logic.dart';
import '../theme.dart';
import '../widgets/liquid_components.dart';

class SettingsRootScreen extends StatelessWidget {
  const SettingsRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final gradientColors = AppTheme.getGradientColors(themeType);
    final textColor = AppTheme.getTextColor(themeType);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: 'Settings',
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionHeader(title: 'APPEARANCE'),
              const SizedBox(height: 10),
              LiquidContainer(
                padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _SectionHeader(title: 'SOUND & HAPTICS'),
              const SizedBox(height: 10),
              LiquidContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SwitchRow(
                      label: 'Sound Effects',
                      value: settings.isSoundEnabled,
                      onChanged: (_) => settings.toggleSound(),
                      icon: Icons.volume_up_rounded,
                    ),
                    const Divider(height: 20, color: Colors.white10),
                    _SwitchRow(
                      label: 'Haptic Feedback',
                      value: settings.isVibrationEnabled,
                      onChanged: (_) => settings.toggleVibration(),
                      icon: Icons.vibration_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              _SectionHeader(title: 'VISUAL EFFECTS'),
              const SizedBox(height: 10),
              LiquidContainer(
                padding: const EdgeInsets.all(16),
                child: _SwitchRow(
                  label: 'Confetti Celebration',
                  value: settings.isConfettiEnabled,
                  onChanged: (_) => settings.toggleConfetti(),
                  icon: Icons.celebration_rounded,
                ),
              ),
              
              const SizedBox(height: 30),
               _SectionHeader(title: 'PLAYERS'),
              const SizedBox(height: 10),
              LiquidContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PlayerConfigRow(player: Player.x),
                    const Divider(height: 20, color: Colors.white10),
                    _PlayerConfigRow(player: Player.o),
                  ],
                ),
              ),
            ],

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final textColor = AppTheme.getTextColor(themeType);
    
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          color: textColor.withOpacity(0.6),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AppThemeType.values.map((type) {
            final isSelected = settings.currentTheme.toAppThemeType() == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  // Map AppThemeType back to GameThemeMode
                  GameThemeMode mode;
                  switch (type) {
                    case AppThemeType.liquidGlass: mode = GameThemeMode.liquidGlow; break; // Using liquidGlow as proxy for Liquid Glass
                    case AppThemeType.nebula: mode = GameThemeMode.dark; break; // Using dark as proxy for Nebula
                    case AppThemeType.crystal: mode = GameThemeMode.light; break; // Using light as proxy for Crystal
                  }
                  settings.setTheme(mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.getNeonGlowColor(type) : Colors.transparent,
                      width: 2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppTheme.getGradientColors(type),
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppTheme.getNeonGlowColor(type).withOpacity(0.4),
                          blurRadius: 12,
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      type.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(type),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final textColor = AppTheme.getTextColor(themeType);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        child,
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _SwitchRow({required this.label, required this.value, required this.onChanged, required this.icon});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final textColor = AppTheme.getTextColor(themeType);

    return Row(
      children: [
        Icon(icon, color: textColor.withOpacity(0.7), size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500))),
        LiquidSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final int selectedValue;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.values,
    required this.labels,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final activeColor = AppTheme.getNeonGlowColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (index) {
          final isSelected = selectedValue == values[index];
          return GestureDetector(
            onTap: () => onChanged(values[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: isSelected ? Border.all(color: activeColor.withOpacity(0.6)) : null,
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: isSelected ? activeColor : textColor.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlayerConfigRow extends StatelessWidget {
  final Player player;

  const _PlayerConfigRow({required this.player});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final textColor = AppTheme.getTextColor(themeType);
    final playerColor = settings.getPlayerColor(player);
    final playerName = settings.getPlayerName(player);
    final playerIcon = settings.getPlayerIcon(player);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: playerColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: playerColor.withOpacity(0.6), width: 2),
          ),
          child: Center(
            child: Text(
              playerIcon,
              style: TextStyle(
                color: playerColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerName,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                'Player ${player.name.toUpperCase()}',
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_rounded, color: textColor.withOpacity(0.7)),
          onPressed: () => _showEditPlayerDialog(context, player, settings, themeType, textColor),
        ),
      ],
    );
  }

  void _showEditPlayerDialog(BuildContext context, Player player, SettingsProvider settings, AppThemeType themeType, Color textColor) {
    final nameController = TextEditingController(text: settings.getPlayerName(player));
    final iconController = TextEditingController(text: settings.getPlayerIcon(player));
    final glassColor = AppTheme.getGlassColor(themeType);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassColor.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Edit ${player.name.toUpperCase()}', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor.withOpacity(0.3))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              style: TextStyle(color: textColor),
              maxLength: 1,
              decoration: InputDecoration(
                labelText: 'Icon (1 char)',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColor.withOpacity(0.3))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textColor.withOpacity(0.7))),
          ),
          TextButton(
            onPressed: () {
              settings.updatePlayerName(player, nameController.text);
              settings.updatePlayerIcon(player, iconController.text);
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: AppTheme.getNeonGlowColor(themeType), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}