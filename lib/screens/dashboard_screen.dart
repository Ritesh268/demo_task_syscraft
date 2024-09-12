import 'package:demo_task_syscraft/config/theme/app_colors.dart';
import 'package:demo_task_syscraft/config/theme/app_text_style.dart';
import 'package:demo_task_syscraft/constants/app_const_text.dart';
import 'package:demo_task_syscraft/screens/voice_to_text_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading = true;
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('client').get();
    setState(() {
      allUsers = snapshot.docs;
      filteredUsers = allUsers;
      isLoading = false;
    });
  }

  void _searchUsers(String query) {
    final filtered = allUsers.where((user) {
      final firstName = user['firstName'].toString().toLowerCase();
      final lastName = user['lastName'].toString().toLowerCase();
      final mobileNumber = user['mobile'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return firstName.contains(searchQuery) ||
          lastName.contains(searchQuery) ||
          mobileNumber.contains(searchQuery);
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstString.userList,
          style: AppTextStyle.black14W500,
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceToTextScreen(),
                  ));
            },
            child: Text(
              AppConstString.voiceToText,
              style: AppTextStyle.blueColor14W500,
            ),
          ),
          const Icon(
            Icons.speaker_phone,
            color: AppColors.txtColor,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: AppConstString.serachByName,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(child: Text(AppConstString.noUserFound))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person, size: 50),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${user['firstName']} ${user['lastName']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      user['mobile'],
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
