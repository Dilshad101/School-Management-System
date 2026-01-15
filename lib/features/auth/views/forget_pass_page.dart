import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/shared/widgets/text/gradiant_text.dart';
import '../../../shared/styles/app_styles.dart';
import '../../../shared/widgets/input_fields/custom_form_field.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onForgetPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      // For now just print (replace with AuthBloc later)
      debugPrint('Email: $email');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Forget pressed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header with Logo
            Container(
              width: double.infinity,
              height: size.height * 0.28,
              decoration: const BoxDecoration(
                // gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/images/gradiant_background.svg',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 10,
                    child: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.14),

            // Forget Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Welcome to ',
                            style: AppTextStyles.bodyLargeSecondary,
                          ),
                          GradientText(
                            'EduFlow',
                            colors: [AppColors.secondary, AppColors.primary],
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Forgot Password',
                        style: AppTextStyles.heading1,
                      ),
                      const SizedBox(height: 32),

                      CustomFormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Send In Button
                      PrimaryButton(label: 'Send', onTap: _onForgetPressed),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(label, style: AppTextStyles.button),
        ),
      ),
    );
  }
}
