import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/permissions.dart';
import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../../../shared/styles/app_styles.dart';
import '../../../auth/blocs/user/user_bloc.dart';
import 'tab_views/academic_year_tab_view/academic_year_tab_view.dart';
import 'tab_views/fee_component_tab_view/fee_component_tab_view.dart';
import 'tab_views/fee_structure_tab_view/fee_structure_tab_view.dart';
import 'tab_views/period_tab_view/period_tab_view.dart';
import 'tab_views/subject_tab_view/subject_tab_view.dart';

/// Represents a tab with its label, permission, and content builder.
class _SettingsTabData {
  final String label;
  final String permission;
  final Widget Function(String schoolId) builder;

  const _SettingsTabData({
    required this.label,
    required this.permission,
    required this.builder,
  });
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  /// All available tabs with their permissions
  final List<_SettingsTabData> _allTabs = [
    _SettingsTabData(
      label: 'Academic Year',
      permission: Permissions.viewAcademicYear,
      builder: (schoolId) => AcademicYearTabView(schoolId: schoolId),
    ),
    _SettingsTabData(
      label: 'Subjects',
      permission: Permissions.viewSubject,
      builder: (schoolId) => SubjectTabView(schoolId: schoolId),
    ),
    _SettingsTabData(
      label: 'Periods',
      permission: Permissions.viewPeriod,
      builder: (schoolId) => PeriodTabView(schoolId: schoolId),
    ),
    _SettingsTabData(
      label: 'Fee Components',
      permission: Permissions.viewFee,
      builder: (schoolId) => FeeComponentTabView(schoolId: schoolId),
    ),
    _SettingsTabData(
      label: 'Fee Structure',
      permission: Permissions.viewFee,
      builder: (schoolId) => FeeStructureTabView(schoolId: schoolId),
    ),
  ];

  /// Filtered tabs based on user permissions
  List<_SettingsTabData> _permittedTabs = [];

  /// Gets the current school ID from session or tenant context
  String get _schoolId {
    final session = locator<SessionHolder>().session;
    if (session?.schoolId != null && session!.schoolId!.isNotEmpty) {
      return session.schoolId!;
    }
    return locator<TenantContext>().selectedSchoolId ?? '';
  }

  @override
  void initState() {
    super.initState();
    _initPermittedTabs();
  }

  void _initPermittedTabs() {
    final userState = context.read<UserBloc>().state;
    _permittedTabs = _allTabs.where((tab) {
      return userState.hasPermission(tab.permission);
    }).toList();

    if (_permittedTabs.isNotEmpty) {
      _tabController = TabController(
        length: _permittedTabs.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state if no tabs are permitted
    if (_permittedTabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: Text('No settings available for your role.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _permittedTabs
                  .map((tab) => tab.builder(_schoolId))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 38,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: AppColors.white,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelColor: AppColors.textSecondary,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        splashBorderRadius: BorderRadius.circular(25),
        tabs: _permittedTabs.map((tab) => Tab(text: tab.label)).toList(),
      ),
    );
  }
}
