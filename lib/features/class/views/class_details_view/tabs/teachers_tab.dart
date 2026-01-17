import 'package:flutter/material.dart';
import 'package:school_management_system/shared/widgets/input_fields/search_field.dart';

import '../widgets/class_teacher_tile.dart';

class ClassTeachersTabView extends StatelessWidget {
  const ClassTeachersTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        AppSearchBar(),
        const SizedBox(height: 10),
        ClassTeacherTile(),
      ],
    );
  }
}
