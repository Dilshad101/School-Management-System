import 'package:flutter/material.dart';
import 'package:school_management_system/core/utils/validations.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import 'icon_form_field.dart';

/// Step 3 of Create Student flow - Parent Information.
class ParentInfoStep extends StatefulWidget {
  const ParentInfoStep({
    super.key,
    required this.formKey,
    required this.fullName,
    required this.email,
    required this.contactNo,
    required this.address,
    required this.onFullNameChanged,
    required this.onEmailChanged,
    required this.onContactNoChanged,
    required this.onAddressChanged,
  });

  final GlobalKey<FormState> formKey;
  final String fullName;
  final String email;
  final String contactNo;
  final String address;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onContactNoChanged;
  final ValueChanged<String> onAddressChanged;

  @override
  State<ParentInfoStep> createState() => _ParentInfoStepState();
}

class _ParentInfoStepState extends State<ParentInfoStep> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _contactNoController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: widget.email);
    _contactNoController = TextEditingController(text: widget.contactNo);
    _addressController = TextEditingController(text: widget.address);
  }

  @override
  void didUpdateWidget(covariant ParentInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_fullNameController, widget.fullName, oldWidget.fullName);
    _syncController(_emailController, widget.email, oldWidget.email);
    _syncController(
      _contactNoController,
      widget.contactNo,
      oldWidget.contactNo,
    );
    _syncController(_addressController, widget.address, oldWidget.address);
  }

  void _syncController(
    TextEditingController controller,
    String newValue,
    String oldValue,
  ) {
    if (newValue != oldValue && newValue != controller.text) {
      controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactNoController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Section header
            Text(
              'Parent Information',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Full Name
            IconFormField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter full name',
              icon: Icons.person_outline,
              onChanged: widget.onFullNameChanged,
            ),
            const SizedBox(height: 16),

            // Email
            IconFormField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              onChanged: widget.onEmailChanged,
              validator: (value) => Validations.validateOptionalEmail(value),
            ),
            const SizedBox(height: 16),

            // Contact No
            IconFormField(
              controller: _contactNoController,
              label: 'Contact No',
              hint: '91 00000 00000',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              isRequired: true,
              onChanged: widget.onContactNoChanged,
              validator: (value) => Validations.validatePhoneNumber(value),
            ),
            const SizedBox(height: 16),

            // Address
            IconFormField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter your address',
              keyboardType: TextInputType.streetAddress,
              icon: Icons.location_on_outlined,
              onChanged: widget.onAddressChanged,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
