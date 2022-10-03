import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/models/network.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/network_tile.dart';

class NetworkList extends ConsumerWidget {
  const NetworkList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wirelessEnabled = ref.watch(wirelessEnabledProvider);
    final device = ref.watch(primaryWirelessDeviceProvider)!;

    final activeConnection = ref.watch(deviceActiveConnectionProvider(device));

    final networksBySsid = ref.watch(reachableNetworksProvider(device.wireless!));
    var networks = networksBySsid.values.toList();

    if (!wirelessEnabled) {
      // Don't show the access point list if the wireless is disabled.
      networks = [];
    }

    networks.sort((a, b) => b.bestAccessPoint.strength - a.bestAccessPoint.strength);

    // Put the active access point at the top.
    if (activeConnection != null) {
      final String ssid = activeConnection.id;
      final Network? connectingNetwork = networksBySsid[ssid];
      if (connectingNetwork != null) {
        networks.remove(connectingNetwork);
        networks.insert(0, connectingNetwork);
      }
    }

    return Column(
      children: networks.map((network) => NetworkTile(network: network)).toList(),
    );
  }
}
