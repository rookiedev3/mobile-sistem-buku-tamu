class SimpleResponse {
  final bool? status;
  final String? message;

  SimpleResponse({this.status, this.message});

  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      status: json['status'] as bool?,
      // Menangani fleksibilitas nama key dari backend ("message" atau "pesan")
      message: json['message'] as String? ?? json['pesan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}