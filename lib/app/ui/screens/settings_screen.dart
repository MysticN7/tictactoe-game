import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Sound'),
                value: settingsProvider.isSoundEnabled,
                onChanged: (_) => settingsProvider.toggleSound(),
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                value: settingsProvider.isVibrationEnabled,
                onChanged: (_) => settingsProvider.toggleVibration(),
              ),
            ],
          );
        },
      ),
    );
  }
}
