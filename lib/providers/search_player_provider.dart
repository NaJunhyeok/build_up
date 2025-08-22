import 'dart:async';
import 'package:build_up/services/meta_data_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';

final metaApiProvider = Provider<NexonMetaApi>((_) => NexonMetaApi());

// 검색/필터 상태
final queryProvider = StateProvider<String>((_) => '');
final selectedSeasonProvider = StateProvider<int?>((_) => null);
final selectedPositionProvider = StateProvider<int?>((_) => null);

// 메타 캐시
final seasonsProvider = FutureProvider<List<FoSeason>>((ref) async {
  return ref.watch(metaApiProvider).fetchSeasons();
});
final positionsProvider = FutureProvider<List<FoPosition>>((ref) async {
  return ref.watch(metaApiProvider).fetchPositions();
});
final allPlayersProvider = FutureProvider<List<FoPlayerMeta>>((ref) async {
  return ref.watch(metaApiProvider).fetchPlayersMeta();
});

final seasonListProvider = Provider<List<FoSeason>>((ref) {
  final async = ref.watch(seasonsProvider);
  return async.maybeWhen(data: (v) => v, orElse: () => const <FoSeason>[]);
});

final positionListProvider = Provider<List<FoPosition>>((ref) {
  final async = ref.watch(positionsProvider);
  return async.maybeWhen(data: (v) => v, orElse: () => const <FoPosition>[]);
});

// 검색 결과 (디바운스 + 로컬 필터)
const _debounceMs = 250;
const _defaultPageSize = 100;

final playerSearchProvider = FutureProvider.autoDispose<List<FoPlayerMeta>>((
  ref,
) async {
  await Future<void>.delayed(const Duration(milliseconds: _debounceMs));

  final q = ref.watch(queryProvider).trim().toLowerCase();
  final season = ref.watch(selectedSeasonProvider);
  final pos = ref.watch(selectedPositionProvider);

  final all = await ref.watch(allPlayersProvider.future);
  Iterable<FoPlayerMeta> list = all;
  print(list);
  final noFilter = q.isEmpty && season == null && pos == null;
  if (noFilter) {
    // 이름 기준 정렬 후 상위 N개만
    final base = [...all]
      ..sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
          (b.name ?? '').toLowerCase(),
        ),
      );
    return base.take(_defaultPageSize).toList();
  }

  if (q.isNotEmpty) {
    list = list.where((p) => p.name!.toLowerCase().contains(q));
  }

  if (season != null) {
    list = list.where((p) => p.seasonId == season);
  }
  if (pos != null) {
    list = list.where((p) => p.spposition == pos);
  }

  final result = list.take(200).toList(); // 첫 200개만
  return result;
});
