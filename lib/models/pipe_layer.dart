/// One wall layer for pipeline thermal calculation.
class PipeLayer {
  PipeLayer({required this.material, required this.thicknessInch});

  final String material;
  final double thicknessInch;

  Map<String, dynamic> toJson() => {
        'material': material,
        'thickness_inch': thicknessInch,
      };

  static PipeLayer? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final mat = json['material'] as String?;
    final thick = (json['thickness_inch'] as num?)?.toDouble();
    if (mat == null || thick == null) return null;
    return PipeLayer(material: mat, thicknessInch: thick);
  }
}
