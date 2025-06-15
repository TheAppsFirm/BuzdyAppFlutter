import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:buzdy/services/video_downloader.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String? videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    this.videoTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  Future<void> _shareVideo() async {
    final videoUrl = 'https://www.youtube.com/watch?v=${widget.videoId}';
    final title = widget.videoTitle ?? 'Check out this video';

    final params = ShareParams(
      text: '$title\n$videoUrl',
      subject: title,
    );

    try {
      await SharePlus.instance.share(params);
    } catch (_) {
      EasyLoading.showError('Sharing not available');
    }
  }

  Future<void> _downloadVideo() async {
    final path = await VideoDownloader.download(widget.videoId);
    if (path != null) {
      EasyLoading.showSuccess('Video saved');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareVideo(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadVideo,
          ),
        ],
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}




// import 'package:buzdy/presentation/screens/dashboard/feed/model/youtubeModel.dart';
// import 'package:buzdy/presentation/screens/dashboard/feed/videoplayer.dart';
// import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
// import 'package:buzdy/presentation/widgets/appBar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({super.key});

//   @override
//   State<FeedScreen> createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {
//   late ScrollController _shortsScrollController;
//   late ScrollController _videosScrollController;

//   @override
//   void initState() {
//     super.initState();
//     final provider = Provider.of<UserViewModel>(context, listen: false);
//     provider.fetchYoutubeShorts();
//     provider.fetchYoutubeVideos();

//     _shortsScrollController = ScrollController();
//     _shortsScrollController.addListener(_onShortsScroll);

//     _videosScrollController = ScrollController();
//     _videosScrollController.addListener(_onVideosScroll);
//   }

//   void _onShortsScroll() {
//     final provider = Provider.of<UserViewModel>(context, listen: false);
//     if (_shortsScrollController.position.pixels >=
//             _shortsScrollController.position.maxScrollExtent - 100 &&
//         !provider.isFetchingShorts) {
//       provider.fetchYoutubeShorts();
//     }
//   }

//   void _onVideosScroll() {
//     final provider = Provider.of<UserViewModel>(context, listen: false);
//     if (_videosScrollController.position.pixels >=
//             _videosScrollController.position.maxScrollExtent - 100 &&
//         !provider.isFetchingVideos) {
//       provider.fetchYoutubeVideos();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: appBarrWitoutAction(
//           title: "Feed", leadingWidget: Container(), centerTitle: true),
//       body: Consumer<UserViewModel>(
//         builder: (context, provider, child) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// **YouTube Shorts Section**
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text("Shorts",
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ),
//               SizedBox(
//                 height: Get.height / 4,
//                 width: Get.width,
//                 child: ListView.builder(
//                   controller: _shortsScrollController,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: provider.youtubeShorts.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == provider.youtubeShorts.length) {
//                       return provider.isFetchingShorts
//                           ? Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Center(child: CircularProgressIndicator()),
//                             )
//                           : SizedBox();
//                     }
//                     var item = provider.youtubeShorts[index];
//                     return ShortsItem(item: item);
//                   },
//                 ),
//               ),

//               Divider(color: Colors.grey[400], thickness: 1),

//               /// **YouTube Videos Section**
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text("Videos",
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ),

//               Expanded(
//                 child: ListView.builder(
//                   controller: _videosScrollController,
//                   itemCount: provider.youtubeVideos.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == provider.youtubeVideos.length) {
//                       return provider.isFetchingVideos
//                           ? Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Center(child: CircularProgressIndicator()),
//                             )
//                           : SizedBox();
//                     }
//                     var item = provider.youtubeVideos[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       child: GestureDetector(
//                         onTap: () {
//                           Get.to(VideoPlayerScreen(
//                             videoId: item.id ?? "",
//                           ));
//                         },
//                         child: Card(
//                           elevation: 2,
//                           margin: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(10)),
//                                 child: Image.network(
//                                   "",
//                                   height: Get.height / 4,
//                                   width: double.infinity,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 20,
//                                       backgroundColor: Colors.red,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const SizedBox(height: 5),
//                                           Text(
//                                             "video",
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           const SizedBox(height: 5),
//                                           Text(
//                                             '',
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.grey[600]),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const Padding(
//                                       padding: EdgeInsets.only(top: 8.0),
//                                       child: Icon(Icons.more_vert),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class ShortsItem extends StatelessWidget {
//   final Item item;
//   ShortsItem({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(VideoPlayerScreen(videoId: item.id ?? ""));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 5),
//         width: Get.width / 3,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           image: DecorationImage(
//             image: NetworkImage(item.snippet?.thumbnails?.medium?.url ?? ""),
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class VideoItem extends StatelessWidget {
//   final Item item;
//   VideoItem({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(item.snippet?.title ?? ""),
//       leading: Image.network(item.snippet?.thumbnails?.high?.url ?? ""),
//     );
//   }
// }




// shorts widget
  //  Padding(
  //                 padding: const EdgeInsets.all(4.0),
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     Get.to(VideoPlayerScreen(
  //                         videoId: youtubePlaylists[index]['videoId']));
  //                   },
  //                   child: Container(
  //                     margin: EdgeInsets.symmetric(vertical: 5),
  //                     width: Get.width / 3,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(15),
  //                       image: DecorationImage(
  //                         image: NetworkImage(
  //                             youtubePlaylists[index]['thumbnail']),
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                     child: Align(
  //                       alignment: Alignment.bottomLeft,
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                             color: Colors.black.withOpacity(0.5),
  //                             borderRadius: BorderRadius.only(
  //                                 bottomLeft: Radius.circular(15),
  //                                 bottomRight: Radius.circular(15))),
  //                         padding: EdgeInsets.all(8),
  //                         child: Text(
  //                           youtubePlaylists[index]['title'],
  //                           style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               );
             

//video widget

                //   Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 10),
                //   child: GestureDetector(
                //     onTap: () {
                //       Get.to(VideoPlayerScreen(
                //           videoId: youtubeVideos[index]['videoId']));
                //     },
                //     child: Card(
                //       elevation: 2,
                //       margin: const EdgeInsets.symmetric(horizontal: 10),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           ClipRRect(
                //             borderRadius: const BorderRadius.vertical(
                //                 top: Radius.circular(10)),
                //             child: Image.network(
                //               youtubeVideos[index]['thumbnail'],
                //               height: Get.height / 4,
                //               width: double.infinity,
                //               fit: BoxFit.cover,
                //             ),
                //           ),
                //           Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Row(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 CircleAvatar(
                //                   radius: 20,
                //                   backgroundColor: Colors.red,
                //                 ),
                //                 const SizedBox(width: 10),
                //                 Expanded(
                //                   child: Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       const SizedBox(height: 5),
                //                       Text(
                //                         youtubeVideos[index]['title'],
                //                         style: TextStyle(
                //                             fontSize: 14,
                //                             fontWeight: FontWeight.bold),
                //                       ),
                //                       const SizedBox(height: 5),
                //                       Text(
                //                         '${youtubeVideos[index]['channel']} • ${youtubeVideos[index]['views']} • ${youtubeVideos[index]['time']}',
                //                         style: TextStyle(
                //                             fontSize: 12,
                //                             color: Colors.grey[600]),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 const Padding(
                //                   padding: EdgeInsets.only(top: 8.0),
                //                   child: Icon(Icons.more_vert),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // );
          