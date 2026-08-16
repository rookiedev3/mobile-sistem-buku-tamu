import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/helpers/user_info.dart';
import 'app_exception.dart';

class Api {
  Future<dynamic> post(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Accept": "application/json", // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
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
          "Accept": "application/json", // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future<dynamic> get(dynamic url) async {
    var token = await UserInfo().getToken();
    var responseJson;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Accept": "application/json", // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Interner Conection');
    }
    return responseJson;
  }

  Future<dynamic> delete(dynamic url) async {
    var token = await UserInfo().getToken();
    var responseJson;

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          "Accept": "application/json", // ← TAMBAH BARIS INI
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Conection');
    }
    return responseJson;
  }

  /// HTTP POST MULTIPART (DITAMBAHKAN - Untuk Upload Foto / File)
  Future<dynamic> postMultipart(
    String url,
    Map<String, String> fields, {
    XFile? file,
    String fileParamName = 'photo_path',
  }) async {
    var token = await UserInfo().getToken();
    var responseJson;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Set Header Authorization & Accept (Menggunakan String biasa)
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Tambahkan Text Fields
      request.fields.addAll(fields);

      // Tambahkan File Gambar via Bytes jika ada
      if (file != null) {
        final bytes = await file.readAsBytes(); // 👈 Membaca data byte memori (Aman untuk Chrome & Mobile)
        request.files.add(
          http.MultipartFile.fromBytes(
            fileParamName,
            bytes,
            filename: file.name.isNotEmpty ? file.name : 'upload.jpg',
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      responseJson = _returnResponse(response);
    } catch (e) {
      throw FetchDataException('No Internet Connection or Upload Error');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 422:
        throw InvalidInputException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
          'Error Occured while Communication Serveff with StatusCode: ${response.statusCode}',
        );
    }
  }
}
