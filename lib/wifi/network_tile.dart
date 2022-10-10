import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';
import 'package:zenith_settings/models/network.dart';
import 'package:zenith_settings/providers/network_manager.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/dialogs/psk_auth_dialog.dart';
import 'package:zenith_settings/wifi/dialogs/unsupported_network_dialog.dart';
import 'package:zenith_settings/wifi/network_details.dart';
import 'package:zenith_settings/wifi/util.dart';

class NetworkTile extends ConsumerWidget {
  final Network network;

  const NetworkTile({Key? key, required this.network}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(primaryWirelessDeviceProvider)!;
    final deviceState = ref.watch(deviceStateProvider(device));

    NetworkManagerActiveConnection? activeConnection = ref.watch(deviceActiveConnectionProvider(device));
    bool isActive = activeConnection?.id == network.ssid;

    NetworkManagerActiveConnectionState? connectionState;
    if (activeConnection != null && isActive) {
      connectionState = ref.watch(activeConnectionStateProvider(activeConnection));
    }

    final ap = network.bestAccessPoint;

    List<NetworkManagerWifiAccessPointSecurityFlag> securityFlags = ap.rsnFlags.isNotEmpty ? ap.rsnFlags : ap.wpaFlags;

    final bool isConnectionSaved = ref.watch(connectionSettingsBySsidProvider(network.ssid)).asData?.value != null;

    String? connectionStatus = _getConnectionStatus(
      isConnectionSaved,
      deviceState,
      connectionState,
    );
    Widget? subtitle = connectionStatus != null ? Text(connectionStatus) : null;

    Widget? leadingIcon;
    if (isActive) {
      leadingIcon = Icon(
        getSignalStrengthIconData(ap.strength),
        color: Theme.of(context).indicatorColor,
      );
    } else {
      leadingIcon = Icon(getSignalStrengthIconData(ap.strength));
    }

    Widget? trailingIcon;
    if (isActive) {
      trailingIcon = Icon(
        Icons.settings_outlined,
        color: Theme.of(context).indicatorColor,
      );
    } else if (securityFlags.isNotEmpty) {
      trailingIcon = const Icon(Icons.lock_outline_rounded);
    }

    return ListTile(
      leading: leadingIcon,
      trailing: trailingIcon,
      title: Text(network.ssid),
      subtitle: subtitle,
      minVerticalPadding: 15,
      onTap: () => isActive
          ? _viewConnectionDetails(context, network.ssid)
          : _connect(context, ref, network.ssid, securityFlags),
    );
  }

  String? _getConnectionStatus(
    bool isConnectionSaved,
    NetworkManagerDeviceState? deviceState,
    NetworkManagerActiveConnectionState? connectionState,
  ) {
    if (connectionState == NetworkManagerActiveConnectionState.activating) {
      if (deviceState == NetworkManagerDeviceState.needAuth) {
        return "Needs authentication...";
      } else {
        return "Connecting...";
      }
    } else if (connectionState == NetworkManagerActiveConnectionState.activated) {
      return "Connected";
    } else if (connectionState == NetworkManagerActiveConnectionState.deactivating) {
      return "Disconnecting...";
    } else if (isConnectionSaved) {
      return "Saved";
    }
    return null;
  }

  void _connect(
    BuildContext context,
    WidgetRef ref,
    String ssid,
    List<NetworkManagerWifiAccessPointSecurityFlag> securityFlags,
  ) async {
    final nm = await ref.read(networkManagerProvider.future);
    final device = ref.read(primaryWirelessDeviceProvider)!;
    final connection = await ref.read(connectionSettingsCacheProvider.selectAsync((cache) => cache[ssid]));

    if (connection != null) {
      await nm.activateConnection(device: device, connection: connection, accessPoint: network.bestAccessPoint);
      return;
    }

    if (securityFlags.isEmpty) {
      // Open wireless network.
      await nm.addAndActivateConnection(
        device: device,
        accessPoint: network.bestAccessPoint,
      );
    } else if (securityFlags.contains(NetworkManagerWifiAccessPointSecurityFlag.keyManagementPsk)) {
      // Pre-shared key.
      final String? password = await showDialog<String>(
        context: context,
        builder: (_) => PskAuthDialog(apName: ssid),
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
          accessPoint: network.bestAccessPoint,
        );
      }
    } else {
      await showDialog<String>(
        context: context,
        builder: (_) => const UnsupportedNetworkDialog(),
      );
    }
  }

  void _viewConnectionDetails(BuildContext context, String ssid) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NetworkDetails(ssid: ssid),
    ));
  }
}
