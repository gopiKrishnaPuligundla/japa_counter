import 'package:japa_counter/retro_model/mock_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: "https://630a5be6f280658a59cdf99f.mockapi.io/japa_api/v1/")
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  //TODO: here we add rest as abstract methods
  @GET("/test_rest")
  Future<List<MockModel>> getModels();
}