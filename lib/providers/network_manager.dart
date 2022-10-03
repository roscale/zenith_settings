import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nm/nm.dart';

final networkManagerProvider = FutureProvider<NetworkManagerClient>((ref) async {
  final nm = NetworkManagerClient();
  await nm.connect();
  ref.onDispose(() => nm.close());
  return nm;
});

final deviceListChangedProvider = StreamProvider<void>((ref) async* {
  final nm = ref.watch(networkManagerProvider).value!;
  yield* StreamGroup.merge([nm.deviceAdded, nm.deviceRemoved]);
});
