import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';

final networkManagerProvider = FutureProvider<NetworkManagerClient>((ref) async {
  final nm = NetworkManagerClient();
  await nm.connect();
  ref.onDispose(() => nm.close());
  return nm;
});
