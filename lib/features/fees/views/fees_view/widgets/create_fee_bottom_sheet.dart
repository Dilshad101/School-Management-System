import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/di.dart';
import '../../../../../shared/styles/app_styles.dart';
import '../../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../../shared/widgets/input_fields/suggestion_form_field.dart';
import '../../../../settings/models/academic_year_model.dart';
import '../../../../settings/models/fee_structure_model.dart';
import '../../../../settings/repositories/academic_year_repository.dart';
import '../../../../settings/repositories/fee_structure_repository.dart';
import '../../../../students/models/student_model.dart';
import '../../../../students/repositories/students_repository.dart';
import '../../../blocs/create_fee/create_fee_cubit.dart';
import '../../../blocs/create_fee/create_fee_state.dart';
import '../../../repositories/fees_repository.dart';

/// Bottom sheet for creating a new student fee assignment.
class CreateFeeBottomSheet extends StatefulWidget {
  final String schoolId;

  const CreateFeeBottomSheet({super.key, required this.schoolId});

  /// Shows the bottom sheet and returns true if a fee was created.
  static Future<bool?> show(BuildContext context, {required String schoolId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider(
        create: (context) => CreateFeeCubit(
          feesRepository: locator<FeesRepository>(),
          schoolId: schoolId,
        ),
        child: CreateFeeBottomSheet(schoolId: schoolId),
      ),
    );
  }

  @override
  State<CreateFeeBottomSheet> createState() => _CreateFeeBottomSheetState();
}

class _CreateFeeBottomSheetState extends State<CreateFeeBottomSheet> {
  final _studentController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _feeStructureController = TextEditingController();

  String? _selectedStudentId;
  String? _selectedAcademicYearId;
  String? _selectedFeeStructureId;

  late final StudentsRepository _studentsRepository;
  late final AcademicYearRepository _academicYearRepository;
  late final FeeStructureRepository _feeStructureRepository;

  @override
  void initState() {
    super.initState();
    _studentsRepository = locator<StudentsRepository>();
    _academicYearRepository = locator<AcademicYearRepository>();
    _feeStructureRepository = locator<FeeStructureRepository>();
  }

  @override
  void dispose() {
    _studentController.dispose();
    _academicYearController.dispose();
    _feeStructureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateFeeCubit, CreateFeeState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fee assigned successfully'),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state.isFailure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.borderError,
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        Text('Create Fee', style: AppTextStyles.heading4),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Student Field
                    SuggestionFormField<StudentModel>(
                      controller: _studentController,
                      label: 'Student',
                      hint: 'Search and select student',
                      isRequired: true,
                      suggestionsCallback: _searchStudents,
                      itemBuilder: (context, student) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              student.fullName.isNotEmpty
                                  ? student.fullName[0].toUpperCase()
                                  : 'S',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(student.fullName),
                          subtitle: Text(
                            student.enrollment?.classroomName ?? student.email,
                          ),
                          dense: true,
                        );
                      },
                      onSelected: (student) {
                        _selectedStudentId = student.userSchoolId;
                        _studentController.text = student.fullName;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Academic Year Field
                    SuggestionFormField<AcademicYearModel>(
                      controller: _academicYearController,
                      label: 'Academic Year',
                      hint: 'Search and select academic year',
                      isRequired: true,
                      suggestionsCallback: _searchAcademicYears,
                      itemBuilder: (context, academicYear) {
                        return ListTile(
                          title: Text(academicYear.name),
                          subtitle: Text(
                            '${academicYear.formattedStartDate} - ${academicYear.formattedEndDate}',
                          ),
                          trailing: academicYear.isCurrent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.green,
                                    ),
                                  ),
                                )
                              : null,
                          dense: true,
                        );
                      },
                      onSelected: (academicYear) {
                        _selectedAcademicYearId = academicYear.id;
                        _academicYearController.text = academicYear.name;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fee Structure Field
                    SuggestionFormField<FeeStructureModel>(
                      controller: _feeStructureController,
                      label: 'Fee Structure',
                      hint: 'Search and select fee structure',
                      isRequired: true,
                      suggestionsCallback: _searchFeeStructures,
                      itemBuilder: (context, feeStructure) {
                        return ListTile(
                          title: Text(feeStructure.name),
                          subtitle: Text(
                            '${feeStructure.assignedClassName} • ₹${feeStructure.totalAmount.toStringAsFixed(0)}',
                          ),
                          dense: true,
                        );
                      },
                      onSelected: (feeStructure) {
                        _selectedFeeStructureId = feeStructure.id;
                        _feeStructureController.text = feeStructure.name;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            label: 'Create Fee',
                            onPressed: _onSubmit,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<List<StudentModel>> _searchStudents(String query) async {
    try {
      final response = await _studentsRepository.getStudents(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  Future<List<AcademicYearModel>> _searchAcademicYears(String query) async {
    try {
      final response = await _academicYearRepository.getAcademicYears(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  Future<List<FeeStructureModel>> _searchFeeStructures(String query) async {
    try {
      final response = await _feeStructureRepository.getFeeStructures(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  void _onSubmit() {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a student')));
      return;
    }

    if (_selectedAcademicYearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an academic year')),
      );
      return;
    }

    if (_selectedFeeStructureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fee structure')),
      );
      return;
    }

    context.read<CreateFeeCubit>().createStudentFee(
      studentId: _selectedStudentId!,
      academicYearId: _selectedAcademicYearId!,
      feeStructureId: _selectedFeeStructureId!,
    );
  }
}

var d = {
  "success": true,
  "data": {
    "id": "bb42fb3a-5fc2-4c88-9980-f350aab40dd8",
    "email": "arshad@gmail.com",
    "phone": "89333223333",
    "first_name": "Arshad",
    "last_name": null,
    "is_active": true,
    "roles_details": [
      {
        "role__id": "bb811be3-38d7-4f1d-b17a-084bdc2e6952",
        "role__name": "Student",
      },
    ],
    "profile": {
      "id": "ee33a66a-7feb-4360-a0d4-5771750d8139",
      "user": "bb42fb3a-5fc2-4c88-9980-f350aab40dd8",
      "profile_pic":
          "https://school-mgmt-media.s3.amazonaws.com/media/user_profiles/71feb2fb-8bbb-4dc0-b043-2fc73425e93b.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAX4B3W6DXSJ5C4EUA%2F20260327%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20260327T064038Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=cf39ac4d136ce53b5942b0158be1601254f735c222c20a37b52b5e1f9146968c",
      "date_of_birth": "2016-03-10",
      "address": "adfad",
      "agent_id": null,
      "blood_group": "A-",
      "gender": "Female",
      "created_at": "2026-03-27T06:36:13.452891Z",
      "updated_at": "2026-03-27T06:36:13.452908Z",
    },
    "documents": [
      {
        "id": "819f196b-b533-4e44-ab9a-d56597b01223",
        "user": "bb42fb3a-5fc2-4c88-9980-f350aab40dd8",
        "document_file":
            "https://school-mgmt-media.s3.amazonaws.com/media/user_documents/62fa29ff-98e8-4bbd-97ad-faa9a0fd09f4.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAX4B3W6DXSJ5C4EUA%2F20260327%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20260327T064038Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=b928c1a1249d67e9d35a104c36b442b638f99e162cf9086b869fc32cc582effc",
        "document_name": "adhaar",
        "document_number": null,
        "is_verified": false,
        "uploaded_at": "2026-03-27T06:36:13.500428Z",
      },
    ],
    "relation_details": [],
    "classroom_name": "9A",
    "student_enrolment_details": [
      {
        "id": "0cba2f9c-d0df-4f30-bd83-96bee784b00b",
        "classroom": "9ffa3181-8525-4664-93a6-af3fac97512b",
        "academic_year": "fd0663b0-15b9-43de-b9d6-c68cc109f12d",
        "classroom_name": "9A",
        "academic_year_name": "2025 - 2026",
        "roll_no": "2",
      },
    ],
    "user_school_id": "fa5da765-d33d-4e4f-befd-24c954f2f51d",
    "common_id": null,
  },
  "meta": {
    "request_id": "dace7db5-99a3-4766-969f-8e41590177a8",
    "timestamp": "2026-03-27T06:40:38.634652+00:00",
  },
};
