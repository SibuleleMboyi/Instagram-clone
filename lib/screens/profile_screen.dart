import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/widgets/post_view.dart';
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

  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  User _profileUser;


  void initState(){
    super.initState();
    _setUpIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
  }

  _setUpIsFollowing() async{
    bool isFollowingUser = await DatabaseService.isFollowingUser( currentUserId:  widget.currentUserId, userId:  widget.userId);
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async{
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followerCount = userFollowerCount;
    });
  }

  _setupFollowing() async{
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

  _setupPosts() async{
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async{
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _followOrUnfollow(){
    if(_isFollowing){
      _unfollowUser();
    } else{
      _followUser();
    }
  }

  _unfollowUser(){
    DatabaseService.unfollowUser(currentUserId: widget.currentUserId, userId: widget.userId);

    setState(() {
      _isFollowing = false;
      _followerCount-- ;
    });
  }

  _followUser(){
    DatabaseService.followUser(currentUserId: widget.currentUserId, userId: widget.userId);

    setState(() {
      _isFollowing = true;
      _followerCount++ ;
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
        color: _isFollowing ? Colors.grey[200] : Colors.blue,
        textColor: _isFollowing ? Colors.black : Colors.white,
        onPressed: _followOrUnfollow,
        child: Text(
          _isFollowing ? 'Unfollow' : 'Follow',
          style: TextStyle(
              fontSize: 18.0, color: Colors.white),
        ),
      ),
    );

  }

  _buildProfileInfo(User user){
    return Column(
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
                              _posts.length.toString(),
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
                              _followerCount.toString(),
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
                              _followingCount.toString(),
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
  }

  _buildToggleButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30.0,
          color: _displayPosts == 0
              ? Theme.of(context).primaryColor : Colors.grey[300],
          onPressed: () => setState((){
            _displayPosts = 0;
          })
        ),
        IconButton(
            icon: Icon(Icons.list),
            iconSize: 30.0,
            color: _displayPosts == 1
                ? Theme.of(context).primaryColor : Colors.grey[300],
            onPressed: () => setState((){
              _displayPosts = 1;
            })
        )
      ],
    ) ;
  }

  _buildTilePost(Post post){
    return GridTile(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentsScreen(
              post: post,
              likeCount: post.likeCount,
            ),
          ),
        ),
        child: Image(
          image: CachedNetworkImageProvider(post.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _buildDisplayPosts(){
    if(_displayPosts == 0){
      // Grid
      List<GridTile> tiles = [];
      _posts.forEach(
              (post) => tiles.add(_buildTilePost(post))
      );
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: tiles,

      );

    }else{
      // Column
      List<PostView> postViews = [];
      _posts.forEach((post) {
        postViews.add(
          PostView(
            currentUserId: widget.currentUserId,
            post: post,
            author: _profileUser,
          ),
        );
      });
      return Column(
        children: postViews,

      );
    }
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
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: AuthService.logout
          ),
        ],
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

          return ListView(
            children: [
              _buildProfileInfo(user),
              _buildToggleButtons(),
              Divider(),
              _buildDisplayPosts(),
            ],
          );
        },
      ),
    );

  }
}
