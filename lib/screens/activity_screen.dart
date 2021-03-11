import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/activity_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({ this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {

  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    List<Activity> activities = await DatabaseService.getActivities(widget.currentUserId);
    if(mounted){
      setState(() {
        _activities = activities;
      });
    }
  }

  _buildActivity(Activity activity){
    return FutureBuilder(
        future: DatabaseService.getUserWithId(activity.fromUserId),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return SizedBox.shrink();
          }
          User user = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.grey,
              backgroundImage: user.profileImageUrl.isEmpty
                  ? AssetImage('assets/images/user_placeholder.png')
                  : CachedNetworkImageProvider(user.profileImageUrl),
            ),
           title: Row(
             children: [
               activity.comment != null
               ? Row(
                 children: [
                   Text(
                     '${user.name}',
                     style: TextStyle(
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                   Text(
                     ' commented "${activity.comment}"',
                   ),
                 ],
               )
               : Row(
                 children: [
                   Text(
                     '${user.name}',
                     style: TextStyle(
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                   Text(
                       ' liked your post '
                   ),
                 ],
               )
             ],
           ),

            subtitle: Text(
              DateFormat.yMd().add_jm().format(activity.timestamp.toDate()),
            ),
            trailing: activity.postImageUrl != null
                ? CachedNetworkImage(
              imageUrl: activity.postImageUrl,
              height: 40.0,
              width: 40.0,
              fit: BoxFit.cover,
            ) : Container(),
            onTap: () async{
              String currentUserId = Provider.of<UserData>(context).currentUserId;
              Post post = await DatabaseService.getUserPost(currentUserId, activity.postId);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CommentsScreen(
                  post: post,
                  likeCount: post.likeCount,
                ),
                ),
              );
            },
          );

    });
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
      body: RefreshIndicator(
        onRefresh: () =>  _setupActivities(),
        child: ListView.builder(
            itemCount: _activities.length,
            itemBuilder: (BuildContext context, int index){
          Activity activity = _activities[index];
          return _buildActivity(activity);
        }),
      )
    );
  }
}