import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/core.dart';
import '../api/http.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.username});
  final String username;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  String? error;
  UserResponse? user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final coreApi = Provider.of<CoreApi>(context, listen: false);
      final fetchedUser = await coreApi.getUser(widget.username);
      setState(() {
        isLoading = false;
        user = fetchedUser;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: isLoading
          ? const Center(
              child: Text("Loading..."),
            )
          : user == null || error != null
              ? Center(
                  child: Text(error ?? "User not found"),
                )
              : Center(
                  child: Text(user!.publicKey),
                ),
    );
  }
}
