import 'package:dio/dio.dart';

class CropServices {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Use 10.0.2.2 for emulator; replace with 192.168.1.4 for physical device
  final String baseUrl = "https://vrcrop.pythonanywhere.com";

  Future<String> predictGrowth({
    required double moisture,
    required double temperature,
    required double sunlight,
    required double humidity,
    required double rainfall,
    required double soilPh,
    required String soilType,
    required String cropType,
    required String growthStage,
    required String plantingDate,
  }) async {
    try {
      print("Sending predictGrowth request to: $baseUrl/api/crop/predict-growth/");
      final response = await _dio.post(
        "$baseUrl/api/crop/predict-growth/",
        data: {
          "moisture": moisture,
          "temperature": temperature,
          "sunlight": sunlight,
          "humidity": humidity,
          "rainfall": rainfall,
          "soil_ph": soilPh,
          "soil_type": soilType,
          "crop_type": cropType,
          "growth_stage": growthStage,
          "planting_date": plantingDate,
        },
      );

      print("predictGrowth response: ${response.statusCode} ${response.data}");
      if (response.statusCode == 200 && response.data['growth_stage'] != null) {
        return response.data['growth_stage'].toString();
      }
      throw Exception("Unexpected response: ${response.data}");
    } catch (e) {
      print("predictGrowth error: $e");
      throw Exception("Failed to predict growth: $e");
    }
  }

  Future<double> predictYield({
    required double temperature,
    required double humidity,
    required double windSpeed,
    required double soilPh,
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required String cropType,
    required String soilType,
    required String plantingDate,
    double? biomass,
    double? leafAreaIndex,
  }) async {
    try {
      print("Sending predictYield request to: $baseUrl/api/crop/predict-yield/");
      final response = await _dio.post(
        "$baseUrl/api/crop/predict-yield/",
        data: {
          "Temperature": temperature,
          "Humidity": humidity,
          "Wind_Speed": windSpeed,
          "Soil_pH": soilPh,
          "N": nitrogen,
          "P": phosphorus,
          "K": potassium,
          "crop_type": cropType,
          "soil_type": soilType,
          "planting_date": plantingDate,
          if (biomass != null) "biomass": biomass,
          if (leafAreaIndex != null) "leaf_area_index": leafAreaIndex,
        },
      );

      print("predictYield response: ${response.statusCode} ${response.data}");
      if (response.statusCode == 200 && response.data['predicted_yield'] != null) {
        return response.data['predicted_yield'].toDouble();
      }
      throw Exception("Unexpected response: ${response.data}");
    } catch (e) {
      print("predictYield error: $e");
      throw Exception("Failed to predict yield: $e");
    }
  }
}