import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/notification_model.dart';
import '../domain/profile_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String role;

  const NotificationsScreen({super.key, required this.role});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ProfileService _service = ProfileService();
  List<NotificationModel>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<NotificationModel> items = await _service.getNotifications(
      widget.role,
    );
    if (!mounted) return;
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<NotificationModel>? items = _items;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: items == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildList(items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: AppFontSize.heading,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<NotificationModel> items) {
    List<NotificationModel> today = [];
    List<NotificationModel> earlier = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i].isToday) {
        today.add(items[i]);
      } else {
        earlier.add(items[i]);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      children: [
        if (today.isNotEmpty) ...[
          _buildSectionLabel('TODAY'),
          for (int i = 0; i < today.length; i++) _buildRow(today[i]),
          const Divider(color: AppColors.border, height: 1),
        ],
        if (earlier.isNotEmpty) ...[
          _buildSectionLabel('EARLIER'),
          for (int i = 0; i < earlier.length; i++) _buildRow(earlier[i]),
        ],
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl),
            child: Center(child: Text('No notifications')),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.s),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: AppColors.greyText,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.greyText,
        ),
      ),
    );
  }

  Widget _buildRow(NotificationModel item) {
    return Opacity(
      opacity: item.isUnread ? 1 : 0.72,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.isUnread ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (int i = 0; i < item.lines.length; i++)
                    Text(
                      item.lines[i],
                      style: const TextStyle(
                        fontSize: AppFontSize.label,
                        color: AppColors.greyText,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              item.time,
              style: const TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: FontWeight.w500,
                color: AppColors.lightGreyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
