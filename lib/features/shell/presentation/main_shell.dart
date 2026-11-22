import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_nav.dart';
import '../../auth/domain/user_model.dart';
import '../../datacell/presentation/datacell_home_screen.dart';
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
