import 'package:json_annotation/json_annotation.dart';
part 'mock_model.g.dart';

@JsonSerializable()
class MockModel {
  String? createdAt;
  String? name;
  String? avatar;
  String? id;

  MockModel({this.createdAt, this.name, this.avatar, this.id});

  factory MockModel.fromJson(Map<String, dynamic> json) => _$MockModelFromJson(json);

  Map<String, dynamic> toJson() => _$MockModelToJson(this);
}
