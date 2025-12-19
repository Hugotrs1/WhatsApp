class Response<T> {
  final bool success;
  final String message;
  final T? data;

  Response({
    required this.success,
    required this.message,
    this.data,
  });

  factory Response.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return Response<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson([dynamic Function(T)? toJsonT]) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null && data != null ? toJsonT(data as T) : data,
    };
  }
}