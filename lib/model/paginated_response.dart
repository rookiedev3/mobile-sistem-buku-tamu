class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  bool get hasMore => currentPage < lastPage;

  PaginatedResponse({required this.data, required this.currentPage, required this.lastPage, required this.total});

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final list = (json['data'] as List).map((e) => fromJsonT(e)).toList();
    return PaginatedResponse(
      data: list,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? list.length,
    );
  }
}