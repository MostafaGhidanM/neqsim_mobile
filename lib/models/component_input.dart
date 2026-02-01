/// One component for compositional fluid.
class ComponentInput {
  String name;
  double? moles;
  double? moleFraction;

  ComponentInput({
    required this.name,
    this.moles,
    this.moleFraction,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'name': name};
    if (moles != null) m['moles'] = moles;
    if (moleFraction != null) m['mole_fraction'] = moleFraction;
    return m;
  }
}
