/// One pipeline point: horizontal length (m) and elevation (m).
class PipelinePoint {
  double horizontalLengthM;
  double elevationM;

  PipelinePoint({
    required this.horizontalLengthM,
    required this.elevationM,
  });

  Map<String, dynamic> toJson() => {
        'horizontal_length_m': horizontalLengthM,
        'elevation_m': elevationM,
      };

  static PipelinePoint fromJson(Map<String, dynamic> json) => PipelinePoint(
        horizontalLengthM: (json['horizontal_length_m'] as num).toDouble(),
        elevationM: (json['elevation_m'] as num).toDouble(),
      );

  PipelinePoint copyWith({double? horizontalLengthM, double? elevationM}) =>
      PipelinePoint(
        horizontalLengthM: horizontalLengthM ?? this.horizontalLengthM,
        elevationM: elevationM ?? this.elevationM,
      );
}
