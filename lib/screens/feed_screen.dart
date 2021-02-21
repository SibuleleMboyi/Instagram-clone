import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  _buildPost(Post post, User author){
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  currentUserId: widget.currentUserId,
                  userId: post.authorId,
                ),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: author.profileImageUrl.isEmpty
                      ? AssetImage('assets/images/user_placeholder.png')
                      : CachedNetworkImageProvider(author.profileImageUrl),
                ),
                SizedBox(width: 8.0),
                Text(
                  author.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(post.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    iconSize: 30.0,
                    onPressed: (){},
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    iconSize: 30.0,
                    onPressed: (){},
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                    '0 likes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 12.0,
                      right: 6.0,
                    ),
                    child: Text(
                      author.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    post.caption,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 12.0),
            ],
          ),
        ),
      ],
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
      body: StreamBuilder(
        stream: DatabaseService.getFeedPosts(widget.currentUserId),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return SizedBox.shrink();
          }
          final List<Post> posts = snapshot.data;
          return ListView.builder(
              itemCount : posts.length,
              itemBuilder: (BuildContext context, int index){
                Post post = posts[index];
                return FutureBuilder(
                  future: DatabaseService.getUserWithId(post.authorId),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    if(!snapshot.hasData){
                      return SizedBox.shrink();
                    }
                    User author = snapshot.data;
                    return _buildPost(post, author);
                  },
                );
              }
          );
        },
      )
    );
  }
}
