import 'dart:convert';

class MetTimer {
  final int startTime;
  final int endTime;

  MetTimer(
    this.startTime,
    this.endTime,
  );

  MetTimer copyWith({
    int? startTime,
    int? endTime,
  }) {
    return MetTimer(
      startTime ?? this.startTime,
      endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory MetTimer.fromMap(Map<String, dynamic> map) {
    return MetTimer(
      map['start_time'],
      map['end_time'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MetTimer.fromJson(String source) =>
      MetTimer.fromMap(json.decode(source));

  @override
  String toString() => 'MetTimer(startTime: $startTime, endTime: $endTime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MetTimer &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode;
}
