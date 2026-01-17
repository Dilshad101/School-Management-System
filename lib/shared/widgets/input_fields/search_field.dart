import 'dart:async';

import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({super.key, this.onChanged, this.searchHint});
  final Function(String value)? onChanged;
  final String? searchHint;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  // Debouncer
  Timer? _debounce;
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged?.call(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (v) {
        _onSearchChanged(v);
      },
      decoration: InputDecoration(
        hintText: widget.searchHint ?? 'Search here',
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(Icons.search_outlined, color: AppColors.textSecondary),
        constraints: BoxConstraints(maxHeight: 44),
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      textInputAction: TextInputAction.search,
    );
  }
}
