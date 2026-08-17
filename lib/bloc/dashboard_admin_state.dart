import 'package:equatable/equatable.dart';

abstract class DashboardAdminState extends Equatable {
  const DashboardAdminState();

  @override
  List<Object?> get props => [];
}

class DashboardAdminInitial extends DashboardAdminState {}

class DashboardAdminLoading extends DashboardAdminState {}

class DashboardAdminLoaded extends DashboardAdminState {
  final int totalToday;
  final int unfinishedTodayCount;
  final List<dynamic> visits;
  final String currentFilter;
  final String currentKeyword;

  const DashboardAdminLoaded({
    required this.totalToday,
    required this.unfinishedTodayCount,
    required this.visits,
    required this.currentFilter,
    required this.currentKeyword,
  });

  @override
  List<Object?> get props => [
        totalToday,
        unfinishedTodayCount,
        visits,
        currentFilter,
        currentKeyword,
      ];
}

class DashboardAdminFailure extends DashboardAdminState {
  final String errorMessage;

  const DashboardAdminFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class DashboardActionSuccess extends DashboardAdminState {
  final String message;

  const DashboardActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardActionFailure extends DashboardAdminState {
  final String errorMessage;

  const DashboardActionFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}