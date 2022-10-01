import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';
import 'package:zenith_settings/providers/network_manager.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/wpa_auth_dialog.dart';

class NetworkTile extends ConsumerWidget {
  final NetworkManagerAccessPoint ap;

  const NetworkTile({Key? key, required this.ap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAccessPoint = ref.watch(activeAccessPointProvider).mapOrNull(data: (ap) => ap.value);
    final isConnected = activeAccessPoint == ap;

    final String ssid = utf8.decode(ap.ssid, allowMalformed: true);
    final bool isProtected = ap.rsnFlags.isNotEmpty || ap.wpaFlags.isNotEmpty;
    final bool isWpa2Protected = ap.rsnFlags.isNotEmpty;

    bool saved = ref.watch(connectionSettingsBySsidProvider(ssid)).maybeMap(data: (_) => true, orElse: () => false);

    Widget? subtitle;
    if (isConnected) {
      subtitle = const Text("Connected");
    } else if (saved) {
      subtitle = const Text("Saved");
    }

    Widget? leadingIcon;
    if (isConnected) {
      leadingIcon = Icon(
        _getSignalStrengthIconData(ap.strength),
        color: Theme.of(context).indicatorColor,
      );
    } else {
      leadingIcon = Icon(_getSignalStrengthIconData(ap.strength));
    }

    Widget? trailingIcon;
    if (isConnected) {
      trailingIcon = Icon(
        Icons.settings_outlined,
        color: Theme.of(context).indicatorColor,
      );
    } else if (isProtected) {
      trailingIcon = const Icon(Icons.lock_outline_rounded);
    }

    return ListTile(
      leading: leadingIcon,
      trailing: trailingIcon,
      title: Text(ssid),
      subtitle: subtitle,
      minVerticalPadding: 15,
      onTap: () => isConnected ? _viewConnection() : _connect(context, ref, ssid, isWpa2Protected),
    );
  }

  void _connect(BuildContext context, WidgetRef ref, String ssid, bool isWpa2Protected) async {
    final nm = await ref.read(networkManagerProvider.future);
    final device = await ref.read(primaryWirelessDeviceProvider.future);
    final connectionAsyncValue = await AsyncValue.guard(() => ref.read(connectionSettingsBySsidProvider(ssid).future));
    final connection = connectionAsyncValue.mapOrNull(data: (x) => x.value);

    if (connection != null) {
      await nm.activateConnection(device: device, connection: connection, accessPoint: ap);
      return;
    }

    if (isWpa2Protected) {
      final String? password = await showDialog<String>(
        context: context,
        builder: (_) => WpaAuthDialog(apName: ssid),
      );
      if (password != null) {
        await nm.addAndActivateConnection(
          connection: {
            "802-11-wireless-security": {
              "key-mgmt": const DBusString("wpa-psk"),
              "psk": DBusString(password),
            },
          },
          device: device,
          accessPoint: ap,
        );
      }
    }
  }

  void _viewConnection() {
    // TODO
  }
}

IconData _getSignalStrengthIconData(int strength) {
  if (strength <= 20) {
    return Icons.signal_wifi_0_bar;
  } else if (strength <= 40) {
    return Icons.network_wifi_1_bar;
  } else if (strength <= 60) {
    return Icons.network_wifi_2_bar;
  } else if (strength <= 80) {
    return Icons.network_wifi_3_bar;
  } else {
    return Icons.signal_wifi_statusbar_4_bar;
  }
}
