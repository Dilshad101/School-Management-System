import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import 'tabs/students_tab.dart';
import 'tabs/teachers_tab.dart';
import 'tabs/time_table_tab.dart';
import 'widgets/class_detail_info_card.dart';

class ClassDetailsView extends StatelessWidget {
  const ClassDetailsView({super.key, required this.classId});
  final String? classId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Class Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: ClassDetailInfoCard(
                    label: 'Class Teacher',
                    value: 'Lakshmi Presad',
                  ),
                ),
                Expanded(
                  child: ClassDetailInfoCard(
                    label: 'Total Students',
                    value: '30',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: ClassDetailInfoCard(label: 'Room No', value: '101 C'),
                ),
                Expanded(
                  child: ClassDetailInfoCard(
                    label: 'Batch Year',
                    value: '2023-2024',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tab bar
            Expanded(child: ClassDetailsTabBarView()),
          ],
        ),
      ),
    );
  }
}

class ClassDetailsTabBarView extends StatefulWidget {
  const ClassDetailsTabBarView({super.key});

  @override
  State<ClassDetailsTabBarView> createState() => _ClassDetailsTabBarViewState();
}

class _ClassDetailsTabBarViewState extends State<ClassDetailsTabBarView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ValueNotifier<int> _tabNotifier;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabNotifier = ValueNotifier(0);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _tabNotifier.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _tabNotifier,
          builder: (context, value, child) {
            return TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(),
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              onTap: (value) => _tabNotifier.value = value,
              tabs: [
                _buildTab('Students', 0, value),
                _buildTab('Teachers', 1, value),
                _buildTab('Timetable', 2, value),
              ],
            );
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ClassStudentsTabView(),
              ClassTeachersTabView(),
              ClassTimetableTabView(),
            ],
          ),
        ),
      ],
    );
  }

  Tab _buildTab(String title, int index, int value) {
    final bool isSelected = value == index;

    return Tab(
      height: 36,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
        ),
        child: Text(
          title,
          style: AppTextStyles.linkSmall.copyWith(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
