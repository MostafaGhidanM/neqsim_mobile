/// Flow assurance API response.
class FaResponse {
  bool success;
  double? startingPressureBara;
  double? arrivalPressureBara;
  double? totalPressureDropBara;
  double? evr;
  double? liquidVelocityMs;
  double? liquidHoldup;
  /// Iterations used by solver (max 100). Correlation coverage.
  int? iterationsUsed;
  String message;
  double? uTotalWM2K;
  double? ambientTemperatureC;

  FaResponse({
    required this.success,
    this.startingPressureBara,
    this.arrivalPressureBara,
    this.totalPressureDropBara,
    this.evr,
    this.liquidVelocityMs,
    this.liquidHoldup,
    this.iterationsUsed,
    required this.message,
    this.uTotalWM2K,
    this.ambientTemperatureC,
  });

  factory FaResponse.fromJson(Map<String, dynamic> json) => FaResponse(
        success: json['success'] as bool? ?? false,
        startingPressureBara: json['starting_pressure_bara'] != null
            ? (json['starting_pressure_bara'] as num).toDouble()
            : null,
        arrivalPressureBara: json['arrival_pressure_bara'] != null
            ? (json['arrival_pressure_bara'] as num).toDouble()
            : null,
        totalPressureDropBara: json['total_pressure_drop_bara'] != null
            ? (json['total_pressure_drop_bara'] as num).toDouble()
            : null,
        evr: json['evr'] != null ? (json['evr'] as num).toDouble() : null,
        liquidVelocityMs: json['liquid_velocity_m_s'] != null
            ? (json['liquid_velocity_m_s'] as num).toDouble()
            : null,
        liquidHoldup: json['liquid_holdup'] != null
            ? (json['liquid_holdup'] as num).toDouble()
            : null,
        iterationsUsed: json['iterations_used'] != null
            ? (json['iterations_used'] as num).toInt()
            : null,
        message: json['message'] as String? ?? '',
        uTotalWM2K: json['u_total_w_m2_k'] != null
            ? (json['u_total_w_m2_k'] as num).toDouble()
            : null,
        ambientTemperatureC: json['ambient_temperature_c'] != null
            ? (json['ambient_temperature_c'] as num).toDouble()
            : null,
      );
}
