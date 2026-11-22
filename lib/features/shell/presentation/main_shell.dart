import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_nav.dart';
import '../../auth/domain/user_model.dart';
import '../../datacell/presentation/datacell_home_screen.dart';
import '../../director/domain/director_models.dart';
import '../../director/domain/director_service.dart';
import '../../faculty/presentation/faculty_home_screen.dart';
import '../../faculty/presentation/faculty_papers_screen.dart';
import '../../hod/presentation/clo_rules_screen.dart';
import '../../hod/presentation/hod_home_screen.dart';
import '../../paper_review/domain/paper_review_models.dart';
import '../../paper_review/domain/paper_review_service.dart';
import '../../paper_review/presentation/covered_topics_sheet.dart';
import '../../paper_review/presentation/paper_workspace_screen.dart';
import '../../director/presentation/director_courses_screen.dart';
import '../../director/presentation/director_home_screen.dart';
import '../../director/presentation/director_papers_screen.dart';
import '../../datacell/presentation/import_upload_screen.dart';
import '../../datacell/presentation/papers_screen.dart';
import '../../profile/presentation/profile_screen.dart';

// The screen shown after login. It has the bottom bar, and the tabs
// depend on the role. Tabs that are not built yet show a placeholder.
class MainShell extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const MainShell({super.key, required this.user, required this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<NavItem> _tabsForRole() {
    NavItem home = NavItem(label: 'Home', icon: Icons.home_outlined);
    NavItem papers = NavItem(label: 'Papers', icon: Icons.description_outlined);
    NavItem profile = NavItem(label: 'Profile', icon: Icons.person_outline);

    String role = widget.user.role;
    if (role == 'datacell') {
      return [
        home,
        papers,
        NavItem(label: 'Data', icon: Icons.storage_outlined),
        profile,
      ];
    }
    if (role == 'director') {
      return [
        home,
        papers,
        NavItem(label: 'Courses', icon: Icons.menu_book_outlined),
        profile,
      ];
    }
    if (role == 'hod') {
      return [
        home,
        papers,
        NavItem(label: 'CLO Rule', icon: Icons.rule_outlined),
        profile,
      ];
    }
    return [home, papers, profile]; // faculty
  }

  void _goToTab(String label) {
    List<NavItem> tabs = _tabsForRole();
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].label == label) {
        setState(() {
          _currentIndex = i;
        });
      }
    }
  }

  int _directorVersion = 0; // changes when a decision is saved, to reload lists

  // Opens the paper workspace. Papers that are still waiting for the
  // director can be approved or rejected, the others are view only.
  void _openDirectorPaper(DirectorPaper paper) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaperWorkspaceScreen(
          code: paper.code,
          courseName: paper.courseName,
          submittedBy: paper.teacher,
          currentUserName: widget.user.name,
          currentUserRole: 'Director',
          canDecide: paper.status == 'toReview',
          onConfirmDecision: (approve, comment) async {
            await DirectorService().decide(paper, approve, comment);
            if (!mounted) return;
            setState(() {
              _directorVersion = _directorVersion + 1;
            });
          },
        ),
      ),
    );
  }

  int _hodVersion = 0; // changes when a CLO review is saved, to reload lists

  // The HOD opens the "Review CLO Grid" sheet. Papers that are not waiting
  // for review open the same sheet without the decision.
  Future<void> _openHodPaper(DirectorPaper paper) async {
    PaperDetail detail = await PaperReviewService().getPaper(
      code: paper.code,
      courseName: paper.courseName,
      submittedBy: paper.teacher,
    );
    if (!mounted) return;
    bool canReview = paper.status == 'toReview' && !paper.cloChecked;
    showCoveredTopicsSheet(
      context,
      detail,
      onConfirmDecision: canReview
          ? (approve, comment) async {
              await DirectorService().reviewClo(paper, approve, comment);
              if (!mounted) return;
              setState(() {
                _hodVersion = _hodVersion + 1;
              });
            }
          : null,
    );
  }

  Widget _buildBody(String label) {
    if (label == 'Profile') {
      return ProfileScreen(user: widget.user, onLogout: widget.onLogout);
    }
    if (widget.user.role == 'datacell') {
      if (label == 'Home') {
        return DatacellHomeScreen(
          user: widget.user,
          onLogout: widget.onLogout,
          onOpenProfile: () => _goToTab('Profile'),
          onImportDone: () => _goToTab('Home'),
        );
      }
      if (label == 'Papers') {
        return DatacellPapersScreen(onBack: () => _goToTab('Home'));
      }
      if (label == 'Data') {
        return ImportUploadScreen(
          onBack: () => _goToTab('Home'),
          onDone: () => _goToTab('Home'),
        );
      }
    }
    if (widget.user.role == 'director') {
      if (label == 'Home') {
        return DirectorHomeScreen(
          key: ValueKey('director-home-$_directorVersion'),
          user: widget.user,
          onLogout: widget.onLogout,
          onOpenProfile: () => _goToTab('Profile'),
          onOpenPaper: _openDirectorPaper,
        );
      }
      if (label == 'Papers') {
        return DirectorPapersScreen(
          key: ValueKey('director-papers-$_directorVersion'),
          onOpenPaper: _openDirectorPaper,
        );
      }
      if (label == 'Courses') {
        return const DirectorCoursesScreen();
      }
    }
    if (widget.user.role == 'hod') {
      if (label == 'Home') {
        return HodHomeScreen(
          key: ValueKey('hod-home-$_hodVersion'),
          user: widget.user,
          onLogout: widget.onLogout,
          onOpenProfile: () => _goToTab('Profile'),
          onViewAllPapers: () => _goToTab('Papers'),
          onOpenPaper: _openHodPaper,
        );
      }
      if (label == 'Papers') {
        // The HOD sees the same paper lists as the director.
        return DirectorPapersScreen(
          key: ValueKey('hod-papers-$_hodVersion'),
          onOpenPaper: _openHodPaper,
        );
      }
      if (label == 'CLO Rule') {
        return const CloRulesScreen();
      }
    }
    if (widget.user.role == 'faculty') {
      if (label == 'Home') {
        return FacultyHomeScreen(
          user: widget.user,
          onLogout: widget.onLogout,
          onOpenProfile: () => _goToTab('Profile'),
          onViewAllPapers: () => _goToTab('Papers'),
        );
      }
      if (label == 'Papers') {
        return const FacultyPapersScreen();
      }
    }
    // Replaced by the real screen when that feature is built.
    return SafeArea(child: Center(child: Text('$label (coming soon)')));
  }

  @override
  Widget build(BuildContext context) {
    List<NavItem> tabs = _tabsForRole();
    return Scaffold(
      body: _buildBody(tabs[_currentIndex].label),
      bottomNavigationBar: AppBottomNav(
        items: tabs,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
