import 'package:flutter_app/models/slot.dart';

/// The class to manage a much less ritcher set of slots
/// It only rappresents the vailable hour slots
class AvailableHourSlot {
  final String beginHour;
  final String endHour;

  AvailableHourSlot({required this.beginHour, required this.endHour});

  AvailableHourSlot.fromAvailableSlot(AvailableSlot slot)
      : beginHour = slot.beginHourAsString,
        endHour = slot.endHourAsString;

  @override
  String toString() {
    return "$beginHour - $endHour";
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableHourSlot &&
        other.beginHour == beginHour &&
        other.endHour == endHour;
  }

  @override
  int get hashCode => beginHour.hashCode ^ endHour.hashCode;
}
