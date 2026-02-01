import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Dio get dio => _dio;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
