// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      json['name'] as String,
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'name': instance.name,
    };

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      json['name'] as String,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'name': instance.name,
    };

PlayerAmount _$PlayerAmountFromJson(Map<String, dynamic> json) => PlayerAmount(
      Player.fromJson(json['player'] as Map<String, dynamic>),
      json['amount'] as int,
    );

Map<String, dynamic> _$PlayerAmountToJson(PlayerAmount instance) =>
    <String, dynamic>{
      'player': instance.player.toJson(),
      'amount': instance.amount,
    };

GameRecord _$GameRecordFromJson(Map<String, dynamic> json) => GameRecord(
      Game.fromJson(json['game'] as Map<String, dynamic>),
      (json['playerRecords'] as List<dynamic>)
          .map((e) => PlayerAmount.fromJson(e as Map<String, dynamic>))
          .toList(),
      DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$GameRecordToJson(GameRecord instance) =>
    <String, dynamic>{
      'game': instance.game.toJson(),
      'playerRecords': instance.playerRecords.map((e) => e.toJson()).toList(),
      'date': instance.date.toIso8601String(),
    };
