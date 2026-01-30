import 'package:equatable/equatable.dart';

/// Enum for subscription plan billing type.
enum BillingType { monthly, yearly }

/// Enum for subscription status.
enum SubscriptionStatus { active, expired, cancelled }

/// Model for a subscription feature.
class FeatureModel extends Equatable {
  const FeatureModel({required this.name, required this.isIncluded});

  final String name;
  final bool isIncluded;

  @override
  List<Object?> get props => [name, isIncluded];
}

/// Model for a subscription plan.
class SubscriptionPlanModel extends Equatable {
  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.duration,
    required this.description,
    required this.features,
    this.isCurrentPlan = false,
  });

  final String id;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final int duration; // in months
  final String description;
  final List<FeatureModel> features;
  final bool isCurrentPlan;

  double getPrice(BillingType billingType) {
    return billingType == BillingType.monthly ? monthlyPrice : yearlyPrice;
  }

  SubscriptionPlanModel copyWith({
    String? id,
    String? name,
    double? monthlyPrice,
    double? yearlyPrice,
    int? duration,
    String? description,
    List<FeatureModel>? features,
    bool? isCurrentPlan,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      features: features ?? this.features,
      isCurrentPlan: isCurrentPlan ?? this.isCurrentPlan,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    monthlyPrice,
    yearlyPrice,
    duration,
    description,
    features,
    isCurrentPlan,
  ];
}

/// Model for current subscription details.
class CurrentSubscriptionModel extends Equatable {
  const CurrentSubscriptionModel({
    required this.planName,
    required this.price,
    required this.duration,
    required this.status,
    required this.renewsOn,
    required this.storageUsed,
    required this.totalStorage,
  });

  final String planName;
  final double price;
  final int duration; // in months
  final SubscriptionStatus status;
  final DateTime renewsOn;
  final double storageUsed; // in GB
  final double totalStorage; // in GB

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get durationText => '$duration Month${duration > 1 ? '' : ''}';
  String get storageText =>
      '${storageUsed.toStringAsFixed(1)}GB of ${totalStorage.toStringAsFixed(0)}GB';
  double get storagePercentage => storageUsed / totalStorage;

  String get statusText {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [
    planName,
    price,
    duration,
    status,
    renewsOn,
    storageUsed,
    totalStorage,
  ];
}

/// Enum for the submission/upgrade status.
enum UpgradeStatus { initial, loading, success, failure }

/// Immutable state class for SubscriptionCubit.
class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.isInitialLoading = true,
    this.upgradeStatus = UpgradeStatus.initial,
    this.errorMessage,
    this.selectedBillingType = BillingType.monthly,
    this.currentSubscription,
    this.availablePlans = const [],
    this.selectedPlanId,
  });

  final bool isInitialLoading;
  final UpgradeStatus upgradeStatus;
  final String? errorMessage;
  final BillingType selectedBillingType;
  final CurrentSubscriptionModel? currentSubscription;
  final List<SubscriptionPlanModel> availablePlans;
  final String? selectedPlanId;

  /// Helper getters
  bool get isUpgrading => upgradeStatus == UpgradeStatus.loading;
  bool get isUpgradeSuccess => upgradeStatus == UpgradeStatus.success;
  bool get isUpgradeFailure => upgradeStatus == UpgradeStatus.failure;
  bool get hasCurrentSubscription => currentSubscription != null;

  /// Get selected plan
  SubscriptionPlanModel? get selectedPlan {
    if (selectedPlanId == null) return null;
    try {
      return availablePlans.firstWhere((p) => p.id == selectedPlanId);
    } catch (_) {
      return null;
    }
  }

  SubscriptionState copyWith({
    bool? isInitialLoading,
    UpgradeStatus? upgradeStatus,
    String? errorMessage,
    BillingType? selectedBillingType,
    CurrentSubscriptionModel? currentSubscription,
    List<SubscriptionPlanModel>? availablePlans,
    String? selectedPlanId,
  }) {
    return SubscriptionState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      upgradeStatus: upgradeStatus ?? this.upgradeStatus,
      errorMessage: errorMessage,
      selectedBillingType: selectedBillingType ?? this.selectedBillingType,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availablePlans: availablePlans ?? this.availablePlans,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
    );
  }

  @override
  List<Object?> get props => [
    isInitialLoading,
    upgradeStatus,
    errorMessage,
    selectedBillingType,
    currentSubscription,
    availablePlans,
    selectedPlanId,
  ];
}
