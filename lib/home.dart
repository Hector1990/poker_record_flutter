import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:poker_record/add_record.dart';
import 'package:poker_record/data.dart';
import 'package:poker_record/player_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _futurePlayerAmountList;
  late Future<List<GameRecord>> _futureGameRecord;

  @override
  void initState() {
    super.initState();
    _futurePlayerAmountList = fetchPlayerAmount();
    _futureGameRecord = fetchGameRecords();
  }

  List<Widget> _createPlayerAmountWidget(List<dynamic> playerAmountList) {
    List<PlayerAmount> values =
        playerAmountList.map((e) => PlayerAmount.fromJson(e)).toList();
    values.sort((a, b) => (b.amount.compareTo(a.amount)));

    return values.map((element) {
      int index = values.indexOf(element);
      String tag = "";
      if (index == 0) {
        tag = " - 武林至尊";
      } else if (index == 1) {
        tag = " - 群众演员";
      } else {
        tag = " - 散财童子";
      }

      Color color = Colors.red;
      if (element.amount < 0) {
        color = Colors.green;
      }

      return ListTile(
        dense: false,
        title: Text("${element.player.name}$tag"),
        subtitle: Text(
          "${element.amount}",
          style: TextStyle(
            color: color,
          ),
        ),
        leading: Image(
          image: playerImageMap[element.player.name]!,
          width: 48,
          height: 48,
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlayerDetailPage(playerName: element.player.name);
          }));
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("战绩榜"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddRecordPage(title: "添加战绩");
                }));
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            const ListTile(
              title: Text(
                "排行榜",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            buildPlayerRecordsView(),
            const ListTile(
              title: Text(
                "战绩详情",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            buildTotalRecordsView()
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<dynamic>> buildPlayerRecordsView() {
    return FutureBuilder<List<dynamic>>(
      future: _futurePlayerAmountList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Column(children: _createPlayerAmountWidget(snapshot.data!));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
        }

        return const CircularProgressIndicator();
      },
    );
  }

  FutureBuilder<List<GameRecord>> buildTotalRecordsView() {
    return FutureBuilder<List<GameRecord>>(
      future: _futureGameRecord,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return createRecordsView(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Container createRecordsView(List<GameRecord> gameRecordList) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Table(
        border:
            TableBorder.all(width: 1, borderRadius: BorderRadius.circular(4)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: getRecordTables(gameRecordList),
      ),
    );
  }

  List<TableRow> getRecordTables(List<GameRecord> gameRecordList) {
    List<TableRow> result = [
      TableRow(children: [
        Container(
          height: 36,
          alignment: Alignment.center,
          child: const Text(
            "项目",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            "何伟",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            "何杰",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            "顾健",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            "日期",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ])
    ];
    result.addAll(gameRecordList.map((record) {
      return TableRow(
        children: [
          Container(
              height: 36,
              alignment: Alignment.center,
              child: Text(
                record.game.name,
                style: const TextStyle(fontSize: 13),
              )),
          Center(
            child: Text(
              "${record.playerRecords.singleWhere((element) => element.player.name == "何伟").amount}",
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Center(
            child: Text(
                "${record.playerRecords.singleWhere((element) => element.player.name == "何杰").amount}",
                style: const TextStyle(fontSize: 13)),
          ),
          Center(
            child: Text(
                "${record.playerRecords.singleWhere((element) => element.player.name == "顾健").amount}",
                style: const TextStyle(fontSize: 13)),
          ),
          Center(
              child: Text(DateFormat('MM-dd').format(record.date),
                  style: const TextStyle(fontSize: 13))),
        ],
      );
    }).toList());
    return result;
  }
}

Future<List<dynamic>> fetchPlayerAmount() async {
  final response = await http.get(Uri.parse("$BASE_URL/player-records"));

  if (response.statusCode == 200) {
    Map<String, dynamic> json =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    if (json["status"] == 200) {
      return json["data"];
    } else {
      throw Exception(json["message"]);
    }
  } else {
    throw Exception("Error network");
  }
}

Future<List<GameRecord>> fetchGameRecords() async {
  final response = await http.get(Uri.parse("$BASE_URL/records"));

  if (response.statusCode == 200) {
    Map<String, dynamic> json =
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

    if (json["status"] == 200) {
      return (json["data"] as List<dynamic>)
          .map((e) => GameRecord.fromJson(e))
          .toList();
    } else {
      throw Exception(json["message"]);
    }
  } else {
    throw Exception("Error network");
  }
}
