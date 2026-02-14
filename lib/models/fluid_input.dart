import 'component_input.dart';
import 'pipe_layer.dart';
import 'saved_fluid.dart';

/// Fluid and pipe inputs for flow assurance.
class FluidInput {
  double temperatureC;
  /// Arrival pressure (bara) when solving for starting pressure; or unused when startingPressureBara is set.
  double pressureBara;
  double flowRate;
  String flowUnit;
  String fluidType; // 'black_oil' | 'compositional'
  String? preset;
  List<ComponentInput>? components;
  double diameterM;
  double roughnessM;
  /// When set, FA uses this and ignores fluidType/preset/components.
  SavedFluid? savedFluid;
  /// When set, backend runs forward from this pressure and returns arrival pressure.
  double? startingPressureBara;
  double? ambientTemperatureC;
  List<PipeLayer>? pipeLayers;
  String? environment;

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
    this.savedFluid,
    this.startingPressureBara,
    this.ambientTemperatureC,
    this.pipeLayers,
    this.environment,
  });

  Map<String, dynamic> toFaRequestJson(List<Map<String, dynamic>> pipelinePoints) {
    final body = <String, dynamic>{
      'pipeline_points': pipelinePoints,
      'flow_rate': flowRate,
      'flow_unit': flowUnit,
      'temperature_c': temperatureC,
      'diameter_m': diameterM,
      'roughness_m': roughnessM,
    };
    if (savedFluid != null) {
      body['saved_fluid'] = {
        'name': savedFluid!.name,
        'type': savedFluid!.type,
        if (savedFluid!.compositional != null)
          'compositional': savedFluid!.compositional!.toJson(),
        if (savedFluid!.blackOil != null)
          'black_oil': savedFluid!.blackOil!.toJson(),
      };
      body['fluid_type'] = savedFluid!.type;
      if (savedFluid!.type == 'compositional' && savedFluid!.compositional != null) {
        body['components'] = savedFluid!.compositional!.components;
      } else if (savedFluid!.type == 'black_oil' && savedFluid!.blackOil != null) {
        body['preset'] = 'black oil';
        // Backend can use black_oil from saved_fluid
      }
      if (startingPressureBara != null) {
        body['starting_pressure_bara'] = startingPressureBara;
      } else {
        body['arrival_pressure_bara'] = pressureBara;
      }
      if (ambientTemperatureC != null) {
        body['ambient_temperature_c'] = ambientTemperatureC;
      }
      if (pipeLayers != null && pipeLayers!.isNotEmpty) {
        body['pipe_layers'] = pipeLayers!.map((l) => l.toJson()).toList();
      }
      if (environment != null && environment!.isNotEmpty) {
        body['environment'] = environment;
      }
    } else {
      body['arrival_pressure_bara'] = pressureBara;
      body['fluid_type'] = fluidType;
      if (preset != null && preset!.isNotEmpty) body['preset'] = preset;
      if (components != null && components!.isNotEmpty) {
        body['components'] = components!.map((c) => c.toJson()).toList();
      }
      if (startingPressureBara != null) {
        body['starting_pressure_bara'] = startingPressureBara;
      }
      if (ambientTemperatureC != null) {
        body['ambient_temperature_c'] = ambientTemperatureC;
      }
      if (pipeLayers != null && pipeLayers!.isNotEmpty) {
        body['pipe_layers'] = pipeLayers!.map((l) => l.toJson()).toList();
      }
      if (environment != null && environment!.isNotEmpty) {
        body['environment'] = environment;
      }
    }
    return body;
  }
}
