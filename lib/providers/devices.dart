import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith_settings/providers/network_manager.dart';

final deviceListChangedProvider = StreamProvider<void>((ref) async* {
  final nm = await ref.watch(networkManagerProvider.future);
  yield* StreamGroup.merge([nm.deviceAdded, nm.deviceRemoved]);
});
