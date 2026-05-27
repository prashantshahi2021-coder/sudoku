import 'package:flutter/material.dart';

import 'app.dart';
import 'engine/ads/mobile_ads_adapter.dart';
import 'storage/game_save_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameSaveStore.init();
  await MobileAdsAdapter.initialize();
  runApp(const SudokuApp());
}
