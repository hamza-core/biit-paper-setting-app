import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../domain/handover_service.dart';

// Bottom sheet to start a handover. Returns true when it was created.
Future<bool?> showHandoverSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const _HandoverSheet(),
    ),
  );
}

class _HandoverSheet extends StatefulWidget {
  const _HandoverSheet();

  @override
  State<_HandoverSheet> createState() => _HandoverSheetState();
}

class _HandoverSheetState extends State<_HandoverSheet> {
  final HandoverService _service = HandoverService();
  final TextEditingController _reasonController = TextEditingController();

  List<String> _faculty = [];
  String? _selected;
  DateTime? _start;
  DateTime? _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadFaculty() async {
    List<String> faculty = await _service.getFaculty();
    if (!mounted) return;
    setState(() {
      _faculty = faculty;
    });
  }

  Future<void> _pickDate(bool isStart) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _confirm() async {
    String? error = _service.validate(_selected, _start, _end);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      _saving = true;
    });
    await _service.startHandover(
      faculty: _selected,
      start: _start,
      end: _end,
      reason: _reasonController.text,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.m,
        AppSpacing.xxl,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Role Handover',
            style: TextStyle(
              fontSize: AppFontSize.profileName,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _label('Authorized Replacement', 14, AppColors.textDark),
          const SizedBox(height: AppSpacing.s),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<String>(
              value: _selected,
              hint: const Text('Select Faculty Member'),
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: const TextStyle(
                fontSize: AppFontSize.small,
                color: AppColors.textDark,
              ),
              items: [
                for (int i = 0; i < _faculty.length; i++)
                  DropdownMenuItem(
                    value: _faculty[i],
                    child: Text(_faculty[i]),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selected = value;
                });
              },
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _label('Period', 14, AppColors.textDark),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: _dateField('Start Date', 'Select Start', _start, true),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: _dateField('End Date', 'Select End', _end, false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _label('Reason for Handover (optional)', 14, AppColors.textDark),
          const SizedBox(height: AppSpacing.s),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: AppFontSize.small),
              decoration: const InputDecoration(
                hintText: 'Delegation of tasks during medical leave...',
                hintStyle: TextStyle(color: AppColors.greyText),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _saving
              ? const SizedBox(
                  height: 49,
                  child: Center(child: CircularProgressIndicator()),
                )
              : AppButton(
                  text: 'Confirm Handover',
                  compact: true,
                  onPressed: _confirm,
                ),
        ],
      ),
    );
  }

  Widget _label(String text, double size, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _dateField(String label, String hint, DateTime? value, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, AppFontSize.label, AppColors.greyText),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(isStart),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value == null ? hint : _service.dateText(value),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
