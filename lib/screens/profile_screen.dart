import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {

  final String currentUserId;
  final String userId;


  ProfileScreen({
    this.currentUserId,
    this.userId,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  void initState(){
    super.initState();
    _setUpIsFollowing();
    _setupFollowers();
    _setupFollowing();
  }

  _setUpIsFollowing() async{
    bool isFollowingUser = await DatabaseService.isFollowingUser( currentUserId:  widget.currentUserId, userId:  widget.userId);
    setState(() {
      isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async{
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      followerCount = userFollowerCount;
    });
  }

  _setupFollowing() async{
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      followingCount = userFollowingCount;
    });
  }

  _followOrUnfollow(){
    if(isFollowing){
      _unfollowUser();
    } else{
      _followUser();
    }
  }

  _unfollowUser(){
    DatabaseService.unfollowUser(currentUserId: widget.currentUserId, userId: widget.userId);

    setState(() {
      isFollowing = false;
      followerCount -- ;
    });
  }

  _followUser(){
    DatabaseService.followUser(currentUserId: widget.currentUserId, userId: widget.userId);

    setState(() {
      isFollowing = true;
      followerCount ++ ;
    });
  }

  _displayButton(User user){
    return  user.id == Provider.of<UserData>(context).currentUserId
        ? Container(
      width: 200.0,
      child: FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
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
    )
    :Container(
      width: 200.0,
      child: FlatButton(
        color: isFollowing ? Colors.grey[200] : Colors.blue,
        textColor: isFollowing ? Colors.black : Colors.white,
        onPressed: _followOrUnfollow,
        child: Text(
          isFollowing ? 'Unfollow' : 'Follow',
          style: TextStyle(
              fontSize: 18.0, color: Colors.white),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Instagram',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Billabong',
              fontSize: 35.0,
            ),
          ),
        ),
      ),

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
                                    followerCount.toString(),
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
                                    followingCount.toString(),
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
                          _displayButton(user),
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
