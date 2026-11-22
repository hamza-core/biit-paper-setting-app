import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/handover_model.dart';
import '../domain/handover_service.dart';
import 'handover_sheet.dart';

class RoleHandoverScreen extends StatefulWidget {
  const RoleHandoverScreen({super.key});

  @override
  State<RoleHandoverScreen> createState() => _RoleHandoverScreenState();
}

class _RoleHandoverScreenState extends State<RoleHandoverScreen> {
  final HandoverService _service = HandoverService();
  HandoverState? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    HandoverState state = await _service.getState();
    if (!mounted) return;
    setState(() {
      _state = state;
    });
  }

  Future<void> _openSheet() async {
    bool? created = await showHandoverSheet(context);
    if (created == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Role handover started')));
      _load();
    }
  }

  Future<void> _endHandover() async {
    bool? sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End handover?'),
        content: const Text('The director role will return to you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await _service.endHandover();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    HandoverState? state = _state;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.m,
              ),
              child: Row(
                children: [
                  BackCircleButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: AppSpacing.m),
                  const Text(
                    'Role Handover',
                    style: TextStyle(
                      fontSize: AppFontSize.heading,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.l,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.active == null) ...[
                            _buildEmptyCard(),
                            const SizedBox(height: AppSpacing.xl),
                            _buildStartButton(),
                          ] else ...[
                            _buildActiveCard(state.active!),
                            const SizedBox(height: AppSpacing.xl),
                            _buildEndButton(),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          const Text(
                            'Previous Handovers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          for (int i = 0; i < state.history.length; i++) ...[
                            _buildHistoryCard(state.history[i]),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 32,
              color: Color(0xFF6B8F86),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          const Text(
            'No Active Handover',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'There is currently no delegated director role active.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _openSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33004741),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Role Handover',
          style: TextStyle(
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard(HandoverModel active) {
    bool hasPhoto = active.facultyName == 'Dr. Munir';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'ACTIVE HANDOVER',
                  style: TextStyle(
                    fontSize: AppFontSize.caption,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              Text(
                'Until ${_service.dateText(active.endDate)}',
                style: const TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          const Divider(height: 1, color: AppColors.white),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              ClipOval(
                child: hasPhoto
                    ? Image.asset(
                        'assets/images/avatar_hod.jpg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        color: AppColors.successBackground,
                        child: Text(
                          active.facultyName
                              .replaceAll('Dr. ', '')
                              .replaceAll('Mr. ', '')[0],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active.facultyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Acting Director',
                      style: TextStyle(fontSize: 14, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndButton() {
    return Material(
      color: AppColors.signOutBackground,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: _endHandover,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.l),
          alignment: Alignment.center,
          child: const Text(
            'End Active Handover',
            style: TextStyle(
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.w700,
              color: AppColors.signOutText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(HandoverModel item) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history,
              size: 18,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.facultyName,
                  style: const TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _service.rangeText(item.startDate, item.endDate),
                  style: const TextStyle(
                    fontSize: AppFontSize.label,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Completed',
              style: TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
