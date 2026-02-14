import 'package:flutter/material.dart';

/// Phase envelope data from API: T in K, P in bara.
class PhaseEnvelopeData {
  PhaseEnvelopeData({
    required this.dewPointTK,
    required this.dewPointPBara,
    required this.bubblePointTK,
    required this.bubblePointPBara,
    this.cricondenbarTK,
    this.cricondenbarPBara,
    this.cricondenthermTK,
    this.cricondenthermPBara,
    this.criticalTK,
    this.criticalPBara,
  });

  final List<double> dewPointTK;
  final List<double> dewPointPBara;
  final List<double> bubblePointTK;
  final List<double> bubblePointPBara;
  final double? cricondenbarTK;
  final double? cricondenbarPBara;
  final double? cricondenthermTK;
  final double? cricondenthermPBara;
  final double? criticalTK;
  final double? criticalPBara;

  static double kToC(double k) => k - 273.15;

  static PhaseEnvelopeData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final dewT = (json['dew_point_t_k'] as List?)?.cast<num>().map((e) => e.toDouble()).toList() ?? <double>[];
      final dewP = (json['dew_point_p_bara'] as List?)?.cast<num>().map((e) => e.toDouble()).toList() ?? <double>[];
      final bubT = (json['bubble_point_t_k'] as List?)?.cast<num>().map((e) => e.toDouble()).toList() ?? <double>[];
      final bubP = (json['bubble_point_p_bara'] as List?)?.cast<num>().map((e) => e.toDouble()).toList() ?? <double>[];
      double? cbarT = (json['cricondenbar_t_k'] as num?)?.toDouble();
      double? cbarP = (json['cricondenbar_p_bara'] as num?)?.toDouble();
      double? cthermT = (json['cricondentherm_t_k'] as num?)?.toDouble();
      double? cthermP = (json['cricondentherm_p_bara'] as num?)?.toDouble();
      double? critT = (json['critical_t_k'] as num?)?.toDouble();
      double? critP = (json['critical_p_bara'] as num?)?.toDouble();
      return PhaseEnvelopeData(
        dewPointTK: dewT,
        dewPointPBara: dewP,
        bubblePointTK: bubT,
        bubblePointPBara: bubP,
        cricondenbarTK: cbarT,
        cricondenbarPBara: cbarP,
        cricondenthermTK: cthermT,
        cricondenthermPBara: cthermP,
        criticalTK: critT,
        criticalPBara: critP,
      );
    } catch (_) {
      return null;
    }
  }

  bool get isEmpty =>
      dewPointTK.isEmpty && dewPointPBara.isEmpty && bubblePointTK.isEmpty && bubblePointPBara.isEmpty;

  /// Estimate (Tc, Pc) as the point where bubble curve reaches max T (tip of envelope).
  ({double tK, double pBara})? get estimatedCritical {
    if (bubblePointTK.isEmpty || bubblePointPBara.isEmpty) return null;
    if (criticalTK != null && criticalPBara != null) return (tK: criticalTK!, pBara: criticalPBara!);
    double tMax = bubblePointTK[0];
    double pAtMax = bubblePointPBara[0];
    for (var i = 0; i < bubblePointTK.length; i++) {
      if (bubblePointTK[i] > tMax) {
        tMax = bubblePointTK[i];
        pAtMax = bubblePointPBara[i];
      }
    }
    return (tK: tMax, pBara: pAtMax);
  }
}

/// P-T phase envelope chart with critical point and phase region colors.
class PhaseEnvelopeChart extends StatelessWidget {
  const PhaseEnvelopeChart({
    super.key,
    required this.data,
    this.height = 280,
  });

  final PhaseEnvelopeData? data;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No phase envelope data')),
      );
    }

    final d = data!;
    if (d.dewPointTK.isEmpty && d.bubblePointTK.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No curve points')),
      );
    }

    final theme = Theme.of(context);
    final critical = d.estimatedCritical;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(left: 40, bottom: 24, right: 8, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _PhaseEnvelopePainter(
                data: d,
                critical: critical,
                dewColor: Colors.blue.shade700,
                bubbleColor: Colors.orange.shade700,
                twoPhaseColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                liquidColor: theme.colorScheme.tertiaryContainer.withOpacity(0.25),
                gasColor: theme.colorScheme.secondaryContainer.withOpacity(0.25),
                criticalColor: theme.colorScheme.error,
                labelColor: theme.colorScheme.onSurface,
              ),
            );
                },
              ),
            ),
            const SizedBox(height: 6),
            PhaseEnvelopeLegend(
              dewColor: Colors.blue.shade700,
              bubbleColor: Colors.orange.shade700,
              twoPhaseColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
              criticalColor: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseEnvelopePainter extends CustomPainter {
  _PhaseEnvelopePainter({
    required this.data,
    required this.critical,
    required this.dewColor,
    required this.bubbleColor,
    required this.twoPhaseColor,
    required this.liquidColor,
    required this.gasColor,
    required this.criticalColor,
    required this.labelColor,
  });

  final PhaseEnvelopeData data;
  final ({double tK, double pBara})? critical;
  final Color dewColor;
  final Color bubbleColor;
  final Color twoPhaseColor;
  final Color liquidColor;
  final Color gasColor;
  final Color criticalColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bubT = data.bubblePointTK;
    final bubP = data.bubblePointPBara;
    final dewT = data.dewPointTK;
    final dewP = data.dewPointPBara;
    if (bubT.isEmpty || dewT.isEmpty) return;

    final allT = <double>[...bubT, ...dewT];
    if (critical != null) {
      allT.add(critical!.tK);
    }
    final allP = <double>[...bubP, ...dewP];
    if (critical != null) {
      allP.add(critical!.pBara);
    }
    final minT = allT.reduce((a, b) => a < b ? a : b);
    final maxT = allT.reduce((a, b) => a > b ? a : b);
    final minP = allP.reduce((a, b) => a < b ? a : b);
    final maxP = allP.reduce((a, b) => a > b ? a : b);
    final padT = (maxT - minT).clamp(5.0, 50.0) * 0.15;
    final padP = (maxP - minP).clamp(1.0, 20.0) * 0.15;
    final minXC = PhaseEnvelopeData.kToC(minT) - padT;
    final maxXC = PhaseEnvelopeData.kToC(maxT) + padT;
    final minYP = (minP - padP).clamp(0.0, double.infinity);
    final maxYP = maxP + padP;

    double xToPx(double tC) => (tC - minXC) / (maxXC - minXC) * size.width;
    double yToPx(double p) => size.height - (p - minYP) / (maxYP - minYP) * size.height;

    // 1) Build envelope as closed polygon: bubble low T -> high T, then dew high T -> low T
    final envelopePath = Path();
    final bubSorted = _sortedByT(bubT, bubP);
    final dewSortedRev = _sortedByT(dewT, dewP);
    if (bubSorted.$1.isEmpty || dewSortedRev.$1.isEmpty) return;
    envelopePath.moveTo(xToPx(PhaseEnvelopeData.kToC(bubSorted.$1.first)), yToPx(bubSorted.$2.first));
    for (var i = 1; i < bubSorted.$1.length; i++) {
      envelopePath.lineTo(xToPx(PhaseEnvelopeData.kToC(bubSorted.$1[i])), yToPx(bubSorted.$2[i]));
    }
    for (var i = dewSortedRev.$1.length - 1; i >= 0; i--) {
      envelopePath.lineTo(xToPx(PhaseEnvelopeData.kToC(dewSortedRev.$1[i])), yToPx(dewSortedRev.$2[i]));
    }
    envelopePath.close();

    // 1) Background: light single-phase tint
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = liquidColor,
    );
    // 2) Two-phase region (inside envelope) – distinct color
    canvas.drawPath(envelopePath, Paint()..color = twoPhaseColor);
    // 3) Gas region: right side of chart (high T) – draw after two-phase so it doesn’t cover envelope
    final rightHalf = Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height);
    canvas.drawRect(rightHalf, Paint()..color = gasColor);

    // 2) Draw envelope curves
    final bubPath = Path();
    bubPath.moveTo(xToPx(PhaseEnvelopeData.kToC(bubT[0])), yToPx(bubP[0]));
    for (var i = 1; i < bubT.length; i++) {
      bubPath.lineTo(xToPx(PhaseEnvelopeData.kToC(bubT[i])), yToPx(bubP[i]));
    }
    canvas.drawPath(bubPath, Paint()..color = bubbleColor..style = PaintingStyle.stroke..strokeWidth = 2);

    final dewPath = Path();
    dewPath.moveTo(xToPx(PhaseEnvelopeData.kToC(dewT[0])), yToPx(dewP[0]));
    for (var i = 1; i < dewT.length; i++) {
      dewPath.lineTo(xToPx(PhaseEnvelopeData.kToC(dewT[i])), yToPx(dewP[i]));
    }
    canvas.drawPath(dewPath, Paint()..color = dewColor..style = PaintingStyle.stroke..strokeWidth = 2);

    // 3) Critical point marker
    if (critical != null) {
      final cx = xToPx(PhaseEnvelopeData.kToC(critical!.tK));
      final cy = yToPx(critical!.pBara);
      canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = criticalColor);
      canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = criticalColor..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // 4) Axes and labels (simple)
    _drawAxisLabels(canvas, size, minXC, maxXC, minYP, maxYP, xToPx, yToPx);
  }

  void _drawAxisLabels(Canvas canvas, Size size, double minXC, double maxXC, double minYP, double maxYP,
      double Function(double) xToPx, double Function(double) yToPx) {
    final textStyle = TextStyle(fontSize: 10, color: labelColor);
    for (var t = (minXC ~/ 20) * 20.0; t <= maxXC + 1; t += 20) {
      if (t < minXC) continue;
      final x = xToPx(t);
      if (x < 0 || x > size.width) continue;
      _drawText(canvas, '${t.toInt()}°C', Offset(x, size.height - 2), textStyle, alignBottom: true);
    }
    for (var p = (minYP ~/ 20) * 20.0; p <= maxYP + 1; p += 20) {
      if (p < minYP) continue;
      final y = yToPx(p);
      if (y < 0 || y > size.height) continue;
      _drawText(canvas, '${p.toInt()}', Offset(2, y), textStyle);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style, {bool alignBottom = false}) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    if (alignBottom) {
      tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy - tp.height));
    } else {
      tp.paint(canvas, Offset(offset.dx, offset.dy - tp.height / 2));
    }
  }

  /// Sort by T ascending, return (tList, pList).
  ({List<double> $1, List<double> $2}) _sortedByT(List<double> t, List<double> p) {
    final pairs = List.generate(t.length, (i) => (t[i], p[i]));
    pairs.sort((a, b) => a.$1.compareTo(b.$1));
    return ($1: pairs.map((e) => e.$1).toList(), $2: pairs.map((e) => e.$2).toList());
  }

  @override
  bool shouldRepaint(covariant _PhaseEnvelopePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.critical != critical;
}

/// Legend for phase envelope chart (Dew, Bubble, Two-phase, Critical).
class PhaseEnvelopeLegend extends StatelessWidget {
  const PhaseEnvelopeLegend({
    super.key,
    required this.dewColor,
    required this.bubbleColor,
    required this.twoPhaseColor,
    required this.criticalColor,
  });

  final Color dewColor;
  final Color bubbleColor;
  final Color twoPhaseColor;
  final Color criticalColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _item(dewColor, 'Dew'),
        _item(bubbleColor, 'Bubble'),
        _item(twoPhaseColor, 'Two-phase'),
        _item(criticalColor, 'Critical'),
      ],
    );
  }

  Widget _item(Color color, String label) {
    final isLine = label == 'Dew' || label == 'Bubble';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: isLine ? 2 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: label == 'Critical' ? BoxShape.circle : BoxShape.rectangle,
            border: label == 'Critical' ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
