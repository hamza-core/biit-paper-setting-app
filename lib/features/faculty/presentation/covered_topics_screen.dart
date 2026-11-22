import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/faculty_models.dart';
import '../domain/faculty_service.dart';

// The teacher marks which topics were covered (per section).
class CoveredTopicsScreen extends StatefulWidget {
  final FacultyCourse course;
  final String teacherName;

  const CoveredTopicsScreen({
    super.key,
    required this.course,
    required this.teacherName,
  });

  @override
  State<CoveredTopicsScreen> createState() => _CoveredTopicsScreenState();
}

class _CoveredTopicsScreenState extends State<CoveredTopicsScreen> {
  final FacultyService _service = FacultyService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _sections = [];
  List<WeekModel> _weeks = [];
  Map<String, Set<String>> _selections = {};
  String _section = 'Section A';
  bool _applyToAll = false;
  final Set<String> _openWeeks = {'Week 1'};
  final Set<String> _openTopics = {'Loops'};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    List<String> sections = await _service.getSections();
    List<WeekModel> weeks = await _service.getWeeks(widget.course.code);
    Map<String, Set<String>> selections = await _service.getSelections(
      widget.course.code,
    );
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _weeks = weeks;
      _selections = selections;
      _section = sections.first;
      _loading = false;
    });
  }

  Set<String> get _current => _selections[_section]!;

  // Runs a change on the current section, or on every section.
  void _change(void Function(Set<String> selected) change) {
    setState(() {
      if (_applyToAll) {
        _selections.forEach((section, names) => change(names));
      } else {
        change(_current);
      }
    });
  }

  void _setApplyToAll(bool value) {
    setState(() {
      _applyToAll = value;
      if (value) {
        // Every section gets the same topics as the current one.
        Set<String> copy = Set<String>.from(_current);
        for (int i = 0; i < _sections.length; i++) {
          _selections[_sections[i]] = Set<String>.from(copy);
        }
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
    });
    try {
      await _service.submitTopics(
        widget.course,
        widget.teacherName,
        _selections,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your topics were submitted')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.l,
                  AppSpacing.xxl,
                  AppSpacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BackCircleButton(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: AppSpacing.m),
                        const Text(
                          'Covered Topics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _buildCourseCard(),
                    const SizedBox(height: AppSpacing.l),
                    _buildSearch(),
                    const SizedBox(height: AppSpacing.l),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _buildControls(),
                      const SizedBox(height: AppSpacing.l),
                      _buildTopicsCard(),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.l,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : GestureDetector(
                      onTap: _loading ? null : _submit,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'Submit your marked topics',
                          style: TextStyle(
                            fontSize: AppFontSize.small,
                            fontWeight: FontWeight.w700,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.code,
            style: const TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.course.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: AppSpacing.m),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exam',
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.white,
                ),
              ),
              Text(
                'Final',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search topics...',
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFF7A7A7A)),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textDark),
          prefixIconConstraints: BoxConstraints(minWidth: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppCheckbox(
            state: _applyToAll ? 2 : 0,
            onTap: () => _setApplyToAll(!_applyToAll),
          ),
          const SizedBox(width: AppSpacing.m),
          const Expanded(
            child: Text(
              'Apply same selection to all sections',
              style: TextStyle(
                fontSize: AppFontSize.label,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.only(left: 14, right: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<String>(
              value: _section,
              underline: const SizedBox(),
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              style: const TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
              items: [
                for (int i = 0; i < _sections.length; i++)
                  DropdownMenuItem(
                    value: _sections[i],
                    child: Text(_sections[i]),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _section = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsCard() {
    Set<String> selected = _current;
    String text = _searchController.text.trim().toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 11, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 35,
            child: Row(
              children: [
                AppCheckbox(
                  state: _service.allState(_weeks, selected),
                  onTap: () =>
                      _change((names) => _service.toggleAll(_weeks, names)),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        _change((names) => _service.toggleAll(_weeks, names)),
                    child: Text(
                      'Select All Topics for $_section',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selected: ${selected.length} of ${_service.totalTopics(_weeks)} topics',
            style: const TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          for (int i = 0; i < _weeks.length; i++) ...[
            _buildWeek(_weeks[i], selected, text),
            const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }

  Widget _buildWeek(WeekModel week, Set<String> selected, String text) {
    // Only the topics that match the search are shown.
    List<TopicItem> visible = [];
    for (int i = 0; i < week.topics.length; i++) {
      if (text.isEmpty || week.topics[i].name.toLowerCase().contains(text)) {
        visible.add(week.topics[i]);
      }
    }
    if (visible.isEmpty) return const SizedBox();

    bool open = _openWeeks.contains(week.name) || text.isNotEmpty;
    int state = _service.weekState(week, selected);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                if (open) {
                  _openWeeks.remove(week.name);
                } else {
                  _openWeeks.add(week.name);
                }
              });
            },
            child: Row(
              children: [
                AppCheckbox(
                  state: state,
                  onTap: () =>
                      _change((names) => _service.toggleWeek(week, names)),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(
                    week.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: state == 0 && !open
                          ? AppColors.mutedTab
                          : AppColors.primary,
                    ),
                  ),
                ),
                Icon(
                  open ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          if (open) ...[
            const SizedBox(height: AppSpacing.l),
            for (int i = 0; i < visible.length; i++) ...[
              _buildTopic(visible[i], selected),
              if (i < visible.length - 1) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTopic(TopicItem topic, Set<String> selected) {
    bool checked = selected.contains(topic.name);
    bool hasSub = topic.subTopics.isNotEmpty;
    bool subOpen = _openTopics.contains(topic.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppCheckbox(
              state: checked ? 2 : 0,
              onTap: () =>
                  _change((names) => _service.toggleTopic(topic.name, names)),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    _change((names) => _service.toggleTopic(topic.name, names)),
                child: Text(
                  topic.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: checked ? FontWeight.w500 : FontWeight.w400,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            if (hasSub)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (subOpen) {
                      _openTopics.remove(topic.name);
                    } else {
                      _openTopics.add(topic.name);
                    }
                  });
                },
                child: Icon(
                  subOpen
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        // Sub-topics follow the topic and cannot be changed alone.
        if (hasSub && subOpen)
          for (int i = 0; i < topic.subTopics.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Row(
                children: [
                  AppCheckbox(state: checked ? 2 : 0, size: 14, faded: true),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    topic.subTopics[i],
                    style: TextStyle(
                      fontSize: AppFontSize.label,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
