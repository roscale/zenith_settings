import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nm/nm.dart';

part "network.freezed.dart";

@freezed
class Network with _$Network {
  const Network._();

  const factory Network({
    required String ssid,
    required List<NetworkManagerAccessPoint> accessPoints,
  }) = _Network;

  /// Prioritize high frequency access points.
  NetworkManagerAccessPoint get bestAccessPoint {
    return accessPoints.reduce((value, element) {
      return value.frequency > element.frequency ? value : element;
    });
  }
}
