import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/settings_tile.dart';
import 'package:zenith_settings/wifi/wifi.dart';

// The default Flutter embedder does not forward touch input for some reason.
// Touch input is instead emulated as pointer events inside the app.
// Since Flutter 2.5, you cannot scroll anymore using the mouse, but this reverses the behavior to how it was before 2.5.
class ScrollWithMouseBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
      };
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      scrollBehavior: ScrollWithMouseBehavior(),
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SettingsList(),
    );
  }
}

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return ListView(
            children: [
              const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.wifi,
                title: "Network & internet",
                subTitle: "Wi-Fi",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WiFi()));
                },
              ),
              SettingsTile(
                icon: Icons.volume_up,
                title: "Sound",
                subTitle: "Volume",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.brightness_6_outlined,
                title: "Display",
                subTitle: "Brightness",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.battery_5_bar,
                title: "Battery",
                subTitle: "99%",
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
