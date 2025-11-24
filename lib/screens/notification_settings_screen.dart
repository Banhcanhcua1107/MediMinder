import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../widgets/custom_toast.dart';

const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);
const Color kSuccessColor = Color(0xFF10B981);
const Color kErrorColor = Color(0xFFEF4444);

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late SharedPreferences _prefs;
  bool _enableNotifications = true;
  bool _enableSound = true;
  bool _enableVibration = true;
  int _repeatNotificationInterval = 10; // Lặp lại mỗi 10 phút nếu chưa uống
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _enableNotifications = _prefs.getBool('enable_notifications') ?? true;
          _enableSound = _prefs.getBool('enable_notification_sound') ?? true;
          _enableVibration =
              _prefs.getBool('enable_notification_vibration') ?? true;
          _repeatNotificationInterval =
              _prefs.getInt('repeat_notification_interval') ?? 10;

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading notification settings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _prefs.setBool('enable_notifications', _enableNotifications);
      await _prefs.setBool('enable_notification_sound', _enableSound);
      await _prefs.setBool('enable_notification_vibration', _enableVibration);
      await _prefs.setInt(
        'repeat_notification_interval',
        _repeatNotificationInterval,
      );

      debugPrint('✅ Notification settings saved');
    } catch (e) {
      debugPrint('❌ Error saving notification settings: $e');
    }
  }

  Future<void> _testNotification() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      await NotificationService().showNotification(
        id: 999998,
        title: '🔔 ${l10n.testAlarm}',
        body: l10n.testNotificationBody,
        useAlarm: true,
      );
      if (mounted) {
        showCustomToast(
          context,
          message: l10n.testNotificationSent,
          subtitle: l10n.checkSound,
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomToast(
          context,
          message: AppLocalizations.of(context)!.errorTesting,
          subtitle: e.toString(),
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kCardColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.notifications,
            style: const TextStyle(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            color: kPrimaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _enableNotifications ? kAccentColor : kAccentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: _enableNotifications
                          ? kPrimaryColor
                          : kSecondaryTextColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.enableNotifications,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.notificationDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                      });
                      _saveSettings();
                      showCustomToast(
                        context,
                        message: value
                            ? l10n.notificationsEnabled
                            : l10n.notificationsDisabled,
                        isSuccess: true,
                      );
                    },
                    activeThumbColor: kPrimaryColor,
                    activeTrackColor: kPrimaryColor.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.medicineReminders,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kSecondaryTextColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEEDEA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.timer,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.repeatInterval,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_repeatNotificationInterval ${l10n.minutes}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<int>(
                          enabled: _enableNotifications,
                          onSelected: (value) {
                            setState(() {
                              _repeatNotificationInterval = value;
                            });
                            _saveSettings();
                            showCustomToast(
                              context,
                              message:
                                  'Nhắc lặp lại mỗi $value phút nếu chưa uống',
                              isSuccess: true,
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 5,
                              child: Text('5 minutes'),
                            ),
                            const PopupMenuItem(
                              value: 10,
                              child: Text('10 minutes'),
                            ),
                            const PopupMenuItem(
                              value: 15,
                              child: Text('15 minutes'),
                            ),
                            const PopupMenuItem(
                              value: 30,
                              child: Text('30 minutes'),
                            ),
                          ],
                          child: Icon(
                            Icons.more_vert,
                            color: _enableNotifications
                                ? kSecondaryTextColor
                                : kBorderColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.soundAndVibration,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kSecondaryTextColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.notificationSound,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryTextColor,
                            ),
                          ),
                        ),
                        Switch(
                          value: _enableSound && _enableNotifications,
                          onChanged: _enableNotifications
                              ? (value) {
                                  setState(() {
                                    _enableSound = value;
                                  });
                                  _saveSettings();
                                }
                              : null,
                          activeThumbColor: kPrimaryColor,
                          activeTrackColor: kPrimaryColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: kBorderColor, indent: 64),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.vibration,
                            color: Color(0xFFA855F7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.vibration,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryTextColor,
                            ),
                          ),
                        ),
                        Switch(
                          value: _enableVibration && _enableNotifications,
                          onChanged: _enableNotifications
                              ? (value) {
                                  setState(() {
                                    _enableVibration = value;
                                  });
                                  _saveSettings();
                                }
                              : null,
                          activeThumbColor: kPrimaryColor,
                          activeTrackColor: kPrimaryColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _enableNotifications ? _testNotification : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Color(0xFFE11D48),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.testAlarm,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.testNotificationDescription,
                            style: const TextStyle(
                              fontSize: 12,
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: _enableNotifications
                          ? kSecondaryTextColor
                          : kBorderColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2E7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationPermissionTipsTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.notificationPermissionTipsBody,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0F2FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.notificationInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0284C7),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
