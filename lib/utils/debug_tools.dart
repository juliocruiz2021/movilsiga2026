import 'package:flutter/foundation.dart';

const bool kDebugTracingEnabled = true;
const String kDebugHeaderName = 'X-Debug';
const String kDebugHeaderValue = '1';

void debugTrace(String scope, String message) {
  if (!kDebugTracingEnabled) return;
  final ts = DateTime.now().toIso8601String();
  debugPrint('[$ts][$scope] $message');
}

Map<String, String> withDebugHeader(Map<String, String> headers) {
  if (!kDebugTracingEnabled) return headers;
  return {...headers, kDebugHeaderName: kDebugHeaderValue};
}

Map<String, String> redactHeaders(Map<String, String> headers) {
  final masked = Map<String, String>.from(headers);
  if (masked.containsKey('Authorization')) {
    masked['Authorization'] = '<redacted>';
  }
  return masked;
}

String debugBodyPreview(String raw, {int maxChars = 400}) {
  if (raw.length <= maxChars) return raw;
  return '${raw.substring(0, maxChars)}...';
}
