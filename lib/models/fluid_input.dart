import 'component_input.dart';

/// Fluid and pipe inputs for flow assurance.
class FluidInput {
  double temperatureC;
  double pressureBara;
  double flowRate;
  String flowUnit;
  String fluidType; // 'black_oil' | 'compositional'
  String? preset;
  List<ComponentInput>? components;
  double diameterM;
  double roughnessM;

  FluidInput({
    required this.temperatureC,
    required this.pressureBara,
    required this.flowRate,
    this.flowUnit = 'MSm3/day',
    required this.fluidType,
    this.preset,
    this.components,
    this.diameterM = 0.3,
    this.roughnessM = 50.0e-6,
  });

  Map<String, dynamic> toFaRequestJson(List<Map<String, dynamic>> pipelinePoints) {
    final body = <String, dynamic>{
      'pipeline_points': pipelinePoints,
      'arrival_pressure_bara': pressureBara,
      'flow_rate': flowRate,
      'flow_unit': flowUnit,
      'fluid_type': fluidType,
      'temperature_c': temperatureC,
      'diameter_m': diameterM,
      'roughness_m': roughnessM,
    };
    if (preset != null && preset!.isNotEmpty) body['preset'] = preset;
    if (components != null && components!.isNotEmpty) {
      body['components'] = components!.map((c) => c.toJson()).toList();
    }
    return body;
  }
}
