import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';
import 'package:zenith_settings/providers/network_manager.dart';
import 'package:zenith_settings/providers/wifi.dart';
import 'package:zenith_settings/wifi/button_group.dart';
import 'package:zenith_settings/wifi/util.dart';

class NetworkDetails extends StatelessWidget {
  final String ssid;

  const NetworkDetails({Key? key, required this.ssid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Network details")),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, __) {
          final device = ref.watch(primaryWirelessDeviceProvider);

          if (device == null) {
            return Center(
              child: Text(
                "No wireless device available",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }

          final deviceState = ref.watch(deviceStateProvider(device));
          final network = ref.watch(reachableNetworksProvider(device.wireless!).select((networks) => networks[ssid]));
          final activeConnection = ref.watch(deviceActiveConnectionProvider(device));

          bool isActive = false;
          NetworkManagerActiveConnectionState? connectionState;
          if (activeConnection != null && activeConnection.id == ssid) {
            isActive = true;
            connectionState = ref.watch(activeConnectionStateProvider(activeConnection));
          }

          final signalStrength = network?.bestAccessPoint.strength ?? 0;

          return ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Icon(
                    getSignalStrengthIconData(signalStrength),
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ssid,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _getConnectionStatus(deviceState, connectionState),
                    style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: ButtonGroup(
                  children: [
                    ButtonGroupChild(
                      widget: Column(
                        children: const [
                          Icon(Icons.delete_outline),
                          Text("Forget"),
                        ],
                      ),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        NetworkManagerSettingsConnection? settings =
                            await ref.watch(connectionSettingsCacheProvider.selectAsync((cache) => cache[ssid]));
                        await settings?.delete();
                        navigator.pop();
                      },
                    ),
                    ButtonGroupChild(
                      widget: Column(
                        children: isActive
                            ? const [
                                Icon(Icons.close),
                                Text("Disconnect"),
                              ]
                            : const [
                                Icon(Icons.wifi),
                                Text("Connect"),
                              ],
                      ),
                      onPressed: () async {
                        final nm = await ref.read(networkManagerProvider.future);

                        if (isActive) {
                          nm.deactivateConnection(activeConnection!);
                        } else {
                          if (network == null) {
                            return;
                          }

                          final connection =
                              await ref.read(connectionSettingsCacheProvider.selectAsync((cache) => cache[ssid]));

                          if (connection != null) {
                            final device = ref.read(primaryWirelessDeviceProvider)!;
                            await nm.activateConnection(
                                device: device, connection: connection, accessPoint: network.bestAccessPoint);
                            return;
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _getConnectionStatus(
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
  } else {
    return "Disconnected";
  }
}
