import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/player_model.dart';

class NexonMetaApi {
  final Dio _dio;

  NexonMetaApi._(this._dio);

  factory NexonMetaApi() {
    final key = dotenv.env['nexon_api_key'];
    if (key == null || key.isEmpty) {
      throw StateError('NEXON_API_KEY is missing');
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://open.api.nexon.com',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'x-nxopen-api-key': key},
      ),
    );
    return NexonMetaApi._(dio);
  }

  // 메타 JSON들 (경로는 공개 안내에 따른 static/meta 경로 관례)
  Future<List<FoSeason>> fetchSeasons() async {
    final res = await _dio.get('/static/fconline/meta/seasonid.json');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((j) {
      // 키 가드: seasonId / className / seasonImg 후보
      final id = j['seasonId'] ?? j['id'];
      final name = j['className'] ?? j['name'] ?? j['seasonName'];
      return FoSeason(
        seasonId: (id as num).toInt(),
        className: name?.toString() ?? 'UNKNOWN',
        seasonImg: j['seasonImg']?.toString(),
      );
    }).toList();
  }

  Future<List<FoPosition>> fetchPositions() async {
    final res = await _dio.get('/static/fconline/meta/spposition.json');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((j) {
      final code = j['spposition'] ?? j['id'];
      final desc = j['desc'] ?? j['name'];
      return FoPosition(
        spposition: (code as num).toInt(),
        desc: desc?.toString() ?? 'POS',
      );
    }).toList();
  }

  /// 방대한 spid.json (수만 건) — 데모에선 전체 로드 후 로컬 필터.
  /// 운영에선 서버 검색 API로 위임 권장.
  Future<List<FoPlayerMeta>> fetchPlayersMeta() async {
    final res = await _dio.get('/static/fconline/meta/spid.json');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((j) {
      final spid = j['id'] ?? j['spid'];
      final name = j['name'] ?? j['spName'] ?? 'UNKNOWN';
      final pos = j['spposition']; // 없을 수 있음
      return FoPlayerMeta(
        spid: (spid as num).toInt(),
        name: name.toString(),
        spposition: (pos is num) ? pos.toInt() : null,
      );
    }).toList();
  }

  /// 액션샷 이미지 URL 생성
  /// 공식 이미지 항목에 '이미지 정보 조회'가 있으나 구체 키/경로는 로그인 문서.
  /// 현업 관행: pid(뒤 6자리) 기반 p{pid}.png 경로를 우선 시도.
  String buildActionImageUrlByPid(int pid) {
    // 액션샷(추정 경로): playersAction
    return 'https://fco.dn.nexoncdn.co.kr/live/externalAssets/common/playersAction/p$pid.png';
  }

  /// 필요 시 대체(초상 사진 등) 경로를 추가해서 폴백 전략 구성 가능.
}
