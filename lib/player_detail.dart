import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data.dart';

class PlayerDetailPage extends StatefulWidget {
  final String playerName;

  const PlayerDetailPage({Key? key, required this.playerName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerDetailState();
}

class _PlayerDetailState extends State<PlayerDetailPage> {
  late Future<List<Map<String, dynamic>>> _futureDetails;

  @override
  void initState() {
    super.initState();
    _futureDetails = _fetchPlayerDetails(widget.playerName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playerName),
      ),
      body: _buildPlayerDetails(),
    );
  }

  FutureBuilder _buildPlayerDetails() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Column(
              children: _buildTiles(snapshot.data!),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  List<ListTile> _buildTiles(List<Map<String, dynamic>> data) {
    return data.map((element) {
      final game = (Game.fromJson(element["game"])).name;
      final amount = element["amount"] as int;

      return ListTile(
        leading: Text(game),
        title: Text("$amount"),
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchPlayerDetails(
      String playerName) async {
    final response = await http
        .get(Uri.parse("$BASE_URL/player-details-records?player=$playerName"));

    if (response.statusCode == 200) {
      Map<String, dynamic> json =
          jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

      if (json["status"] == 200) {
        return (json["data"] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(json["message"]);
      }
    } else {
      throw Exception("Error network");
    }
  }
}
