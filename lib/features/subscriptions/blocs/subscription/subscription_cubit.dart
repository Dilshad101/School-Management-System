import 'package:flutter_bloc/flutter_bloc.dart';

import 'subscription_state.dart';

export 'subscription_state.dart';

/// Cubit for managing the Subscription screen state.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(const SubscriptionState());

  /// Initialize and fetch subscription data.
  Future<void> initialize() async {
    emit(state.copyWith(isInitialLoading: true));

    try {
      // Simulate parallel API calls
      final results = await Future.wait([
        _fetchCurrentSubscription(),
        _fetchAvailablePlans(),
      ]);

      final currentSubscription = results[0] as CurrentSubscriptionModel;
      final availablePlans = results[1] as List<SubscriptionPlanModel>;

      emit(
        state.copyWith(
          isInitialLoading: false,
          currentSubscription: currentSubscription,
          availablePlans: availablePlans,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: 'Failed to load subscription data. Please try again.',
        ),
      );
    }
  }

  /// Simulates fetching current subscription from API.
  Future<CurrentSubscriptionModel> _fetchCurrentSubscription() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return CurrentSubscriptionModel(
      planName: 'Standard Plan',
      price: 1999,
      duration: 3,
      status: SubscriptionStatus.active,
      renewsOn: DateTime(2025, 7, 24),
      storageUsed: 6.5,
      totalStorage: 10,
    );
  }

  /// Simulates fetching available plans from API.
  Future<List<SubscriptionPlanModel>> _fetchAvailablePlans() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    const basicFeatures = [
      FeatureModel(name: 'Student Management', isIncluded: true),
      FeatureModel(name: 'Employee Management', isIncluded: true),
      FeatureModel(name: 'Attendance Tracking', isIncluded: true),
      FeatureModel(name: 'Fee Management', isIncluded: false),
      FeatureModel(name: 'Notifications', isIncluded: false),
      FeatureModel(name: 'Reports & Analytics', isIncluded: false),
    ];

    const standardFeatures = [
      FeatureModel(name: 'Student Management', isIncluded: true),
      FeatureModel(name: 'Employee Management', isIncluded: true),
      FeatureModel(name: 'Attendance Tracking', isIncluded: true),
      FeatureModel(name: 'Fee Management', isIncluded: true),
      FeatureModel(name: 'Notifications', isIncluded: true),
      FeatureModel(name: 'Reports & Analytics', isIncluded: false),
    ];

    const premiumFeatures = [
      FeatureModel(name: 'Student Management', isIncluded: true),
      FeatureModel(name: 'Employee Management', isIncluded: true),
      FeatureModel(name: 'Attendance Tracking', isIncluded: true),
      FeatureModel(name: 'Fee Management', isIncluded: true),
      FeatureModel(name: 'Notifications', isIncluded: true),
      FeatureModel(name: 'Reports & Analytics', isIncluded: true),
    ];

    return const [
      SubscriptionPlanModel(
        id: 'basic',
        name: 'Basic',
        monthlyPrice: 999,
        yearlyPrice: 9999,
        duration: 3,
        description: 'Essential tools for small schools',
        features: basicFeatures,
      ),
      SubscriptionPlanModel(
        id: 'standard',
        name: 'Standard',
        monthlyPrice: 1999,
        yearlyPrice: 19999,
        duration: 3,
        description: 'Advanced features for growing schools',
        features: standardFeatures,
        isCurrentPlan: true,
      ),
      SubscriptionPlanModel(
        id: 'premium',
        name: 'Premium',
        monthlyPrice: 2999,
        yearlyPrice: 29999,
        duration: 3,
        description: 'Complete solution for large institutions',
        features: premiumFeatures,
      ),
    ];
  }

  // ==================== Billing Type ====================

  /// Update the selected billing type.
  void updateBillingType(BillingType billingType) {
    emit(state.copyWith(selectedBillingType: billingType));
  }

  // ==================== Plan Selection ====================

  /// Select a plan for upgrade.
  void selectPlan(String planId) {
    emit(state.copyWith(selectedPlanId: planId));
  }

  // ==================== Upgrade/Renew ====================

  /// Upgrade to the selected plan.
  Future<void> upgradeToPlan(String planId) async {
    emit(state.copyWith(upgradeStatus: UpgradeStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Find the selected plan
      final plan = state.availablePlans.firstWhere((p) => p.id == planId);

      // Update current subscription (simulated)
      final newSubscription = CurrentSubscriptionModel(
        planName: '${plan.name} Plan',
        price: plan.getPrice(state.selectedBillingType),
        duration: state.selectedBillingType == BillingType.monthly ? 1 : 12,
        status: SubscriptionStatus.active,
        renewsOn: DateTime.now().add(
          Duration(
            days: state.selectedBillingType == BillingType.monthly ? 30 : 365,
          ),
        ),
        storageUsed: state.currentSubscription?.storageUsed ?? 0,
        totalStorage: plan.id == 'premium'
            ? 50
            : plan.id == 'standard'
            ? 20
            : 10,
      );

      emit(
        state.copyWith(
          upgradeStatus: UpgradeStatus.success,
          currentSubscription: newSubscription,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          upgradeStatus: UpgradeStatus.failure,
          errorMessage: 'Failed to upgrade plan. Please try again.',
        ),
      );
    }
  }

  /// Renew current subscription.
  Future<void> renewSubscription() async {
    emit(state.copyWith(upgradeStatus: UpgradeStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (state.currentSubscription != null) {
        final renewed = CurrentSubscriptionModel(
          planName: state.currentSubscription!.planName,
          price: state.currentSubscription!.price,
          duration: state.currentSubscription!.duration,
          status: SubscriptionStatus.active,
          renewsOn: DateTime.now().add(
            Duration(days: state.currentSubscription!.duration * 30),
          ),
          storageUsed: state.currentSubscription!.storageUsed,
          totalStorage: state.currentSubscription!.totalStorage,
        );

        emit(
          state.copyWith(
            upgradeStatus: UpgradeStatus.success,
            currentSubscription: renewed,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          upgradeStatus: UpgradeStatus.failure,
          errorMessage: 'Failed to renew subscription. Please try again.',
        ),
      );
    }
  }

  /// Reset upgrade status.
  void resetUpgradeStatus() {
    emit(state.copyWith(upgradeStatus: UpgradeStatus.initial));
  }

  /// Clear error message.
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
