import 'package:flutter/cupertino.dart';

import '../pages/SettingRoute.dart';

class RouterTable {
  static const String settingPath = 'profile_setting';
  static Map<String, WidgetBuilder> routeTables = {
    settingPath: (context) => const SettingRoute()
  };

  //路由拦截
  static Route onGenerateRoute<T extends Object>(RouteSettings settings) {
    return CupertinoPageRoute<T>(
      settings: settings,
      builder: (context) {
        String? name = settings.name;
        try{
          Widget widget = routeTables[name]!(context);
          return widget;
        }catch(e){
          return const SettingRoute();
        }
      },
    );
  }
}