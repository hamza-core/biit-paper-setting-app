import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../paper_review/domain/paper_review_models.dart';

// Read only view of the paper, like the printed exam sheet.
class PaperPreviewScreen extends StatefulWidget {
  final PaperDetail paper;
  final String teacherName;

  const PaperPreviewScreen({
    super.key,
    required this.paper,
    required this.teacherName,
  });

  @override
  State<PaperPreviewScreen> createState() => _PaperPreviewScreenState();
}

class _PaperPreviewScreenState extends State<PaperPreviewScreen> {
  int _zoom = 100; // percent

  void _changeZoom(int step) {
    int next = _zoom + step;
    if (next < 50 || next > 200) return;
    setState(() {
      _zoom = next;
    });
  }

  void _notAvailable(String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$name is not available yet')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E6DD),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AppSpacing.l),
                child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(_zoom / 100)),
                  child: SizedBox(
                    width:
                        (MediaQuery.of(context).size.width - 32) * _zoom / 100,
                    child: _buildSheet(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.m,
            AppSpacing.xl,
            AppSpacing.m,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  const Expanded(
                    child: Text(
                      'Paper Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _notAvailable('Print'),
                    icon: const Icon(
                      Icons.print_outlined,
                      color: AppColors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _notAvailable('Download'),
                    icon: const Icon(
                      Icons.download_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeZoom(-25),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Text(
                    '$_zoom%',
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  GestureDetector(
                    onTap: () => _changeZoom(25),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Page 1 of 1',
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheet() {
    const small = TextStyle(
      fontSize: 8,
      color: Colors.black,
      fontFamily: 'serif',
    );
    const bold = TextStyle(
      fontSize: 8,
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
    );
    PaperDetail paper = widget.paper;
    List<QuestionModel> written = [];
    for (int i = 0; i < paper.questions.length; i++) {
      if (paper.questions[i].isWritten) written.add(paper.questions[i]);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 2,
            children: [
              Text("Student's Name: ________", style: bold),
              Text('Reg #: ________', style: bold),
              Text('Class/Section: ________', style: bold),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Image.asset('assets/images/biit_logo.png', width: 34, height: 34),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'Barani Institute of Information Technology',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                      ),
                    ),
                    Text(
                      'PMAS Arid Agriculture University',
                      textAlign: TextAlign.center,
                      style: bold,
                    ),
                    Text(
                      'Rawalpindi, Pakistan',
                      textAlign: TextAlign.center,
                      style: bold,
                    ),
                    Text(
                      'Fall 2026: Final Exam (Theory)',
                      textAlign: TextAlign.center,
                      style: bold,
                    ),
                  ],
                ),
              ),
              Image.asset('assets/images/biit_logo.png', width: 34, height: 34),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(border: Border.all()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Title: ${paper.courseName}      Course Code: ${paper.code}',
                  style: small,
                ),
                const Text(
                  'Date of Exam: ________      Time & Duration: 1:30PM-4:30PM (180 Min)',
                  style: small,
                ),
                Text(
                  'Degree Program: BSCS/GC(A)      Total Marks: ${paper.totalMarks}',
                  style: small,
                ),
                Text('Teacher Name: ${widget.teacherName}', style: small),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FixedColumnWidth(28),
              2: FixedColumnWidth(34),
              3: FixedColumnWidth(34),
            },
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Text('Q. No.', style: bold),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Text('Question', style: bold),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Text('CLO', style: bold),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Text('Marks', style: bold),
                  ),
                ],
              ),
              for (int i = 0; i < written.length; i++)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text('${written[i].number}', style: small),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(written[i].text, style: small),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        written[i].clos
                            .map((c) => c.replaceAll('CLO-', ''))
                            .join(','),
                        style: small,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text('${written[i].marks}', style: small),
                    ),
                  ],
                ),
            ],
          ),
          if (written.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(
                child: Text('No written questions yet', style: small),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          const Center(child: Text('Page 1 of 1', style: small)),
        ],
      ),
    );
  }
}
