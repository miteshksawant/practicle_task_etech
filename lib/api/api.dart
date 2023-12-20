import 'dart:convert';

import 'package:flutter_practical_task_etech/screens/user/model/user_model.dart';
import 'package:http/http.dart' as http;


/*
class ApiService {
  ApiService._();

  final String apiUrl = 'https://randomuser.me/api/';
  int currentPage = 1;

  static Future<List<User>> fetchUsers({int results = 100}) async {
    final response =
    await http.get(Uri.parse('$apiUrl?page=$currentPage&results=$results'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      currentPage++; // Increment the page for the next request

      return results.map((user) {
        return User(
          name: '${user['name']['first']} ${user['name']['last']}',
          email: user['email'],
          country: user['location']['country'],
          registrationDate: user['registered']['date'],
          userImage: user['picture']['thumbnail'],
          city: user['location']['city'],
          state: user['location']['state'],
          postcode: (user['location']?['postcode'] ?? 0).toString(),
          age: (user['dob']?['age'] ?? 0).toString(),
          birthDate: user['dob']?['date'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
 */

class ApiService {
  static int currentPage = 1; // Declare currentPage as static

  static Future<List<User>> fetchUsers({int results = 100}) async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/?page=$currentPage&results=$results'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      currentPage++; // Increment the page for the next request

      return results.map((user) {
        return User(
          name: '${user['name']['first']} ${user['name']['last']}',
          email: user['email'],
          country: user['location']['country'],
          registrationDate: user['registered']['date'],
          userImage: user['picture']['thumbnail'],
          city: user['location']['city'],
          state: user['location']['state'],
          postcode: (user['location']?['postcode'] ?? 0).toString(),
          age: (user['dob']?['age'] ?? 0).toString(),
          birthDate: user['dob']?['date'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
