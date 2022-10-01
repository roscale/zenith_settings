import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/network_tile.dart';

class NetworkList extends ConsumerWidget {
  const NetworkList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wirelessEnabled = ref.watch(wirelessEnabledProvider).maybeWhen(data: (value) => value, orElse: () => false);
    final activeAccessPoint = ref.watch(activeAccessPointProvider).mapOrNull(data: (ap) => ap.value);
    var aps = ref.watch(nearbyAccessPointsProvider);

    if (!wirelessEnabled) {
      // Don't show the access point list if the wireless is disabled.
      aps = [];
    }

    aps = aps.where((ap) => ap.ssid.isNotEmpty).toList();
    aps.sort((a, b) => b.strength - a.strength);
    final ids = <String>{};
    aps.retainWhere((x) => ids.add(utf8.decode(x.ssid, allowMalformed: true)));

    // Put the active access point at the top.
    if (activeAccessPoint != null) {
      aps.remove(activeAccessPoint);
      aps.insert(0, activeAccessPoint);
    }

    return Column(
      children: aps.map((ap) => NetworkTile(ap: ap)).toList(),
    );
  }
}
