import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allowNotifications = true;
  bool _sound = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.allowNotifications),
            value: _allowNotifications,
            onChanged: (value) {
              setState(() {
                _allowNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.sound),
            value: _sound,
            onChanged: _allowNotifications
                ? (value) {
                    setState(() {
                      _sound = value;
                    });
                  }
                : null,
          ),
          SwitchListTile(
            title: Text(l10n.vibration),
            value: _vibration,
            onChanged: _allowNotifications
                ? (value) {
                    setState(() {
                      _vibration = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
