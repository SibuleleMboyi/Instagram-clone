import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';

class ProfileScreen extends StatefulWidget {

  final String userId;

  ProfileScreen({
    this.userId
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {

          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          User user  = User.fromDoc(snapshot.data);
          //print(user.email);

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: user.profileImageUrl.isEmpty 
                          ? AssetImage('assets/images/user_placeholder.png') 
                          : CachedNetworkImageProvider(user.profileImageUrl),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '12',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'posts',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  Text(
                                    '386',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'followers',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),


                              Column(
                                children: [
                                  Text(
                                    '345',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'following',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            width: 200.0,
                            child: FlatButton(
                              color: Colors.blue,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    user: user,
                                    updateUser: (User updateUser){
                                      //Trigger state rebuild after editing profile

                                      setState(() {
                                        user = updateUser;
                                      });
                                    },

                                  ))),
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      height: 80.0,
                      child: Text(
                        user.bio,
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ],


                ),
              ),
            ],
          );
        },
      ),
    );

  }
}
