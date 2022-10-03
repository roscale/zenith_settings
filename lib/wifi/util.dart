import 'package:flutter/material.dart';

IconData getSignalStrengthIconData(int strength) {
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
