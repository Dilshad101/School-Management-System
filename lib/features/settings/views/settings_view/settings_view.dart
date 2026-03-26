import 'package:flutter/material.dart';

import '../../../../core/tenant/tenant_context.dart';
import '../../../../core/utils/di.dart';
import '../../../../shared/styles/app_styles.dart';
import 'tab_views/period_tab_view/period_tab_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'General Settings',
    'Subject Management',
    'Period',
  ];

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
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                _buildGeneralSettingsTab(),
                _buildSubjectManagementTab(),
                PeriodTabView(schoolId: _schoolId),
              ],
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
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildGeneralSettingsTab() {
    return const Center(child: Text('General Settings - Coming Soon'));
  }

  Widget _buildSubjectManagementTab() {
    return const Center(child: Text('Subject Management - Coming Soon'));
  }
}
