/// A fluid definition saved from Define Fluid for use in flow assurance.
class SavedFluid {
  SavedFluid({
    required this.id,
    required this.name,
    required this.type,
    this.compositional,
    this.blackOil,
  })  : assert(type == 'compositional' || type == 'black_oil'),
        assert(
          (type == 'compositional' && compositional != null) ||
              (type == 'black_oil' && blackOil != null),
        );

  final String id;
  final String name;
  /// 'compositional' | 'black_oil'
  final String type;
  final CompositionalDefinition? compositional;
  final BlackOilDefinition? blackOil;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
    };
    if (compositional != null) map['compositional'] = compositional!.toJson();
    if (blackOil != null) map['black_oil'] = blackOil!.toJson();
    return map;
  }

  static SavedFluid? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final type = json['type'] as String?;
    if (id == null || name == null || type == null) return null;
    CompositionalDefinition? comp;
    if (json['compositional'] != null) {
      comp = CompositionalDefinition.fromJson(
        json['compositional'] as Map<String, dynamic>,
      );
    }
    BlackOilDefinition? bo;
    if (json['black_oil'] != null) {
      bo = BlackOilDefinition.fromJson(
        json['black_oil'] as Map<String, dynamic>,
      );
    }
    return SavedFluid(
      id: id,
      name: name,
      type: type,
      compositional: comp,
      blackOil: bo,
    );
  }
}

class CompositionalDefinition {
  CompositionalDefinition({required this.components});

  final List<Map<String, dynamic>> components;

  Map<String, dynamic> toJson() => {
        'components': components,
      };

  static CompositionalDefinition? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final list = json['components'] as List<dynamic>?;
    if (list == null) return null;
    return CompositionalDefinition(
      components: list
          .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
          .toList(),
    );
  }
}

class BlackOilDefinition {
  BlackOilDefinition({
    required this.gorSm3Sm3,
    required this.waterCutFraction,
    this.apiGravity,
  });

  final double gorSm3Sm3;
  final double waterCutFraction;
  final double? apiGravity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'gor_sm3_sm3': gorSm3Sm3,
      'water_cut_fraction': waterCutFraction,
    };
    if (apiGravity != null) map['api_gravity'] = apiGravity;
    return map;
  }

  static BlackOilDefinition? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final gor = (json['gor_sm3_sm3'] as num?)?.toDouble();
    final wc = (json['water_cut_fraction'] as num?)?.toDouble();
    if (gor == null || wc == null) return null;
    return BlackOilDefinition(
      gorSm3Sm3: gor,
      waterCutFraction: wc,
      apiGravity: (json['api_gravity'] as num?)?.toDouble(),
    );
  }
}
