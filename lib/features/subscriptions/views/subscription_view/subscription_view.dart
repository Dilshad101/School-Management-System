import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/features/subscriptions/blocs/subscription/subscription_cubit.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import 'widgets/billing_toggle.dart';
import 'widgets/current_plan_card.dart';
import 'widgets/plan_card.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit()..initialize(),
      child: const _SubscriptionContent(),
    );
  }
}

class _SubscriptionContent extends StatelessWidget {
  const _SubscriptionContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          // Handle upgrade success
          if (state.isUpgradeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription updated successfully!'),
                backgroundColor: AppColors.green,
              ),
            );
            context.read<SubscriptionCubit>().resetUpgradeStatus();
          }

          // Handle error
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<SubscriptionCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Plan Card
                if (state.hasCurrentSubscription)
                  CurrentPlanCard(
                    subscription: state.currentSubscription!,
                    isLoading: state.isUpgrading,
                    onRenewPressed: () {
                      context.read<SubscriptionCubit>().renewSubscription();
                    },
                  ),

                const SizedBox(height: 24),

                // Subscription Plans Title
                const Text(
                  "Subscription Plan's",
                  style: AppTextStyles.heading4,
                ),
                const SizedBox(height: 16),

                // Billing Toggle (Monthly/Yearly)
                BillingToggle(
                  selectedBillingType: state.selectedBillingType,
                  onChanged: (type) {
                    context.read<SubscriptionCubit>().updateBillingType(type);
                  },
                ),
                const SizedBox(height: 16),

                // Plan Cards
                SizedBox(
                  height: 420,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.availablePlans.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final plan = state.availablePlans[index];
                      return PlanCard(
                        plan: plan,
                        billingType: state.selectedBillingType,
                        isLoading: state.isUpgrading,
                        onUpgradePressed: plan.isCurrentPlan
                            ? null
                            : () {
                                context.read<SubscriptionCubit>().upgradeToPlan(
                                  plan.id,
                                );
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
