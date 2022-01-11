import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  Game? _game = games[0];

  final List<GlobalKey<_PlayerInputWidgetState>> _playerKeys = List.generate(
    players.length,
    (index) => GlobalKey<_PlayerInputWidgetState>(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: createGameWidgets(),
            ),
            Column(
              children: createPlayerWidgets(),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    child: const Text("保存"),
                    onPressed: () {
                      final playerRecords = _playerKeys
                          .map((e) => e.currentState!.getAmount())
                          .toList();
                      final gameRecord =
                          GameRecord(_game!, playerRecords, DateTime.now());

                      sendRecord(gameRecord);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> createGameWidgets() {
    return games
        .map(
          (element) => ListTile(
            title: Text(element.name),
            leading: Radio<Game>(
              value: element,
              groupValue: _game,
              onChanged: (Game? value) {
                setState(() {
                  _game = value;
                });
              },
            ),
          ),
        )
        .toList();
  }

  List<PlayerInputWidget> createPlayerWidgets() {
    return players
        .map((e) =>
            PlayerInputWidget(key: _playerKeys[players.indexOf(e)], player: e))
        .toList();
  }

  Future<http.Response> sendRecord(GameRecord gameRecord) async {
    var response = await http.post(
      Uri.parse('$BASE_URL/insert-record'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(gameRecord.toJson()),
    );

    String message;
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> json =
          jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
      message = json["message"];
    } else {
      message = "服务器错误";
    }

    _showMyDialog(message);

    return response;
  }

  Future<void> _showMyDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("提示"),
          content: Container(
            margin: const EdgeInsets.all(16),
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('知道了'),
              onPressed: () {
                Navigator.of(context).pop();
                for (var element in _playerKeys) {
                  element.currentState!.clearData();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class PlayerInputWidget extends StatefulWidget {
  const PlayerInputWidget({Key? key, required this.player}) : super(key: key);

  final Player player;

  @override
  State<StatefulWidget> createState() => _PlayerInputWidgetState();
}

class _PlayerInputWidgetState extends State<PlayerInputWidget> {
  final _start = TextEditingController();
  final _end = TextEditingController();

  PlayerAmount getAmount() {
    return PlayerAmount(
        widget.player, int.parse(_end.text) - int.parse(_start.text));
  }

  void clearData() {
    _start.clear();
    _end.clear();
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(widget.player.name)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _start,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "起始资金",
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _end,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "结束资金",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
