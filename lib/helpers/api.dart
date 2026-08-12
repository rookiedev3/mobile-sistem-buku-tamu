import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/helpers/user_info.dart';
import 'app_exception.dart';

class Api {
  Future<dynamic>post(dynamic url, dynamic data) async{
    var token = await UserInfo().getToken();
    var responseJson;

    try{
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Accept": "application/json",          // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    }on SocketException{
      throw FetchDataException('No Internet Conection');
    }
    return responseJson;
  }

Future<dynamic> put(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;

    try {
      final response = await http.put( 
        Uri.parse(url),
        body: data,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-HTTP-Method-Override": "PUT",
          "Accept": "application/json",          // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future<dynamic> get(dynamic url) async{
    var token = await UserInfo().getToken();
    var responseJson;

    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Accept": "application/json",          // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    }on SocketException{
      throw FetchDataException('No Interner Conection');
    }
    return responseJson;
  }

  Future<dynamic> delete(dynamic url) async{
    var token = await UserInfo().getToken();
    var responseJson;

    try{
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Accept": "application/json",          // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    }on SocketException{
      throw FetchDataException('No Internet Conection');
    }
    return responseJson;
  }
  

  dynamic _returnResponse(http.Response response){  
    switch (response.statusCode){
      case 200: return response;
      case 400: throw BadRequestException(response.body.toString());
      case 401:
      case 403: throw UnauthorisedException(response.body.toString());
      case 422: throw InvalidInputException(response.body.toString());
      case 500: 
      default: 
        throw FetchDataException(
          'Error Occured while Communication Serveff with StatusCode: ${response.statusCode}'
        );
    }
  }
}