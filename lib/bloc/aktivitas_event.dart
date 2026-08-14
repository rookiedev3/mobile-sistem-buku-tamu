import 'package:equatable/equatable.dart';

abstract class AktivitasEvent extends Equatable {
  const AktivitasEvent();
  @override
  List<Object?> get props => [];
}

class FetchAktivitas extends AktivitasEvent {
  const FetchAktivitas();
}

class SearchAktivitas extends AktivitasEvent {
  final String keyword;
  const SearchAktivitas(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class LoadMoreAktivitas extends AktivitasEvent {
  const LoadMoreAktivitas();
}

class RefreshAktivitas extends AktivitasEvent {
  const RefreshAktivitas();
}