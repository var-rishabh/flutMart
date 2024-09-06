import 'dart:convert';
import 'package:http/http.dart' as http;

// utils
import 'package:flut_mart/utils/models/user.model.dart';

// Base URL for Fake Store API
const String baseUrl = 'https://api.escuelajs.co/api/v1';

class AuthApiService {
  final http.Client client;

  AuthApiService({http.Client? client}) : client = client ?? http.Client();

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  // SignUp user
  Future<Map<String, dynamic>> signupUser(User user) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}
