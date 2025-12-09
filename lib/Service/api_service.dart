import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

const String apiKey = " ff33b94319b447818aa51133251606";

class WeatherApiService{
  final String _baseUrl ="https://api.weatherapi.com/v1";
  Future<Map<String, dynamic>> getHourlyForecast(String location) async{
    final url = Uri.parse("$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7");

    final res = await http.get(url);

    if(res.statusCode !=200){
      throw Exception("Failed to fetch data: ${res.body}");
    }

    final data = json.decode(res.body);
    // Invalid location
    if(data.containsKey('error')){
      throw Exception(data['error']['message']?? 'invalid location');
    }
    return data;
  }

  // fore previous 7 days forecast
  Future<List<Map<String,dynamic>>> getPastSevenDaysWeather(String location,) async{

      final List<Map<String, dynamic>> pastWeather = [];
      final today = DateTime.now();
      for(int i = 1; i<=7 ; i++){
        final data = today.subtract(Duration(days: i));
        final formattedData = "${data.year}-${data.month.toString().padLeft(2,"0")}-${data.day.toString().padLeft(2,"0")}";

        final url = Uri.parse("$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedData");
        final res = await http.get(url);
        if(res.statusCode ==200){
          final data = json.decode(res.body);

          // Invalid location

          if(data.containsKey('error')){
            throw Exception(data['error']['message']?? 'invalid location');
          }
          if(data['forecast']?['forecastday']!=null){
            pastWeather.add(data);
          }
        }else{
          debugPrint('failed to fetch past data for $formattedData: ${res.body}');
        }

      }

      return pastWeather;
  }
}