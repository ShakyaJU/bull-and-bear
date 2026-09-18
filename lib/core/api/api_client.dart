import 'package:dio/dio.dart';

/// This is the ONE place in the whole app that knows how to talk over the
/// network. Every feature's repository uses this instead of creating its
/// own Dio instance — that way, if we ever need to add a header, a timeout,
/// or logging everywhere, we only change it here.
class ApiClient {
  ApiClient() : dio = Dio(
          BaseOptions(
            baseUrl: 'https://nepseapi.surajrimal.dev',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    // This interceptor just prints every request/response to the debug
    // console. Very useful while learning — you can literally watch your
    // app talk to the internet. Remove or silence this before a real release.
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  final Dio dio;
}
