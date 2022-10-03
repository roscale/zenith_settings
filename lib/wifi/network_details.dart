import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/providers/wifi.dart';

class NetworkDetails extends ConsumerWidget {
  final String ssid;

  const NetworkDetails({Key? key, required this.ssid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Network details")),
      body: Builder(builder: (context) {
        final device = ref.watch(primaryWirelessDeviceProvider);

        if (device == null) {
          return Center(
            child: Text(
              "No wireless device available",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        final network = ref.watch(reachableNetworksProvider(device.wireless!).select((networks) => networks[ssid]));
        final isReachable = network != null;
        final activeConnection = ref.watch(deviceActiveConnectionProvider(device));

        print(activeConnection?.id);

        return ListView(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ssid),
              ],
            ),
          ],
        );
      }),
    );
  }
}
