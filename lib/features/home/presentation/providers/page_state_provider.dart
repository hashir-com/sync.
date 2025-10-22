// lib/features/home/presentation/providers/page_state_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final nearbyEventsPageProvider = StateProvider<double>((ref) => 0.0);
final topCityEventsPageProvider = StateProvider<double>((ref) => 0.0);
final sportsEventsPageProvider = StateProvider<double>((ref) => 0.0);
final musicEventsPageProvider = StateProvider<double>((ref) => 0.0);
final freeEventsPageProvider = StateProvider<double>((ref) => 0.0);
final bannerPageProvider = StateProvider<int>((ref) => 0);