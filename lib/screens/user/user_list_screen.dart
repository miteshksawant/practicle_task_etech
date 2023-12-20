import 'package:flutter/material.dart';
import 'package:flutter_practical_task_etech/api/api.dart';
import 'package:flutter_practical_task_etech/main.dart';
import 'package:flutter_practical_task_etech/screens/user/controller/user_controller.dart';
import 'package:flutter_practical_task_etech/screens/user/model/user_model.dart';
import 'package:flutter_practical_task_etech/screens/user/user_detail_screen.dart';
import 'package:flutter_practical_task_etech/usage/app_comman.dart';
import 'package:get/get.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserController userController = Get.put(UserController());

  late Future<List<User>> usersFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    usersFuture = loadUsers();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the end of the list, load more data
      loadMoreUsers();
    }
  }

  Future<void> loadMoreUsers() async {
    final List<User> moreUsers = await ApiService.fetchUsers();
    if (moreUsers.isNotEmpty) {
      setState(() {
        usersFuture =
            usersFuture.then((existingUsers) => existingUsers + moreUsers);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<User>> loadUsers() async {
    final cachedUsers = await userController.getUsers();

    if (cachedUsers.isNotEmpty) {
      return cachedUsers;
    } else {
      final users = await ApiService.fetchUsers();
      users.forEach((user) async {
        await userController.insertUser(user);
      });
      return users;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFF34A853)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<User>>(
          future: usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text(
                'Something went wrong please try again..',
                style: TextStyle(color: Colors.white),
              ));
            } else {
              final users = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailScreen(user: users[index]),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30.0,
                              backgroundImage:
                                  NetworkImage(users[index].userImage ?? ""),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        users[index].name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            AppComman.getFormattedDate(
                                                dateTime: DateTime.parse(
                                                    users[index]
                                                        .registrationDate)),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Icon(Icons.arrow_forward_ios,
                                              size: 10, color: Colors.grey)
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(users[index].email),
                                  Row(
                                    children: [
                                      const Text(
                                        "Country | ",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        users[index].country,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
