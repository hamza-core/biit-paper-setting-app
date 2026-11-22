import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/datacell_service.dart';
import '../domain/import_models.dart';

// Step 2 of the import: check the rows, then confirm.
class ImportPreviewScreen extends StatefulWidget {
  final String fileName;
  final VoidCallback onDone;

  const ImportPreviewScreen({
    super.key,
    required this.fileName,
    required this.onDone,
  });

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  final DatacellService _service = DatacellService();

  List<ImportRow> _rows = [];
  String _tab = 'all'; // all, teacher, course, department, account
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _readFile();
  }

  Future<void> _readFile() async {
    try {
      List<ImportRow> rows = await _service.readImportFile(widget.fileName);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<ImportRow> _visibleRows() {
    if (_tab == 'all') return _rows;
    List<ImportRow> result = [];
    for (int i = 0; i < _rows.length; i++) {
      if (_rows[i].type == _tab) result.add(_rows[i]);
    }
    return result;
  }

  String _detailHeader() {
    if (_tab == 'teacher') return 'Course';
    if (_tab == 'course') return 'Department';
    if (_tab == 'department') return 'Head';
    if (_tab == 'account') return 'Role';
    return 'Details';
  }

  Future<void> _editRow(ImportRow row) async {
    TextEditingController controller = TextEditingController(text: row.name);
    String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        row.name = newName;
      });
    }
  }

  void _deleteRow(ImportRow row) {
    setState(() {
      _rows.remove(row);
    });
  }

  Future<void> _confirmImport() async {
    setState(() {
      _saving = true;
    });
    try {
      ImportSummary summary = await _service.confirmImport(_rows);
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _buildSuccessDialog(dialogContext, summary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {
        _saving = false;
      });
    }
  }

  void _goToDashboard(BuildContext dialogContext) {
    Navigator.pop(dialogContext); // close the dialog
    Navigator.popUntil(context, (route) => route.isFirst);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : SingleChildScrollView(child: _buildBody()),
            ),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.l,
      ),
      child: Row(
        children: [
          BackCircleButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: AppSpacing.l),
          const Expanded(
            child: Text(
              'Preview Imported Data',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFontSize.heading,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              const Icon(Icons.description, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s),
              Text(
                widget.fileName,
                style: const TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        _buildTabs(),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.successGreen),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppColors.successGreen,
                ),
                SizedBox(width: AppSpacing.m),
                Text(
                  'Successfully imported',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: _buildTable(),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    List<List<String>> tabs = [
      ['all', 'All'],
      ['teacher', 'Teachers ${_service.countRows(_rows, 'teacher')}'],
      ['course', 'Courses ${_service.countRows(_rows, 'course')}'],
      ['department', 'Departments ${_service.countRows(_rows, 'department')}'],
      ['account', 'Accounts'],
    ];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.m,
          AppSpacing.xl,
          0,
        ),
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tab = tabs[i][0];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.l),
                  child: Column(
                    children: [
                      Text(
                        tabs[i][1],
                        style: TextStyle(
                          fontSize: AppFontSize.label,
                          fontWeight: _tab == tabs[i][0]
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: _tab == tabs[i][0]
                              ? AppColors.primary
                              : AppColors.greyText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Container(
                        height: 2,
                        width: tabs[i][1].length * 6.5,
                        color: _tab == tabs[i][0]
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    List<ImportRow> rows = _visibleRows();
    const headerStyle = TextStyle(
      fontSize: AppFontSize.caption,
      fontWeight: FontWeight.w700,
      color: AppColors.greyText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 56,
                  child: Text('Action', style: headerStyle),
                ),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 52,
                  child: Text('ID', style: headerStyle),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  flex: 3,
                  child: Text('Name', style: headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text(_detailHeader(), style: headerStyle),
                ),
              ],
            ),
          ),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Text('No rows'),
            ),
          for (int i = 0; i < rows.length; i++) _buildRow(rows[i]),
        ],
      ),
    );
  }

  Widget _buildRow(ImportRow row) {
    const cellStyle = TextStyle(
      fontSize: AppFontSize.label,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _editRow(row),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _deleteRow(row),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.deleteRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 52, child: Text(row.id, style: cellStyle)),
          const SizedBox(width: 10),
          Expanded(flex: 3, child: Text(row.name, style: cellStyle)),
          Expanded(flex: 2, child: Text(row.detail, style: cellStyle)),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Re-upload File',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _saving
              ? const SizedBox(
                  height: 49,
                  child: Center(child: CircularProgressIndicator()),
                )
              : AppButton(
                  text: 'Confirm Import',
                  compact: true,
                  onPressed: (_loading || _error != null)
                      ? null
                      : _confirmImport,
                ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog(
    BuildContext dialogContext,
    ImportSummary summary,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30004741),
                      blurRadius: 12,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl + AppSpacing.s),
              const Text(
                'Import Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              const Text(
                'Database has been updated with the imported data.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.greyText),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Records Added Summary',
                      style: TextStyle(
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: AppSpacing.l),
                    _summaryRow('Teachers', summary.teachers),
                    const SizedBox(height: AppSpacing.m),
                    _summaryRow('Courses', summary.courses),
                    const SizedBox(height: AppSpacing.m),
                    _summaryRow('Departments', summary.departments),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: 'Back to Dashboard',
                compact: true,
                onPressed: () => _goToDashboard(dialogContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: AppFontSize.label,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
