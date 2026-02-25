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
    surfaceTintColor: Colors.transparent,
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
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    textStyle: AppTextStyles.bodySmall,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    titleTextStyle: AppTextStyles.heading3,
    contentTextStyle: AppTextStyles.bodyMedium,
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
  ),
);
