import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';
import 'package:zenith_settings/models/network.dart';
import 'package:zenith_settings/providers/network_manager.dart';

final wirelessEnabledChangedProvider = StreamProvider((ref) {
  final nm = ref.watch(networkManagerProvider).value!;
  return nm.propertiesChanged.where((propertyNames) => propertyNames.contains('WirelessEnabled'));
});

final wirelessEnabledProvider = Provider((ref) {
  ref.watch(wirelessEnabledChangedProvider);

  final nm = ref.watch(networkManagerProvider).value!;
  return nm.wirelessEnabled;
});

final primaryWirelessDeviceProvider = Provider<NetworkManagerDevice?>((ref) {
  ref.watch(deviceListChangedProvider);
  final nm = ref.watch(networkManagerProvider).value!;

  try {
    return nm.devices.firstWhere((d) {
      return d.deviceType == NetworkManagerDeviceType.wifi;
    });
  } on StateError {
    return null;
  }
});

final _deviceStateChangedProvider = StreamProvider.family<void, NetworkManagerDevice>((ref, device) {
  return device.propertiesChanged.where((propertyNames) => propertyNames.contains('State'));
});

final deviceStateProvider = Provider.family<NetworkManagerDeviceState, NetworkManagerDevice>((ref, device) {
  ref.watch(_deviceStateChangedProvider(device));
  return device.state;
});

final _deviceActiveConnectionChangedProvider = StreamProvider.family<void, NetworkManagerDevice>((ref, device) {
  return device.propertiesChanged.where((propertyNames) => propertyNames.contains('ActiveConnection'));
});

final deviceActiveConnectionProvider =
    Provider.family<NetworkManagerActiveConnection?, NetworkManagerDevice>((ref, device) {
  ref.watch(_deviceActiveConnectionChangedProvider(device));
  return device.activeConnection;
});

final _activeConnectionStateChangedProvider =
    StreamProvider.family<void, NetworkManagerActiveConnection>((ref, connection) {
  return connection.propertiesChanged.where((propertyNames) => propertyNames.contains('State'));
});

final activeConnectionStateProvider =
    Provider.family<NetworkManagerActiveConnectionState, NetworkManagerActiveConnection>((ref, connection) {
  ref.watch(_activeConnectionStateChangedProvider(connection));
  return connection.state;
});

final _deviceAvailableConnectionsChangedProvider = StreamProvider.family<void, NetworkManagerDevice>((ref, device) {
  return device.propertiesChanged.where((propertyNames) => propertyNames.contains('AvailableConnections'));
});

final deviceAvailableConnectionsProvider =
    Provider.family<List<NetworkManagerSettingsConnection>, NetworkManagerDevice>((ref, device) {
  ref.watch(_deviceAvailableConnectionsChangedProvider(device));
  return device.availableConnections;
});

final savedConnectionListChangedProvider = StreamProvider<void>((ref) {
  final nm = ref.watch(networkManagerProvider).value!;
  return nm.settings.propertiesChanged.where((propertyNames) => propertyNames.contains('Connections'));
});

final connectionSettingsCacheProvider = FutureProvider<Map<String, NetworkManagerSettingsConnection>>((ref) async {
  ref.watch(savedConnectionListChangedProvider);
  final nm = ref.watch(networkManagerProvider).value!;

  getMapEntry(NetworkManagerSettingsConnection connection) async {
    final settings = await connection.getSettings();
    final ssid = settings["connection"]!["id"]!.asString();
    return MapEntry(ssid, connection);
  }

  final futures = nm.settings.connections.map((e) => getMapEntry(e));
  final entries = await Future.wait(futures);
  return Map.fromEntries(entries);
});

final connectionSettingsBySsidProvider =
    FutureProvider.family<NetworkManagerSettingsConnection?, String>((ref, ssid) async {
  final cache = await ref.watch(connectionSettingsCacheProvider.future);
  return cache[ssid];
});

final scanFinalizedStreamProvider = StreamProvider.family<void, NetworkManagerDeviceWireless>((ref, wireless) {
  return wireless.propertiesChanged.where((propertyNames) => propertyNames.contains('LastScan'));
});

final reachableAccessPointsProvider =
    Provider.family<List<NetworkManagerAccessPoint>, NetworkManagerDeviceWireless>((ref, wireless) {
  ref.watch(scanFinalizedStreamProvider(wireless));
  return wireless.accessPoints;
});

final reachableNetworksProvider = Provider.family<Map<String, Network>, NetworkManagerDeviceWireless>((ref, wireless) {
  var aps = ref.watch(reachableAccessPointsProvider(wireless));
  aps = aps.where((ap) => ap.ssid.isNotEmpty).toList();

  final networks = <String, Network>{};
  for (final ap in aps) {
    final String ssid = utf8.decode(ap.ssid, allowMalformed: true);
    final network = networks.putIfAbsent(ssid, () => Network(ssid: ssid, accessPoints: []));
    networks[ssid] = network.copyWith(accessPoints: [...network.accessPoints, ap]);
  }
  return networks;
});

final scanProvider =
    StateNotifierProvider.family<ScanNotifier, AsyncValue<void>, NetworkManagerDeviceWireless>((ref, wireless) {
  return ScanNotifier(ref, wireless);
});

class ScanNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;
  final NetworkManagerDeviceWireless wireless;

  ScanNotifier(this.ref, this.wireless) : super(const AsyncData(null));

  Future<void> scan() async {
    if (state is AsyncLoading) {
      // Don't start a scan if one is already in progress.
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await wireless.requestScan();
      await ref.read(scanFinalizedStreamProvider(wireless).stream).first;
    });
  }
}
