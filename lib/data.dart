import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

const BASE_URL = "http://wolfspider.myqnapcloud.cn:9080/poker";

@JsonSerializable(explicitToJson: true)
class Game {
  final String name;

  Game(this.name);

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Player {
  final String name;

  Player(this.name);

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlayerAmount {
  final Player player;
  final int amount;

  PlayerAmount(this.player, this.amount);

  factory PlayerAmount.fromJson(Map<String, dynamic> json) =>
      _$PlayerAmountFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerAmountToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GameRecord {
  final Game game;
  final List<PlayerAmount> playerRecords;
  final DateTime date;

  GameRecord(this.game, this.playerRecords, this.date);

  factory GameRecord.fromJson(Map<String, dynamic> json) =>
      _$GameRecordFromJson(json);
  Map<String, dynamic> toJson() => _$GameRecordToJson(this);
}

final List<Game> games = [Game("德州扑克"), Game("跑得快"), Game("炸金花"), Game("斗地主")];

final List<Player> players = [Player("何伟"), Player("何杰"), Player("顾健")];

final Map<String, AssetImage> playerImageMap = {
  "何伟": const AssetImage("images/IMG_1215.JPG"),
  "顾健": const AssetImage("images/IMG_1214.JPG"),
  "何杰": const AssetImage("images/IMG_1213.JPG"),
};
