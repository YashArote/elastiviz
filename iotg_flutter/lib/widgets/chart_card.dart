import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../providers/observability_provider.dart';

/// Renders a dynamic multi-series line chart with anomaly markers,
/// time slider, and a collapsible explanation panel.
class ChartCard extends StatefulWidget {
  final ChartData chart;
  final String explanation;

  const ChartCard({
    super.key,
    required this.chart,
    required this.explanation,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  bool _showExplanation = true;
  double _viewStart = 0.0;
  double _viewEnd = 1.0;
  int? _touchedSeriesIndex;
  int? _touchedSpotIndex;

  // Palette for multiple series
  static const _seriesColors = [
    Color(0xFF00D4FF), // electric blue — CPU
    Color(0xFF7B61FF), // violet — Memory
    Color(0xFF00FFA3), // green — Network
    Color(0xFFFFB800), // amber — Disk
    Color(0xFFFF6B6B), // coral — Load
  ];

  static const _anomalyHighColor = Color(0xFFFF4B4B);
  static const _anomalyMedColor = Color(0xFFFFAA00);

  @override
  Widget build(BuildContext context) {
    if (widget.chart.series.isEmpty &&
        widget.chart.barData.isEmpty &&
        widget.chart.statValue == null) {
      return _buildEmpty();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dispatch by chart type
        if (widget.chart.type == 'stat')
          _buildStatView()
        else if (widget.chart.type == 'bar') ...[
          _buildChartHeader(),
          _buildBarView(),
        ] else ...[
          // line (default) — _buildChartHeader already includes the legend
          _buildChartHeader(),
          const SizedBox(height: 8),
          _buildChart(),
          _buildTimeSlider(),
        ],
        // if (widget.chart.hasAnomalies) _buildAnomalyBadges(),
        _buildExplanationToggle(),
        if (_showExplanation) _buildExplanationPanel(),
      ],
    );
  }

  /// Row with legend + maximize button.
  Widget _buildChartHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.chart.type != 'bar')
          Expanded(child: _buildLegend())
        else
          const Spacer(),
        IconButton(
          tooltip: 'Maximize chart',
          icon: const Icon(
            Icons.open_in_full_rounded,
            size: 16,
            color: Colors.white38,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          onPressed: () => _openFullscreen(context),
        ),
      ],
    );
  }

  void _openFullscreen(BuildContext context) {
    final chart = widget.chart;
    final explanation = widget.explanation;
    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    showDialog<void>(
      context: context,
      builder: (_) =>
          FullscreenChartDialog(chart: chart, explanation: explanation),
    ).whenComplete(() {
      // Restore portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }

  Widget _buildEmpty() => Container(
    height: 120,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFF0D1B2A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'No chart data available',
      style: TextStyle(color: Colors.white54),
    ),
  );

  Widget _buildLegend() => Wrap(
    spacing: 16,
    runSpacing: 4,
    children: [
      for (var i = 0; i < widget.chart.series.length; i++)
        // Constrain legend items to prevent a single long series name from
        // pushing everything else off the card.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _seriesColors[i % _seriesColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.chart.series[i].unit.isNotEmpty
                      ? '${widget.chart.series[i].name} [${widget.chart.series[i].unit}]'
                      : widget.chart.series[i].name,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      /*
      if (widget.chart.hasAnomalies) ...[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              color: _anomalyHighColor.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            const Text(
              'Anomaly',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
      */
    ],
  );

  // ── Stat chart ─────────────────────────────────────────────────────────────

  Widget _buildStatView() {
    final val = widget.chart.statValue ?? 0.0;
    final metric = widget.chart.statMetric ?? 'Metric';
    final unit = widget.chart.statUnit ?? '';
    final color = const Color(0xFF00D4FF);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), const Color(0xFF0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            metric,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_formatY(val)}${unit.isNotEmpty ? ' $unit' : ''}',
              style: TextStyle(
                color: color,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bar chart ──────────────────────────────────────────────────────────────

  Widget _buildBarView() {
    final barData = widget.chart.barData;
    if (barData.isEmpty) return _buildEmpty();

    // Collect all metric names from first entry
    final metricNames = barData.first.values.keys.toList();

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (var i = 0; i < barData.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  for (var mi = 0; mi < metricNames.length; mi++)
                    BarChartRodData(
                      toY: barData[i].values[metricNames[mi]] ?? 0,
                      color: _seriesColors[mi % _seriesColors.length],
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                ],
              ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0x22FFFFFF), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          backgroundColor: const Color(0xFF0D1B2A),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (val, _) => Text(
                  _fmtBarY(val, widget.chart.barUnit ?? ''),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= barData.length) return const SizedBox();
                  return SizedBox(
                    width: 60,
                    child: SideTitleWidget(
                      axisSide: AxisSide.bottom,
                      space: 4,
                      child: Text(
                        barData[idx].label,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E2D40),
              getTooltipItem: (group, groupIdx, rod, rodIdx) {
                final entity = barData[groupIdx].label;
                final metric = metricNames[rodIdx];
                return BarTooltipItem(
                  '$entity\n$metric: ${_fmtBarY(rod.toY, widget.chart.barUnit ?? '')}',
                  const TextStyle(color: Colors.white70, fontSize: 11),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final allData = _windowedData();
    if (allData.every((s) => s.isEmpty)) return _buildEmpty();

    final (minX, maxX) = _xRange(allData);
    final (minY, maxY) = _yRange(allData);
    final yPad = (maxY - minY) * 0.1 + 0.001;

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY - yPad,
          maxY: maxY + yPad,
          // clipData removed — it was clipping anomaly vertical lines
          backgroundColor: const Color(0xFF0D1B2A),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0x22FFFFFF), strokeWidth: 0.5),
            getDrawingVerticalLine: (_) =>
                const FlLine(color: Color(0x11FFFFFF), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                _unitLabel(),
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
              axisNameSize: 14,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (val, meta) => Text(
                  _formatY(val),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (maxX - minX) / 4,
                getTitlesWidget: (val, meta) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(val.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('HH:mm').format(dt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E2D40),
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final series = widget.chart.series[spot.barIndex];
                  return LineTooltipItem(
                    '${series.name}: ${_formatY(spot.y)} ${series.unit}',
                    TextStyle(
                      color:
                          _seriesColors[spot.barIndex % _seriesColors.length],
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            touchCallback: (_, response) {
              setState(() {
                _touchedSeriesIndex =
                    response?.lineBarSpots?.firstOrNull?.barIndex;
                _touchedSpotIndex =
                    response?.lineBarSpots?.firstOrNull?.spotIndex;
              });
            },
            handleBuiltInTouches: true,
          ),
          /*
          // Anomaly vertical lines as extra lines data
          extraLinesData: ExtraLinesData(
            verticalLines: _buildAnomalyLines(minX, maxX),
          ),
          */
          lineBarsData: [
            for (var i = 0; i < widget.chart.series.length; i++)
              _buildBarData(i, allData[i]),
          ],
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  LineChartBarData _buildBarData(int idx, List<FlSpot> spots) {
    final color = _seriesColors[idx % _seriesColors.length];
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: spots.length < 60,
        getDotPainter: (spot, _, __, spotIdx) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 1,
          strokeColor: Colors.white24,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.07),
      ),
    );
  }

  /*
  List<VerticalLine> _buildAnomalyLines(double minX, double maxX) {
    final lines = <VerticalLine>[];
    for (final anomaly in widget.chart.anomalies) {
      final x = anomaly.timestamp.millisecondsSinceEpoch.toDouble();
      // Only render markers visible in the current time window
      if (x < minX || x > maxX) continue;
      final color = anomaly.severity == 'high'
          ? _anomalyHighColor
          : _anomalyMedColor;
      lines.add(
        VerticalLine(
          x: x,
          color: color.withOpacity(0.5),
          strokeWidth: 1.5,
          dashArray: [4, 4],
          label: VerticalLineLabel(
            show: true,
            labelResolver: (_) => anomaly.severity == 'high' ? '⚠' : '△',
            style: TextStyle(color: color, fontSize: 10),
            alignment: Alignment.topCenter,
          ),
        ),
      );
    }
    return lines;
  }
  */

  Widget _buildTimeSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text(
              'Time window',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
          RangeSlider(
            values: RangeValues(_viewStart, _viewEnd),
            onChanged: (v) => setState(() {
              _viewStart = v.start;
              _viewEnd = v.end < _viewStart + 0.05 ? _viewStart + 0.05 : v.end;
            }),
            activeColor: const Color(0xFF00D4FF),
            inactiveColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyBadges() {
    final high = widget.chart.anomalies
        .where((a) => a.severity == 'high')
        .length;
    final med = widget.chart.anomalies
        .where((a) => a.severity == 'medium')
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (high > 0) _badge('$high HIGH', _anomalyHighColor),
          if (med > 0) _badge('$med MEDIUM', _anomalyMedColor),
          // 'total anomalies' badge intentionally removed
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );

  Widget _buildExplanationToggle() => GestureDetector(
    onTap: () => setState(() => _showExplanation = !_showExplanation),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            _showExplanation ? Icons.expand_less : Icons.expand_more,
            color: Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            _showExplanation ? 'Hide explanation' : 'Show explanation',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _buildExplanationPanel() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF0A1628),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white10),
    ),
    child: Text(
      widget.explanation,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        height: 1.5,
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<List<FlSpot>> _windowedData() {
    return widget.chart.series.map((series) {
      if (series.data.isEmpty) return <FlSpot>[];
      final allTs = series.data.map((p) => p.timestamp.millisecondsSinceEpoch);
      final minTs = allTs.reduce(min).toDouble();
      final maxTs = allTs.reduce(max).toDouble();
      final range = maxTs - minTs;

      final winMin = minTs + range * _viewStart;
      final winMax = minTs + range * _viewEnd;

      return series.data
          .where((p) {
            final x = p.timestamp.millisecondsSinceEpoch.toDouble();
            return x >= winMin && x <= winMax;
          })
          .map(
            (p) => FlSpot(
              p.timestamp.millisecondsSinceEpoch.toDouble(),
              p.value,
            ),
          )
          .toList();
    }).toList();
  }

  (double, double) _xRange(List<List<FlSpot>> data) {
    double? minX, maxX;
    for (final s in data) {
      for (final p in s) {
        minX = minX == null ? p.x : min(minX, p.x);
        maxX = maxX == null ? p.x : max(maxX, p.x);
      }
    }
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    return (minX ?? now - 1800000, maxX ?? now);
  }

  (double, double) _yRange(List<List<FlSpot>> data) {
    double? minY, maxY;
    for (final s in data) {
      for (final p in s) {
        minY = minY == null ? p.y : min(minY, p.y);
        maxY = maxY == null ? p.y : max(maxY, p.y);
      }
    }
    return (minY ?? 0, maxY ?? 1);
  }

  String _formatY(double val) {
    if (val.abs() >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}G';
    if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)}M';
    if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)}K';
    if (val.abs() < 1 && val != 0) return val.toStringAsFixed(3);
    return val.toStringAsFixed(1);
  }

  /// Unit-aware bar Y-axis formatter.
  String _fmtBarY(double val, String unit) {
    if (unit == 'cores') {
      // Show as decimal cores — avoid 'm' millicore notation
      if (val == 0) return '0c';
      if (val < 0.001) return '<0.001c';
      return '${val.toStringAsFixed(val < 0.1 ? 3 : 2)}c';
    }
    if (unit == 'bytes' || unit == 'bytes/s') {
      if (val.abs() >= 1e9) return '${(val / 1e9).toStringAsFixed(1)} GB';
      if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)} MB';
      if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)} KB';
      return '${val.toStringAsFixed(0)} B';
    }
    if (unit == '%') return '${val.toStringAsFixed(1)}%';
    // Generic fallback — spell out so axis is self-explanatory
    if (val.abs() >= 1e9) return '${(val / 1e9).toStringAsFixed(1)} B';
    if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)} M';
    if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)} K';
    if (val.abs() < 1 && val != 0) return val.toStringAsFixed(3);
    return val.toStringAsFixed(1);
  }

  /// Extracts a shared unit label from all series (e.g. 'cores', '%').
  String _unitLabel() {
    final units = widget.chart.series
        .map((s) => s.unit)
        .where((u) => u.isNotEmpty)
        .toSet();
    if (units.length == 1) return units.first;
    return '';
  }
}

// ── Fullscreen landscape dialog ───────────────────────────────────────────────

/// Opens the chart in a maximised landscape dialog with a close button.
class FullscreenChartDialog extends StatefulWidget {
  final ChartData chart;
  final String explanation;

  const FullscreenChartDialog({
    super.key,
    required this.chart,
    required this.explanation,
  });

  @override
  State<FullscreenChartDialog> createState() => _FullscreenChartDialogState();
}

class _FullscreenChartDialogState extends State<FullscreenChartDialog> {
  double _viewStart = 0.0;
  double _viewEnd = 1.0;

  static const _seriesColors = [
    Color(0xFF00D4FF),
    Color(0xFF7B61FF),
    Color(0xFF00FFA3),
    Color(0xFFFFB800),
    Color(0xFFFF6B6B),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF060F1E),
      child: Scaffold(
        backgroundColor: const Color(0xFF060F1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080F1E),
          elevation: 0,
          title: const Text(
            'Chart — Full View',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.close_fullscreen_rounded,
              color: Colors.white54,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.white10),
          ),
        ),
        body: OrientationBuilder(
          builder: (_, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 24 : 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dispatch by chart type — bar gets its own path
                  if (widget.chart.type == 'bar') ...[
                    _buildFsBarView(isLandscape),
                  ] else ...[
                    _buildFsLegend(),
                    const SizedBox(height: 8),
                    _buildFsChart(isLandscape),
                    _buildFsSlider(),
                  ],
                  if (widget.explanation.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildFsExplanation(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFsLegend() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < widget.chart.series.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _seriesColors[i % _seriesColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.chart.series[i].unit.isNotEmpty
                      ? '${widget.chart.series[i].name} [${widget.chart.series[i].unit}]'
                      : widget.chart.series[i].name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _buildFsChart(bool isLandscape) {
    final allData = _fsWindowedData();
    if (allData.every((s) => s.isEmpty)) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No data', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final s in allData) {
      for (final p in s) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
    }
    final yPad = (maxY - minY) * 0.1 + 0.001;

    return SizedBox(
      height: isLandscape ? 260 : 220,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY - yPad,
          maxY: maxY + yPad,
          // No clipData — allows anomaly vertical lines to render fully
          backgroundColor: const Color(0xFF0D1B2A),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0x22FFFFFF), strokeWidth: 0.5),
            getDrawingVerticalLine: (_) =>
                const FlLine(color: Color(0x11FFFFFF), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (val, _) => Text(
                  _fmtY(val),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (maxX - minX) / 5,
                getTitlesWidget: (val, _) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(val.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('HH:mm').format(dt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            for (var i = 0; i < widget.chart.series.length; i++)
              LineChartBarData(
                spots: allData[i],
                isCurved: true,
                curveSmoothness: 0.3,
                color: _seriesColors[i % _seriesColors.length],
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: _seriesColors[i % _seriesColors.length].withOpacity(
                    0.08,
                  ),
                ),
              ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildFsBarView(bool isLandscape) {
    final barData = widget.chart.barData;
    if (barData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No data', style: TextStyle(color: Colors.white38)),
        ),
      );
    }
    final metricNames = barData.first.values.keys.toList();
    return SizedBox(
      height: isLandscape ? 320 : 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (var i = 0; i < barData.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  for (var mi = 0; mi < metricNames.length; mi++)
                    BarChartRodData(
                      toY: barData[i].values[metricNames[mi]] ?? 0,
                      color: _seriesColors[mi % _seriesColors.length],
                      width: isLandscape ? 28 : 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                ],
              ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0x22FFFFFF), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          backgroundColor: const Color(0xFF0D1B2A),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (val, _) => Text(
                  _fmtBarY(val, widget.chart.barUnit ?? ''),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= barData.length) return const SizedBox();
                  return SizedBox(
                    width: isLandscape ? 160 : 100,
                    child: SideTitleWidget(
                      axisSide: AxisSide.bottom,
                      space: 6,
                      child: Text(
                        barData[idx].label,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E2D40),
              getTooltipItem: (group, groupIdx, rod, rodIdx) {
                final entity = barData[groupIdx].label;
                final metric = metricNames[rodIdx];
                return BarTooltipItem(
                  '',
                  const TextStyle(),
                  children: [
                    TextSpan(
                      text: '$entity\n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    TextSpan(
                      text:
                          '$metric: ${_fmtBarY(rod.toY, widget.chart.barUnit ?? '')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFsSlider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text(
            'Time window',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ),
        RangeSlider(
          values: RangeValues(_viewStart, _viewEnd),
          onChanged: (v) => setState(() {
            _viewStart = v.start;
            _viewEnd = v.end < _viewStart + 0.05 ? _viewStart + 0.05 : v.end;
          }),
          activeColor: const Color(0xFF00D4FF),
          inactiveColor: Colors.white12,
        ),
      ],
    ),
  );

  Widget _buildFsExplanation() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF0A1628),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white10),
    ),
    child: Text(
      widget.explanation,
      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
    ),
  );

  List<List<FlSpot>> _fsWindowedData() {
    return widget.chart.series.map((series) {
      if (series.data.isEmpty) return <FlSpot>[];
      final allTs = series.data.map((p) => p.timestamp.millisecondsSinceEpoch);
      final minTs = allTs.reduce(min).toDouble();
      final maxTs = allTs.reduce(max).toDouble();
      final range = maxTs - minTs;
      final winMin = minTs + range * _viewStart;
      final winMax = minTs + range * _viewEnd;
      return series.data
          .where((p) {
            final x = p.timestamp.millisecondsSinceEpoch.toDouble();
            return x >= winMin && x <= winMax;
          })
          .map(
            (p) =>
                FlSpot(p.timestamp.millisecondsSinceEpoch.toDouble(), p.value),
          )
          .toList();
    }).toList();
  }

  String _fmtY(double val) {
    if (val.abs() >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}G';
    if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)}M';
    if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)}K';
    if (val.abs() < 1 && val != 0) return val.toStringAsFixed(3);
    return val.toStringAsFixed(1);
  }

  /// Unit-aware bar Y-axis formatter (mirrors ChartCardState._fmtBarY).
  String _fmtBarY(double val, String unit) {
    if (unit == 'cores') {
      if (val == 0) return '0c';
      if (val < 0.001) return '<0.001c';
      return '${val.toStringAsFixed(val < 0.1 ? 3 : 2)}c';
    }
    if (unit == 'bytes' || unit == 'bytes/s') {
      if (val.abs() >= 1e9) return '${(val / 1e9).toStringAsFixed(1)} GB';
      if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)} MB';
      if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)} KB';
      return '${val.toStringAsFixed(0)} B';
    }
    if (unit == '%') return '${val.toStringAsFixed(1)}%';
    if (val.abs() >= 1e9) return '${(val / 1e9).toStringAsFixed(1)} B';
    if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)} M';
    if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)} K';
    if (val.abs() < 1 && val != 0) return val.toStringAsFixed(3);
    return val.toStringAsFixed(1);
  }

  List<VerticalLine> _buildFsAnomalyLines(double minX, double maxX) {
    const highColor = Color(0xFFFF4B4B);
    const medColor = Color(0xFFFFAA00);
    return widget.chart.anomalies
        .where((a) {
          final x = a.timestamp.millisecondsSinceEpoch.toDouble();
          return x >= minX && x <= maxX;
        })
        .map((a) {
          final color = a.severity == 'high' ? highColor : medColor;
          return VerticalLine(
            x: a.timestamp.millisecondsSinceEpoch.toDouble(),
            color: color.withOpacity(0.5),
            strokeWidth: 1.5,
            dashArray: [4, 4],
            label: VerticalLineLabel(
              show: true,
              labelResolver: (_) => a.severity == 'high' ? '⚠' : '△',
              style: TextStyle(color: color, fontSize: 10),
              alignment: Alignment.topCenter,
            ),
          );
        })
        .toList();
  }
}
