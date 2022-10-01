import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';
import 'package:zenith_settings/providers/devices.dart';
import 'package:zenith_settings/providers/network_manager.dart';

final wirelessEnabledProvider = StreamProvider<bool>((ref) async* {
  final nm = await ref.watch(networkManagerProvider.future);
  yield nm.wirelessEnabled;
  yield* nm.propertiesChanged.where((propertyNames) => propertyNames.contains('WirelessEnabled')).map((_) {
    return nm.wirelessEnabled;
  });
});

final primaryWirelessDeviceProvider = FutureProvider<NetworkManagerDevice>((ref) async {
  ref.watch(deviceListChangedProvider);
  final nm = await ref.watch(networkManagerProvider.future);
  NetworkManagerDevice device = nm.devices.firstWhere((d) {
    return d.deviceType == NetworkManagerDeviceType.wifi;
  });
  return device;
});

final availableConnectionsChangedProvider = StreamProvider<List<NetworkManagerSettingsConnection>>((ref) async* {
  final device = await ref.watch(primaryWirelessDeviceProvider.future);
  yield device.availableConnections;
  yield* device.propertiesChanged.where((propertyNames) => propertyNames.contains('AvailableConnections')).map((_) {
    return device.availableConnections;
  });
});

final connectionSettingsCacheProvider = FutureProvider((ref) async {
  final availableConnections = await ref.watch(availableConnectionsChangedProvider.future);

  getMapEntry(NetworkManagerSettingsConnection connection) async {
    final settings = await connection.getSettings();
    final ssid = settings["connection"]!["id"]!.asString();
    return MapEntry(ssid, connection);
  }

  final futures = availableConnections.map((e) => getMapEntry(e));
  final entries = await Future.wait(futures);
  return Map.fromEntries(entries);
});

final connectionSettingsBySsidProvider =
    FutureProvider.family<NetworkManagerSettingsConnection, String>((ref, String ssid) async {
  final cache = await ref.watch(connectionSettingsCacheProvider.future);
  return cache[ssid]!;
});

final activeAccessPointProvider = StreamProvider<NetworkManagerAccessPoint?>((ref) async* {
  final wireless = (await ref.watch(primaryWirelessDeviceProvider.future)).wireless!;
  yield wireless.activeAccessPoint;
  yield* wireless.propertiesChanged.where((propertyNames) => propertyNames.contains("ActiveAccessPoint")).map((_) {
    return wireless.activeAccessPoint;
  });
});

final scanFinalizedStreamProvider = StreamProvider<List<NetworkManagerAccessPoint>>((ref) async* {
  final wireless = (await ref.watch(primaryWirelessDeviceProvider.future)).wireless!;
  yield* wireless.propertiesChanged.where((propertyNames) => propertyNames.contains('LastScan')).map((_) {
    return wireless.accessPoints;
  });
});

final nearbyAccessPointsProvider = Provider<List<NetworkManagerAccessPoint>>((ref) {
  final scanFinalized = ref.watch(scanFinalizedStreamProvider);
  final device = ref.watch(primaryWirelessDeviceProvider);

  return scanFinalized.maybeWhen(
    data: (lastScanResults) => lastScanResults,
    orElse: () => device.maybeWhen(
      data: (device) => device.wireless!.accessPoints,
      orElse: () => [],
    ),
  );
});

final scanProvider = StateNotifierProvider<ScanNotifier, AsyncValue<void>>((ref) {
  return ScanNotifier(ref);
});

class ScanNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;

  ScanNotifier(this.ref) : super(const AsyncData(null));

  Future<void> scan() async {
    if (state is AsyncLoading) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final wireless = (await ref.read(primaryWirelessDeviceProvider.future)).wireless!;

      await wireless.requestScan();
      await ref.read(scanFinalizedStreamProvider.stream).first;
    });
  }
}
