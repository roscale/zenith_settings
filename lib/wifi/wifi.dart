import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/providers/network_manager.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/network_list.dart';

class WiFi extends ConsumerStatefulWidget {
  const WiFi({Key? key}) : super(key: key);

  static MaterialPageRoute get route => MaterialPageRoute(builder: (_) => const WiFi());

  @override
  ConsumerState<WiFi> createState() => _WiFiState();
}

class _WiFiState extends ConsumerState<WiFi> {
  @override
  void initState() {
    super.initState();
    // Read all providers before the async gap.
    final wirelessDevice = ref.read(primaryWirelessDeviceProvider)?.wireless!;
    final scanNotifier = wirelessDevice != null ? ref.read(scanProvider(wirelessDevice).notifier) : null;

    Future.microtask(() {
      scanNotifier?.scan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Network & internet"),
      ),
      body: Builder(builder: (context) {
        final wirelessDevice = ref.watch(primaryWirelessDeviceProvider)?.wireless;
        if (wirelessDevice == null) {
          return Center(
            child: Text(
              "No wireless device available",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        AsyncValue scan = ref.watch(scanProvider(wirelessDevice));

        return ListView(
          children: [
            scan.maybeWhen(
              loading: () => const LinearProgressIndicator(minHeight: 4),
              orElse: () => const SizedBox(height: 4),
            ),
            const ToggleWiFi(),
            const Divider(height: 0),
            const NetworkList(),
          ],
        );
      }),
    );
  }
}

class ToggleWiFi extends ConsumerWidget {
  const ToggleWiFi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wirelessEnabled = ref.watch(wirelessEnabledProvider);

    return ListTile(
      minVerticalPadding: 30,
      leading: const Text(
        "Wi-Fi",
        style: TextStyle(fontSize: 20),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: wirelessEnabled,
            onChanged: (bool? value) {
              _setWirelessEnabled(ref, value!);
            },
          )
        ],
      ),
      onTap: () {
        _setWirelessEnabled(ref, !wirelessEnabled);
      },
    );
  }

  void _setWirelessEnabled(WidgetRef ref, bool value) {
    ref.read(networkManagerProvider).whenData((nm) {
      return nm.setWirelessEnabled(value);
    });
  }
}
