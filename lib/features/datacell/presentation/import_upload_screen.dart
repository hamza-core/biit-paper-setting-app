import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/datacell_service.dart';
import 'import_preview_screen.dart';

// Step 1 of the import: choose the excel file.
class ImportUploadScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onDone; // called after the import is finished

  const ImportUploadScreen({
    super.key,
    required this.onBack,
    required this.onDone,
  });

  @override
  State<ImportUploadScreen> createState() => _ImportUploadScreenState();
}

class _ImportUploadScreenState extends State<ImportUploadScreen> {
  final DatacellService _service = DatacellService();
  String? _fileName;

  Future<void> _chooseFile() async {
    String name = await _service.pickFile();
    setState(() {
      _fileName = name;
    });
  }

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImportPreviewScreen(fileName: _fileName!, onDone: widget.onDone),
      ),
    ).then((_) {
      // Coming back from the preview = "Re-upload File"
      if (mounted) {
        setState(() {
          _fileName = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.l,
            ),
            child: Row(
              children: [
                BackCircleButton(onTap: widget.onBack),
                const SizedBox(width: AppSpacing.l),
                const Expanded(
                  child: Text(
                    'Import Academic Data',
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
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  _buildSteps(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildUploadZone(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppButton(
              text: 'Continue',
              compact: true,
              onPressed: _fileName == null ? null : _continue,
            ),
          ),
        ],
      ),
    );

    // When opened as a tab the shell already has a Scaffold.
    if (Scaffold.maybeOf(context) != null) return content;
    return Scaffold(body: content);
  }

  Widget _buildSteps() {
    return Row(
      children: [
        _step('1. Upload', true),
        _line(),
        _step('2. Preview', false),
        _line(),
        _step('3. Done', false),
      ],
    );
  }

  Widget _step(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: active ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppFontSize.caption,
          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          color: active ? AppColors.white : AppColors.greyText,
        ),
      ),
    );
  }

  Widget _line() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        color: AppColors.border,
      ),
    );
  }

  Widget _buildUploadZone() {
    bool hasFile = _fileName != null;
    return GestureDetector(
      onTap: _chooseFile,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: 48,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0x1A004741),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFile
                      ? Icons.description_outlined
                      : Icons.file_upload_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                hasFile
                    ? _fileName!
                    : 'Upload Bulk Data\nor\nDate Sheet\n (.xlsx)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.medium,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasFile
                    ? 'Tap to choose another file'
                    : 'Drag & drop or tap to browse',
                style: const TextStyle(
                  fontSize: AppFontSize.label,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// White box with a dashed green border (like the Figma upload zone).
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    RRect box = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    canvas.drawRRect(box, Paint()..color = AppColors.white);

    Paint line = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Path path = Path()..addRRect(box.deflate(1));
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), line);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
