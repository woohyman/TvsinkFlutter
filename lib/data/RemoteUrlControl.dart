import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:tv_sink/control/WatchListsController.dart';

class RemoteUrlControl {
  Future<Map<String, dynamic>> fetchDefaultUrlList() async {
    final supabase = Get.find<SupabaseClient>();
    final list = await supabase.from("default_tv_list").select();
    Map<String, dynamic> defaultTvList = <String, dynamic>{};

    for (var item in list) {
      defaultTvList[item["name"]] = {
        "tvgId": "",
        "tvgCountry": "",
        "tvgLanguage": "",
        "tvgLogo": "",
        "groupTitle": "",
        "tvgUrl": [item["url"]],
      };
    }

    return defaultTvList;
  }
}
