import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () => context.push('/profile/edit'),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Account',
            color: AppColors.error,
            onTap: () => context.push('/profile/delete-account'),
          ),
          const _SectionHeader(title: 'Notifications'),
          _SettingsSwitch(
            icon: Icons.notifications_outlined,
            title: 'Session Reminders',
            subtitle: 'Get reminded before your booked sessions',
            value: settings.sessionReminders,
            onChanged: notifier.toggleSessionReminders,
          ),
          _SettingsSwitch(
            icon: Icons.trending_up_rounded,
            title: 'Progress Reminders',
            subtitle: 'Weekly reminders to log your progress',
            value: settings.progressReminders,
            onChanged: notifier.toggleProgressReminders,
          ),
          _SettingsSwitch(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chat Notifications',
            subtitle: 'Get notified for new messages',
            value: settings.chatNotifications,
            onChanged: notifier.toggleChatNotifications,
          ),
          const _SectionHeader(title: 'App'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => context.push('/help'),
          ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate App',
            onTap: () {},
          ),
          if (_version.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 4, 16, 0),
              child: Text(
                'Version $_version',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
          const _SectionHeader(title: 'Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => context.push('/legal/terms'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => context.push('/legal/privacy'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(title, style: AppTextStyles.body.copyWith(color: c)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted, size: 20),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title,
          style:
              AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style:
              AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
