import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tvSink/domain/model/TvList.dart';
import 'package:tvSink/tools/ParseTxtSourceToList.dart';

import '../datastore/OptionalDbControl.dart';

class DefaultUrlListRoute extends StatefulWidget {
  const DefaultUrlListRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingRouteState();
}

class _SettingRouteState extends State<DefaultUrlListRoute> {
  final Map<String, Map<String, String>> defaultList =
      <String, Map<String, String>>{};
  OptionalDbControl control = OptionalDbControl();

  @override
  void initState() {
    control.initDatabase().then((value) {
      print("//////////// --> DefaultUrlListRoute");
      control.dogs().then((tvList) {
        print("//////////// --> $tvList");
        setState(() {
          for (var value in tvList) {
            defaultList[value.name] = {
              "url": value.url,
              "status": "",
            };
          }
        });

        final supabase = Supabase.instance.client;
        supabase.from("default_m3u_list").select().then((values) {
          setState(() {
            for (var value in values) {
              defaultList[value["name"]] = {
                "url": value["url"],
                "status": "",
              };
              control.insertDog(
                TvList(
                    id: values.indexOf(value),
                    name: value["name"],
                    url: value["url"]),
              );
            }
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("精选列表资源")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
            itemCount: defaultList.length,
            itemExtent: 50.0, //强制高度为50.0
            itemBuilder: (BuildContext context, int index) {
              final value = defaultList.values.elementAt(index);
              return InkWell(
                onTap: () async {
                  setState(() {
                    value["status"] = "开始下载数据...";
                  });

                  final file = await _localFile;

                  Dio().download(value["url"] ?? "", file.path,
                      onReceiveProgress: (int count, int total) {
                    setState(() {
                      value["status"] = "进度:$count/$total";
                    });
                  }).then((item) {
                    if (item.statusCode == 200) {
                      setState(() {
                        value["status"] = "下载数据成功,开始解析数据";
                        parse(file.path);
                        value["status"] = "已读取至列表";
                      });
                    }
                  }).catchError((e) {
                    setState(() {
                      value["status"] = "加载失败";
                    });
                  });
                },
                child: ListTile(
                    title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(defaultList.keys.elementAt(index)),
                    Text(value["status"] ?? ""),
                  ],
                )),
              );
            }),
      ),
    );
  }
}

Future<String> get _localPath async {
  final _path = await getTemporaryDirectory();
  return _path.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/playList');
}
