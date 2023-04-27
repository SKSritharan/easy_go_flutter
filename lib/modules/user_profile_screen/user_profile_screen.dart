import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/user_profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: FutureBuilder(
        future: controller.getProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(snapshot.data!['name']),
                    Text(snapshot.data!['email']),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('No profile data found'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ),
    );
  }
}
