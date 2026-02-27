import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:iotg_client/iotg_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single message in the chat thread.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChartData? chart;
  final String? explanation;
  final bool isLoading;
  final bool isError;
  final int? queryId;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.chart,
    this.explanation,
    this.isLoading = false,
    this.isError = false,
    this.queryId,
  });

  ChatMessage copyWith({
    String? text,
    ChartData? chart,
    String? explanation,
    bool? isLoading,
    bool? isError,
  }) => ChatMessage(
    id: id,
    text: text ?? this.text,
    isUser: isUser,
    timestamp: timestamp,
    chart: chart ?? this.chart,
    explanation: explanation ?? this.explanation,
    isLoading: isLoading ?? this.isLoading,
    isError: isError ?? this.isError,
    queryId: queryId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'explanation': explanation,
    'isLoading': false,
    'isError': isError,
    'queryId': queryId,
    if (chart != null) 'chart': chart!.toJsonMap(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    ChartData? chart;
    final chartMap = json['chart'];
    if (chartMap != null && chartMap is Map<String, dynamic>) {
      try {
        chart = ChartData.fromJsonMap(chartMap);
      } catch (_) {}
    }
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      explanation: json['explanation'] as String?,
      isError: json['isError'] as bool? ?? false,
      queryId: json['queryId'] as int?,
      chart: chart,
    );
  }
}

/// A saved conversation (one chat session).
class SavedConversation {
  final String id;
  final String title; // derived from first user message
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const SavedConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory SavedConversation.fromJson(Map<String, dynamic> json) =>
      SavedConversation(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        messages: ((json['messages'] as List?) ?? [])
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

/// Parsed chart data from the backend JSON output contract.
class ChartData {
  final String type;
  final List<ChartSeries> series;
  final List<AnomalyPoint> anomalies;
  // Bar chart
  final List<BarEntry> barData;
  // Stat / big-number
  final double? statValue;
  final String? statMetric;
  final String? statUnit;
  // Bar chart unit (e.g. 'cores', 'bytes', '%')
  final String? barUnit;

  const ChartData({
    required this.type,
    required this.series,
    required this.anomalies,
    this.barData = const [],
    this.statValue,
    this.statMetric,
    this.statUnit,
    this.barUnit,
  });

  factory ChartData.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final seriesList = (json['series'] as List? ?? [])
        .map((s) => ChartSeries.fromJson(s as Map<String, dynamic>))
        .toList();
    final anomalyList = (json['anomalies'] as List? ?? [])
        .map((a) => AnomalyPoint.fromJson(a as Map<String, dynamic>))
        .toList();
    final barList = (json['bar_data'] as List? ?? [])
        .map((b) => BarEntry.fromJson(b as Map<String, dynamic>))
        .toList();
    return ChartData(
      type: json['type'] as String? ?? 'line',
      series: seriesList,
      anomalies: anomalyList,
      barData: barList,
      statValue: (json['stat_value'] as num?)?.toDouble(),
      statMetric: json['stat_metric'] as String?,
      statUnit: json['stat_unit'] as String?,
      barUnit: json['bar_unit'] as String?,
    );
  }

  /// Serialise to a plain map (for local persistence).
  Map<String, dynamic> toJsonMap() => {
    'type': type,
    'series': series.map((s) => s.toJson()).toList(),
    'anomalies': anomalies.map((a) => a.toJson()).toList(),
    'bar_data': barData.map((b) => b.toJson()).toList(),
    if (statValue != null) 'stat_value': statValue,
    if (statMetric != null) 'stat_metric': statMetric,
    if (statUnit != null) 'stat_unit': statUnit,
    if (barUnit != null) 'bar_unit': barUnit,
  };

  /// Deserialise from a plain map (counterpart to toJsonMap).
  factory ChartData.fromJsonMap(Map<String, dynamic> json) {
    final seriesList = (json['series'] as List? ?? [])
        .map((s) => ChartSeries.fromJson(s as Map<String, dynamic>))
        .toList();
    final anomalyList = (json['anomalies'] as List? ?? [])
        .map((a) => AnomalyPoint.fromJson(a as Map<String, dynamic>))
        .toList();
    final barList = (json['bar_data'] as List? ?? [])
        .map((b) => BarEntry.fromJson(b as Map<String, dynamic>))
        .toList();
    return ChartData(
      type: json['type'] as String? ?? 'line',
      series: seriesList,
      anomalies: anomalyList,
      barData: barList,
      statValue: (json['stat_value'] as num?)?.toDouble(),
      statMetric: json['stat_metric'] as String?,
      statUnit: json['stat_unit'] as String?,
      barUnit: json['bar_unit'] as String?,
    );
  }

  bool get hasAnomalies => anomalies.isNotEmpty;
}

/// One grouped bar — entity label + average metric values.
class BarEntry {
  final String label;
  final Map<String, double> values;
  const BarEntry({required this.label, required this.values});

  factory BarEntry.fromJson(Map<String, dynamic> json) => BarEntry(
    label: json['label'] as String? ?? '',
    values: (json['values'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0),
    ),
  );

  Map<String, dynamic> toJson() => {'label': label, 'values': values};
}

class ChartSeries {
  final String name;
  final String category;
  final String unit;
  final List<TimeSeriesPoint> data;

  const ChartSeries({
    required this.name,
    required this.category,
    required this.unit,
    required this.data,
  });

  factory ChartSeries.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List? ?? []);
    final points = rawData.map((d) {
      final row = d as List;
      final ts = DateTime.tryParse(row[0].toString()) ?? DateTime.now();
      final val = (row[1] as num?)?.toDouble() ?? 0.0;
      return TimeSeriesPoint(ts, val);
    }).toList();
    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return ChartSeries(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      data: points,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'unit': unit,
    'data': data.map((p) => [p.timestamp.toIso8601String(), p.value]).toList(),
  };
}

class TimeSeriesPoint {
  final DateTime timestamp;
  final double value;
  const TimeSeriesPoint(this.timestamp, this.value);
}

class AnomalyPoint {
  final DateTime timestamp;
  final String metric;
  final String severity;
  final String reason;

  const AnomalyPoint({
    required this.timestamp,
    required this.metric,
    required this.severity,
    required this.reason,
  });

  factory AnomalyPoint.fromJson(Map<String, dynamic> json) {
    return AnomalyPoint(
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      metric: json['metric'] as String? ?? '',
      severity: json['severity'] as String? ?? 'low',
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'metric': metric,
    'severity': severity,
    'reason': reason,
  };
}

// ── Constants ──────────────────────────────────────────────────────────────
const _kHistoryKey = 'iotg_conversation_history';
const _kMaxSaved = 30;

/// Observability state provider managing the chat thread, API calls,
/// and local conversation history persistence via SharedPreferences.
class ObservabilityProvider extends ChangeNotifier {
  final Client _client;

  ObservabilityProvider(this._client) {
    _loadHistory();
  }

  final List<ChatMessage> _messages = [];
  bool _isQuerying = false;
  String? _schemaStatus;
  bool _isSaved = false; // tracks if the current state has been persisted
  String? _currentSavedConvId; // ID of the in-progress saved entry (for UPDATE)

  /// The Elastic Agent Builder conversation ID — persisted across turns for
  /// multi-turn memory. Null means the next query starts a fresh conversation.
  String? _conversationId;

  /// Saved past conversations (newest first).
  List<SavedConversation> _savedConversations = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isQuerying => _isQuerying;
  String? get schemaStatus => _schemaStatus;
  bool get hasActiveConversation => _conversationId != null;
  List<SavedConversation> get savedConversations =>
      List.unmodifiable(_savedConversations);

  // ── API ───────────────────────────────────────────────────────────────────

  /// Sends a user query through the full agentic pipeline.
  Future<void> sendQuery(String userQuery) async {
    if (userQuery.trim().isEmpty) return;

    // Add user bubble — new message means the conversation has changed
    _isSaved = false;
    _addMessage(
      ChatMessage(
        id: _uid(),
        text: userQuery,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    // Add loading bot bubble
    final loadingId = _uid();
    _addMessage(
      ChatMessage(
        id: loadingId,
        text: 'Analyzing your query...',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: true,
      ),
    );

    _isQuerying = true;
    notifyListeners();

    try {
      final response = await _client.observability.query(
        userQuery,
        conversationId: _conversationId,
      );

      // Persist the conversation ID returned by Agent Builder
      if (response.conversationId != null &&
          response.conversationId!.isNotEmpty) {
        _conversationId = response.conversationId;
      }

      ChartData? chart;
      if (response.chartJson != null && response.chartJson!.isNotEmpty) {
        try {
          chart = ChartData.fromJson(response.chartJson!);
        } catch (_) {
          chart = null;
        }
      }

      _replaceMessage(
        loadingId,
        ChatMessage(
          id: loadingId,
          text: response.explanation,
          isUser: false,
          timestamp: DateTime.now(),
          chart: chart,
          explanation: response.explanation,
          isError: response.status == 'error',
          queryId: response.queryId,
        ),
      );
      // Auto-save conversation after every successful response.
      // Set _isSaved = true BEFORE the await so concurrent calls
      // (e.g. back button pressed mid-query) don't trigger a second save.
      if (response.status != 'error' && !_isSaved) {
        _isSaved = true;
        await _saveCurrentConversation();
      }
    } catch (e) {
      _replaceMessage(
        loadingId,
        ChatMessage(
          id: loadingId,
          text: 'Connection error: $e',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    }

    _isQuerying = false;
    notifyListeners();
  }

  /// Saves the current conversation and starts a new one.
  Future<void> saveAndStartNew() async {
    if (!_isSaved) await _saveCurrentConversation();
    _isSaved = false;
    _conversationId = null;
    _messages.clear();
    notifyListeners();
  }

  /// Starts a new conversation, auto-saving the current one if it has messages.
  Future<void> newConversation({bool clearMessages = false}) async {
    if (_messages.isNotEmpty && !_isSaved) {
      await _saveCurrentConversation();
    }
    _isSaved = false;
    _currentSavedConvId = null; // reset so next conversation gets a fresh entry
    _conversationId = null;
    if (clearMessages) _messages.clear();
    notifyListeners();
  }

  /// Loads a past conversation into the current chat view.
  /// Marks the conversation as already-saved so pressing back
  /// doesn't create a duplicate entry.
  void loadConversation(SavedConversation conv) {
    _conversationId = null; // break old server context
    _currentSavedConvId = conv.id; // any new messages update THIS entry
    _isSaved = true; // nothing new yet — no re-save needed on back
    _messages
      ..clear()
      ..addAll(conv.messages);
    notifyListeners();
  }

  /// Deletes a saved conversation by ID.
  Future<void> deleteConversation(String id) async {
    _savedConversations.removeWhere((c) => c.id == id);
    await _persistHistory();
    notifyListeners();
  }

  /// Manually triggers a schema refresh.
  Future<void> refreshSchema() async {
    _schemaStatus = 'Refreshing schema...';
    notifyListeners();
    try {
      final result = await _client.observability.refreshSchema();
      _schemaStatus = result;
    } catch (e) {
      _schemaStatus = 'Refresh failed: $e';
    }
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _saveCurrentConversation() async {
    final userMessages = _messages.where((m) => m.isUser).toList();
    if (userMessages.isEmpty) return;

    // Claim the conversation ID BEFORE any await or branch — this prevents
    // concurrent callers (e.g. auto-save + back-button pressed simultaneously)
    // from both thinking they are doing the "first save" and creating duplicates.
    _currentSavedConvId ??= _uid();
    final savedId = _currentSavedConvId!;

    final title = userMessages.first.text.length > 60
        ? '${userMessages.first.text.substring(0, 57)}...'
        : userMessages.first.text;
    final snapshot = List<ChatMessage>.unmodifiable(
      _messages.where((m) => !m.isLoading),
    );

    final idx = _savedConversations.indexWhere((c) => c.id == savedId);
    if (idx != -1) {
      // UPDATE existing entry (conversation grew with more messages)
      _savedConversations[idx] = SavedConversation(
        id: savedId,
        title: title,
        createdAt: _savedConversations[idx].createdAt, // preserve original date
        messages: snapshot,
      );
    } else {
      // First save — create a new entry at the top
      _savedConversations.insert(
        0,
        SavedConversation(
          id: savedId,
          title: title,
          createdAt: DateTime.now(),
          messages: snapshot,
        ),
      );
      if (_savedConversations.length > _kMaxSaved) {
        _savedConversations = _savedConversations.take(_kMaxSaved).toList();
      }
    }
    await _persistHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kHistoryKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      _savedConversations = list
          .map((e) => SavedConversation.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // Corrupt data — reset silently
      _savedConversations = [];
    }
  }

  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kHistoryKey,
        jsonEncode(_savedConversations.map((c) => c.toJson()).toList()),
      );
    } catch (_) {}
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  void _addMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }

  void _replaceMessage(String id, ChatMessage newMsg) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) _messages[idx] = newMsg;
    notifyListeners();
  }

  String _uid() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
