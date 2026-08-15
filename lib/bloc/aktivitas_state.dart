import 'package:equatable/equatable.dart';
import '../model/aktivitas_model.dart';

abstract class AktivitasState extends Equatable {
  const AktivitasState();
  @override
  List<Object?> get props => [];
}

class AktivitasInitial extends AktivitasState {}

class AktivitasLoading extends AktivitasState {}

class AktivitasLoaded extends AktivitasState {
  final List<AktivitasModel> items;
  final String keyword;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const AktivitasLoaded({
    required this.items,
    required this.keyword,
    required this.currentPage,
    required this.hasReachedMax,
    this.isLoadingMore = false,
  });

  AktivitasLoaded copyWith({
    List<AktivitasModel>? items,
    String? keyword,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return AktivitasLoaded(
      items: items ?? this.items,
      keyword: keyword ?? this.keyword,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, keyword, currentPage, hasReachedMax, isLoadingMore];
}

class AktivitasError extends AktivitasState {
  final String message;
  const AktivitasError(this.message);
  @override
  List<Object?> get props => [message];
}