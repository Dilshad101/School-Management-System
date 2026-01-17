import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_text_styles.dart';

import '../../shared/styles/app_colors.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.background,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: AppTextStyles.heading3,
  ),
  fontFamily: 'Inter',
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    enableFeedback: false,
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.primary,
    selectedLabelStyle: AppTextStyles.small,
    unselectedLabelStyle: AppTextStyles.small,
    unselectedItemColor: AppColors.textSecondary,
  ),
);
