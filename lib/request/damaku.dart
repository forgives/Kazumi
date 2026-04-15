import 'package:kazumi/request/request.dart';
import 'package:kazumi/request/api.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/modules/danmaku/danmaku_module.dart';
import 'package:kazumi/modules/danmaku/danmaku_search_response.dart';
import 'package:kazumi/modules/danmaku/danmaku_episode_response.dart';
import 'package:kazumi/utils/string_match.dart';

class DanmakuRequest {
  // 从BgmBangumiID获取DanDanBangumiID
  static Future<int> getDanDanBangumiIDByBgmBangumiID(int bgmBangumiID) async {
    return 0;
  }

  // 从标题获取DanDanBangumiID
  static Future<int> getBangumiIDByTitle(String title) async {
    return 0;
  }

  static Future<List<Danmaku>> getDanDanmaku(int bangumiID, int episode) async {
    List<Danmaku> danmakus = [];
    if (bangumiID == 0) {
      return danmakus;
    }
    // 这里猜测了弹弹Play的分集命名规则，例如上面的番剧ID为1758，第一集弹幕库ID大概率为17580001，但是此命名规则并没有体现在官方API文档里，保险的做法是请求 Api.dandanInfo
    var path = Api.dandanAPIComment +
        bangumiID.toString() +
        episode.toString().padLeft(4, '0');
    var endPoint = Api.dandanAPIDomain + path;
    Map<String, String> withRelated = {
      'withRelated': 'true',
    };
    KazumiLogger().i("Danmaku: final request URL $endPoint");
    final res = await Request().get(endPoint,
        data: withRelated,
        extra: {'customError': '弹幕检索错误: 获取弹幕失败'});

    Map<String, dynamic> jsonData = res.data;
    List<dynamic> comments = jsonData['comments'];

    for (var comment in comments) {
      Danmaku danmaku = Danmaku.fromJson(comment);
      danmakus.add(danmaku);
    }
    return danmakus;
  }

  static Future<List<Danmaku>> getDanDanmakuByEpisodeID(int episodeID) async {
    List<Danmaku> danmakus = [];
    return danmakus;
  }
}
