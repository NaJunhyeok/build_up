class FoSeason {
  final int? seasonId;
  final String? className; // 예: 25TOTS
  final String? seasonImg; // 있으면 사용
  FoSeason({required this.seasonId, required this.className, this.seasonImg});
}

class FoPosition {
  final int? spposition; // 예: 28
  final String? desc; // 예: CF
  FoPosition({required this.spposition, required this.desc});
}

class FoPlayerMeta {
  // spid = seasonId(3자리) + pid(6자리) 패턴
  final int? spid;
  final String? name; // 메타 JSON 키명은 'name' 또는 'spName' 등일 수 있음
  final int? spposition; // 있을 수도/없을 수도 있음 (없으면 UI에서 포지션 미표시)
  FoPlayerMeta({required this.spid, required this.name, this.spposition});

  int get seasonId => int.parse(spid.toString().substring(0, 3));
  int get pid => int.parse(spid.toString().substring(3));
}
