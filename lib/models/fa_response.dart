/// Flow assurance API response.
class FaResponse {
  bool success;
  double? startingPressureBara;
  double? evr;
  /// Iterations used by solver (max 100). Correlation coverage.
  int? iterationsUsed;
  String message;

  FaResponse({
    required this.success,
    this.startingPressureBara,
    this.evr,
    this.iterationsUsed,
    required this.message,
  });

  factory FaResponse.fromJson(Map<String, dynamic> json) => FaResponse(
        success: json['success'] as bool? ?? false,
        startingPressureBara: json['starting_pressure_bara'] != null
            ? (json['starting_pressure_bara'] as num).toDouble()
            : null,
        evr: json['evr'] != null ? (json['evr'] as num).toDouble() : null,
        iterationsUsed: json['iterations_used'] != null
            ? (json['iterations_used'] as num).toInt()
            : null,
        message: json['message'] as String? ?? '',
      );
}
