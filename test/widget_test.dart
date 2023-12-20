// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class User {
//   final String name;
//   final String email;
//   final String country;
//   final String registrationDate;
//   final String city;
//   final String state;
//   String? postcode;
//   String? userImage;
//   String? age;
//   String? birthDate;
//
//   User(
//       {required this.name,
//         required this.email,
//         required this.country,
//         required this.registrationDate,
//         required this.city,
//         required this.state,
//         this.postcode,
//         this.userImage,
//         this.age,
//         this.birthDate});
//
//   // Convert User object to a map
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'email': email,
//       'country': country,
//     };
//   }
// }
//
// class DatabaseHelper {
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await initDatabase();
//     return _database!;
//   }
//
//   Future<Database> initDatabase() async {
//     final path = join(await getDatabasesPath(), 'users.db');
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, email TEXT, country TEXT, registrationDate TEXT, userImage TEXT, city TEXT, state TEXT, postcode TEXT, age TEXT, birthDate TEXT)',
//         );
//       },
//     );
//   }
//
//   Future<void> insertUser(User user) async {
//     final db = await database;
//     await db.insert(
//       'users',
//       user.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//   Future<List<User>> getUsers() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('users');
//     return List.generate(maps.length, (index) {
//       return User(
//         name: maps[index]['name'],
//         email: maps[index]['email'],
//         country: maps[index]['country'],
//         registrationDate: maps[index]['registrationDate'],
//         userImage: maps[index]['userImage'],
//         city: maps[index]['city'],
//         state: maps[index]['state'],
//         postcode: maps[index]['postcode'],
//         age: maps[index]['age'],
//         birthDate: maps[index]['date'],
//       );
//     });
//   }
// }
// /*
// class ApiService {
//   final String apiUrl = 'https://randomuser.me/api/';
//   int currentPage = 1;
//
//   Future<List<User>> fetchUsers({int results = 100}) async {
//     final response =
//         await http.get(Uri.parse('$apiUrl?page=$currentPage&results=$results'));
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> results = data['results'];
//
//       currentPage++; // Increment the page for the next request
//
//       return results.map((user) {
//         return User(
//           name: '${user['name']['first']} ${user['name']['last']}',
//           email: user['email'],
//           country: user['location']['country'],
//           registrationDate: user['registered']['date'],
//           userImage: user['picture']['thumbnail'],
//           city: user['location']['city'],
//           state: user['location']['state'],
//           postcode: (user['location']?['postcode'] ?? 0).toString(),
//           age: (user['dob']?['age'] ?? 0).toString(),
//           birthDate: user['dob']?['date'],
//         );
//       }).toList();
//     } else {
//       throw Exception('Failed to load users');
//     }
//   }
// }
//  */
//
//
// class MyApp extends StatelessWidget {
//   final apiService = ApiService();
//   final dbHelper = DatabaseHelper();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: UserListScreen(apiService: apiService, dbHelper: dbHelper),
//     );
//   }
// }
//
// class UserListScreen extends StatefulWidget {
//   final ApiService apiService;
//   final DatabaseHelper dbHelper;
//
//   UserListScreen({required this.apiService, required this.dbHelper});
//
//   @override
//   _UserListScreenState createState() => _UserListScreenState();
// }
//
// class _UserListScreenState extends State<UserListScreen> {
//   late Future<List<User>> usersFuture;
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     usersFuture = loadUsers();
//     _scrollController.addListener(_scrollListener);
//   }
//
//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       // Reached the end of the list, load more data
//       loadMoreUsers();
//     }
//   }
//
//   Future<void> loadMoreUsers() async {
//     final List<User> moreUsers = await widget.apiService.fetchUsers();
//     if (moreUsers.isNotEmpty) {
//       setState(() {
//         usersFuture =
//             usersFuture.then((existingUsers) => existingUsers + moreUsers);
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<List<User>> loadUsers() async {
//     final cachedUsers = await widget.dbHelper.getUsers();
//
//     if (cachedUsers.isNotEmpty) {
//       // If users are available in the local database, use them
//       return cachedUsers;
//     } else {
//       // Otherwise, fetch users from the API and save them to the local database
//       final users = await widget.apiService.fetchUsers();
//       users.forEach((user) async {
//         await widget.dbHelper.insertUser(user);
//       });
//       return users;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('User List')),
//       body: FutureBuilder<List<User>>(
//         future: usersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             print("Error: ${snapshot.error}");
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             final users = snapshot.data!;
//             return ListView.builder(
//               controller: _scrollController,
//               itemCount: users.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             UserDetailsScreen(user: users[index]),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     margin: const EdgeInsets.symmetric(
//                         vertical: 8.0, horizontal: 16.0),
//                     elevation: 2.0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 30.0,
//                             backgroundImage:
//                             NetworkImage(users[index].userImage ?? ""),
//                           ),
//                           const SizedBox(width: 16.0),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       users[index].name,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14.0,
//                                       ),
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           getFormattedDate(
//                                               dateTime: DateTime.parse(
//                                                   users[index]
//                                                       .registrationDate)),
//                                           style: const TextStyle(
//                                               color: Colors.grey, fontSize: 10),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const Icon(Icons.arrow_forward_ios,
//                                             size: 10, color: Colors.grey)
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 Text(users[index].email),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       "Country | ",
//                                       style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       users[index].country,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
//   static String getFormattedDate({required DateTime dateTime}) {
//     final DateFormat _formatter = DateFormat.yMMMMd();
//     return _formatter.format(dateTime);
//   }
// }
//
// class UserDetailsScreen extends StatelessWidget {
//   final User user;
//
//   UserDetailsScreen({required this.user});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(user.name), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Stack(
//                 children: [
//                   Container(
//                     height: 100,
//                     width: 100,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(8.0),
//                       image: DecorationImage(
//                         image: NetworkImage(user.userImage ?? ""),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       height: 20,
//                       width: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.yellow.shade600,
//                       ),
//                       child: Center(
//                         child: Text(
//                           user.age ?? "",
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8.0),
//             const Divider(height: 2, color: Colors.grey, thickness: 2.0),
//             const SizedBox(height: 8.0),
//             const Text(
//               "Email:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(user.email),
//             const SizedBox(height: 8.0),
//             const Text(
//               "Date Joined:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               getFormattedDate(dateTime: DateTime.parse(user.registrationDate)),
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8.0),
//             const Text(
//               "DOB:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               getFormattedDate(dateTime: DateTime.parse(user.birthDate ?? "")),
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8.0),
//             const Divider(height: 2, color: Colors.grey, thickness: 2.0),
//             const SizedBox(height: 8.0),
//             const Text(
//               "City:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(user.city),
//             const SizedBox(height: 8.0),
//             const Text(
//               "State:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(user.state),
//             const SizedBox(height: 8.0),
//             const Text(
//               "Country:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(user.country),
//             const SizedBox(height: 8.0),
//             const Text(
//               "Postcode:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(user.postcode ?? ""),
//           ],
//         ),
//       ),
//     );
//   }
//
//   static String getFormattedDate({required DateTime dateTime}) {
//     final DateFormat _formatter = DateFormat.yMMMMd();
//     return _formatter.format(dateTime);
//   }
// }