import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../model/user.dart';
import '../../widgets/chat_user_card.dart';
import '../../widgets/profile_image.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: FocusScope.of(context).unfocus,
      child: PopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        canPop: false,
        onPopInvoked: (_) {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
            return;
          }

          // some delay before pop
          Future.delayed(
              const Duration(milliseconds: 300), SystemNavigator.pop);
        },

        //
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          //app bar
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            //view profile
            leading: IconButton(
              tooltip: 'View Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: APIs.me),
                  ),
                );
              },
              icon: const ProfileImage(size: 32),
            ),

            //title
            title: _isSearching
                ? TextField(
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search using username...',
                    ),
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();

                      val = val.toLowerCase();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val) ||
                            i.email.toLowerCase().contains(val)) {
                          _searchList.add(i);
                        }
                      }
                      setState(() => _searchList);
                    },
                  )
                : Text(
                    'Jibber',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lobster',
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
            actions: [
              //search user button
              IconButton(
                tooltip: 'Search',
                onPressed: () => setState(() => _isSearching = !_isSearching),
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _showAddChatUserBottomSheet,
              child: Icon(
                CupertinoIcons.person_add,
                size: 25,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          //body
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showAddChatUserBottomSheet() {
    String email = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                24, // Adjust for keyboard
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with animated icon
              Text(
                'Add a New Friend',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Username input field
              TextFormField(
                onChanged: (value) => email = value,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: Icon(
                    Icons.person_add_alt_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 28,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Add button with gradient styling
              Center(
                child: SizedBox(
                  width: 200,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .transparent, // Make button background transparent
                        shadowColor: Colors.transparent, // Remove any shadow
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        if (email.trim().isNotEmpty) {
                          await APIs.addChatUser(email).then(
                            (value) {
                              if (!value) {
                                Dialogs.showSnackbar(
                                    context, 'User does not exist!');
                              }
                            },
                          );
                        }
                      },
                      child: Text(
                        'Send Invite',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
