import 'package:equatable/equatable.dart';

abstract class DashboardAdminEvent extends Equatable {
  const DashboardAdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardData extends DashboardAdminEvent {
  final String dateFilter; // 'all' atau 'today'
  final String keyword;

  const FetchDashboardData({
    this.dateFilter = 'all',
    this.keyword = '',
  });

  @override
  List<Object?> get props => [dateFilter, keyword];
}

class CheckInVisit extends DashboardAdminEvent {
  final int visitId;

  const CheckInVisit(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

class CancelVisit extends DashboardAdminEvent {
  final int visitId;

  const CancelVisit(this.visitId);

  @override
  List<Object?> get props => [visitId];
}