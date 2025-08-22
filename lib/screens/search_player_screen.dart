import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import '../providers/search_player_provider.dart';

class SearchPlayerScreen extends ConsumerStatefulWidget {
  const SearchPlayerScreen({super.key});
  @override
  ConsumerState<SearchPlayerScreen> createState() => _SearchPlayerScreenState();
}

class _SearchPlayerScreenState extends ConsumerState<SearchPlayerScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildImageUrl(FoPlayerMeta p) {
    // spid -> pid(뒤 6자리) 변환 사용 예시
    return 'https://fco.dn.nexoncdn.co.kr/live/externalAssets/common/playersAction/p${p.spid}.png';
    // 실패 시 대체:
    // return 'https://via.placeholder.com/64x64.png?text=${p.pid}';
  }

  @override
  Widget build(BuildContext context) {
    // ▼ 동기 Provider(목록)는 바로 읽어서 사용
    final seasons = ref.watch(seasonListProvider);
    final positions = ref.watch(positionListProvider);

    // ▼ 선택/검색 상태
    final seasonSel = ref.watch(selectedSeasonProvider); // int?
    final positionSel = ref.watch(selectedPositionProvider); // int?
    final results = ref.watch(
      playerSearchProvider,
    ); // AsyncValue<List<FoPlayerMeta>>
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('FC ONLINE 선수 검색')),
      body: Column(
        children: [
          // ── 검색/필터 바 ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 720; // 화면이 좁으면 2줄로
                final barChildren = <Widget>[
                  // 검색 입력
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) =>
                          ref.read(queryProvider.notifier).state = v,
                      decoration: InputDecoration(
                        hintText: '선수명을 입력하세요',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: const OutlineInputBorder(),
                        suffixIcon: (_controller.text.isNotEmpty)
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  ref.read(queryProvider.notifier).state = '';
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 시즌 드롭다운: Flexible + isExpanded 로 가로 폭 유연화
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<int?>(
                      value: ref.watch(selectedSeasonProvider),
                      isExpanded: true, // 내부 콘텐츠가 길어도 줄맞춤
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: '시즌',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('전체'),
                        ),
                        ...ref
                            .watch(seasonListProvider)
                            .map(
                              (s) => DropdownMenuItem<int?>(
                                value: s.seasonId,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max, // 가용 폭만 사용
                                  children: [
                                    // 이미지 크기도 적당히 줄여 폭 절약
                                    Image.network(
                                      s.seasonImg ?? '',
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 32,
                                        height: 32,
                                        color: Colors.grey.shade300,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.person,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // ✅ 텍스트는 남은 영역만 차지 + 말줄임
                                    Expanded(
                                      child: Text(
                                        s.className ?? '',
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                      onChanged: (v) =>
                          ref.read(selectedSeasonProvider.notifier).state = v,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 포지션 드롭다운: Flexible + isExpanded
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<int?>(
                      value: ref.watch(selectedPositionProvider),
                      isExpanded: true,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: '포지션',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('전체'),
                        ),
                        ...ref
                            .watch(positionListProvider)
                            .map(
                              (p) => DropdownMenuItem<int?>(
                                value: p.spposition,
                                child: Text(
                                  p.desc!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                      ],
                      onChanged: (v) =>
                          ref.read(selectedPositionProvider.notifier).state = v,
                    ),
                  ),
                ];

                // 좁은 화면: 2줄(검색 / 시즌+포지션), 넓은 화면: 1줄
                return isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [Expanded(child: barChildren[0])],
                          ), // 검색
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: barChildren[2]), // 시즌
                              const SizedBox(width: 12),
                              Expanded(child: barChildren[4]), // 포지션
                            ],
                          ),
                        ],
                      )
                    : Row(children: barChildren);
              },
            ),
          ),
          const Divider(height: 1),

          // ── 결과 리스트 ────────────────────────────────────────────────
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류가 발생했습니다: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const _EmptyResult();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = list[i];

                    // 포지션/시즌 라벨 찾기 (null 안전)
                    final pos = positions.firstWhere(
                      (x) => x.spposition == (p.spposition ?? -1),
                      orElse: () =>
                          FoPosition(spposition: p.spposition ?? -1, desc: ''),
                    );
                    final season = seasons.firstWhere(
                      (s) => s.seasonId == p.seasonId,
                      orElse: () =>
                          FoSeason(seasonId: p.seasonId, className: 'SEASON'),
                    );

                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _buildImageUrl(p),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person),
                            ),
                          ),
                        ),
                        title: Text(
                          p.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${season.className ?? ''}'
                          '${pos.desc!.isNotEmpty ? ' · ${pos.desc}' : ''}'
                          ' · spid ${p.spid}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: 상세 페이지 이동 (선수 스탯/메타)
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '선수명으로 검색하거나, 시즌/포지션 필터를 선택하세요.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '검색 결과가 없습니다.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
