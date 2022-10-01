import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/providers/network_manager.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/network_list.dart';

class WiFi extends ConsumerStatefulWidget {
  const WiFi({Key? key}) : super(key: key);

  @override
  ConsumerState<WiFi> createState() => _WiFiState();
}

class _WiFiState extends ConsumerState<WiFi> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scanProvider.notifier).scan());
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(scanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Network & internet"),
      ),
      body: ListView(
        children: [
          scan.maybeWhen(
            loading: () => const LinearProgressIndicator(minHeight: 4),
            orElse: () => const SizedBox(height: 4),
          ),
          const ToggleWiFi(),
          const Divider(height: 0),
          const NetworkList(),
        ],
      ),
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
          wirelessEnabled.maybeWhen(
            data: (bool enabled) => Switch(
              value: enabled,
              onChanged: (bool? value) {
                _setWirelessEnabled(ref, value!);
              },
            ),
            orElse: () => const Switch(value: false, onChanged: null),
          )
        ],
      ),
      onTap: wirelessEnabled.maybeWhen(
        data: (enabled) => () => _setWirelessEnabled(ref, !enabled),
        orElse: () => () {},
      ),
    );
  }

  void _setWirelessEnabled(WidgetRef ref, bool value) {
    ref.read(networkManagerProvider).whenData((nm) {
      return nm.setWirelessEnabled(value);
    });
  }
}
