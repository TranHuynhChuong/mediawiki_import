import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service kiểm tra login, lấy thông tin wiki và quyền user
class CheckAuthService {
  final String baseUrl;
  final String? username;
  final String? password;

  late final String apiUrl;
  final http.Client _client = http.Client();
  Map<String, String> _cookies = {};

  CheckAuthService({
    required this.baseUrl,
    this.username,
    this.password,
  }) {
    apiUrl = baseUrl.endsWith('/api.php')
        ? baseUrl
        : '${baseUrl.replaceAll(RegExp(r'/\$'), '')}/api.php';
  }

  /// Giữ cookie từ header Set-Cookie
  void _updateCookies(http.Response resp) {
    try {
      String? rawCookie = resp.headers['set-cookie'];
      if (rawCookie != null) {
        for (var cookie in rawCookie.split(',')) {
          var parts = cookie.split(';')[0].split('=');
          if (parts.length == 2) {
            _cookies[parts[0].trim()] = parts[1].trim();
          }
        }
      }
    } catch (e) {
      print('Error updating cookies: $e');
    }
  }

  Map<String, String> get _headers {
    if (_cookies.isEmpty) return {};
    String cookie = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    return {'Cookie': cookie};
  }

  /// Lấy login token
  Future<String> fetchLoginToken() async {
    try {
      final resp = await _client.get(
        Uri.parse('$apiUrl?action=query&meta=tokens&type=login&format=json'),
      );
      _updateCookies(resp);

      final data = json.decode(resp.body);
      final token = data['query']?['tokens']?['logintoken'];
      return token ?? '';
    } catch (e) {
      print('Error fetching login token: $e');
      return '';
    }
  }

  /// Đăng nhập
  Future<Map<String, String?>> login() async {
    if (username == null || password == null) {
      print('No username/password, skip login');
      return {'status': 'skipped', 'username': null};
    }

    try {
      final token = await fetchLoginToken();
      if (token.isEmpty) {
        print('Login token is empty');
        return {'status': 'fail', 'username': null};
      }

      final resp = await _client.post(
        Uri.parse('$apiUrl?action=clientlogin&format=json'),
        headers: _headers,
        body: {
          'username': username!,
          'password': password!,
          'logintoken': token,
          'loginreturnurl': baseUrl,
          'rememberMe': '1',
        },
      );

      _updateCookies(resp);


      final data = json.decode(resp.body);
      final loginInfo = data['clientlogin'] ?? data['login'] ?? {};

      return {
        'status': loginInfo['status'] ?? 'fail',
        'username': loginInfo['username'],
        'password': password
      };
    } catch (e) {
      print('Login error: $e');
      return {'status': 'error', 'username': null, 'password': null};
    }
  }

  /// Lấy thông tin site
  Future<Map<String, dynamic>> fetchSiteInfo() async {
    try {
      final resp = await _client.get(
        Uri.parse('$apiUrl?action=query&meta=siteinfo&format=json'),
        headers: _headers,
      );


      final data = json.decode(resp.body);
      final general = data['query']?['general'] ?? {};

      return {
        'sitename': general['sitename'] ?? '',
        'base_url':  apiUrl,
      };
    } catch (e) {
      print('Error fetching site info: $e');
      return {'sitename': '', 'base_url': ''};
    }
  }

  /// Lấy quyền user
  Future<Map<String, bool>> fetchUserRights() async {
    try {
      final resp = await _client.get(
        Uri.parse('$apiUrl?action=query&meta=userinfo&uiprop=rights&format=json'),
        headers: _headers,
      );

      final data = json.decode(resp.body);
      final rights = List<String>.from(data['query']?['userinfo']?['rights'] ?? []);

      // Các quyền cần kiểm tra
      final requiredRights = ['import', 'importupload', 'edit', 'createpage', 'autoconfirmed'];

      // Kiểm tra từng quyền
      final Map<String, bool> hasRights = {
        for (var r in requiredRights) r: rights.contains(r),
      };

      return hasRights;
    } catch (e) {
      print('Error fetching user rights: $e');
      return {
        'import': false,
        'importupload': false,
        'edit': false,
        'createpage': false,
      };
    }
  }

  /// Kết hợp init: login + fetch site info + fetch user rights
  Future<Map<String, dynamic>> init() async {
    print('--- Starting init ---');
    Map<String, dynamic> result = {};

    result['login'] = await login();
    result['siteInfo'] = await fetchSiteInfo();
    result['userRights'] = await fetchUserRights();


    print('--- Init finished ---');
    return result;
  }

  /// Đóng client
  void dispose() {
    _client.close();
  }
}
