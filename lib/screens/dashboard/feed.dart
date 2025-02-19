import 'package:buzdy/views/appBar.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/customText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For `Get.height` and `Get.width`

class FeedScreen extends StatefulWidget {
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Map<String, String>> shorts = [
    {
      'title': 'Funny Cat',
      'thumbnail':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlEa6Ty0wiEHrjkwE6W3obXmwaRaM07zVMGg&s'
    },
    {
      'title': 'Travel Vlog',
      'thumbnail':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlEa6Ty0wiEHrjkwE6W3obXmwaRaM07zVMGg&s'
    },
    {
      'title': 'Dance Moves',
      'thumbnail':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlEa6Ty0wiEHrjkwE6W3obXmwaRaM07zVMGg&s'
    },
    {
      'title': 'Cooking Tips',
      'thumbnail':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlEa6Ty0wiEHrjkwE6W3obXmwaRaM07zVMGg&s'
    },
  ];

  final List<Map<String, String>> videos = [
    {
      'title': 'Flutter Widgets - Full Course',
      'thumbnail':
          'https://d3jmn01ri1fzgl.cloudfront.net/photoadking/webp_thumbnail/kournikova-music-youtube-thumbnail-template-qupwp991d44dd5.webp',
      'channel': 'Code Academy',
      'views': '1.2M views',
      'time': '2 days ago',
    },
    {
      'title': 'Building Responsive Apps',
      'thumbnail':
          'https://d3jmn01ri1fzgl.cloudfront.net/photoadking/webp_thumbnail/kournikova-music-youtube-thumbnail-template-qupwp991d44dd5.webp',
      'channel': 'Dev Tutorials',
      'views': '856K views',
      'time': '1 week ago',
    },
    {
      'title': 'State Management in Flutter',
      'thumbnail':
          'https://d3jmn01ri1fzgl.cloudfront.net/photoadking/webp_thumbnail/kournikova-music-youtube-thumbnail-template-qupwp991d44dd5.webp',
      'channel': 'Flutter Devs',
      'views': '500K views',
      'time': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: appBarrWitoutAction(
          title: "Feed", leadingWidget: Container(), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shorts Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: kText(
                text: "Shorts",
                fWeight: FontWeight.bold,
                fSize: 18.0,
              ),
            ),
            SizedBox(
              height: Get.height / 3.5,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: shorts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        // Short Thumbnail
                        Container(
                          width: Get.width / 2.5,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlEa6Ty0wiEHrjkwE6W3obXmwaRaM07zVMGg&s"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Short Title Overlay
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            child: kText(
                              text: shorts[index]['title']!,
                              fWeight: FontWeight.w600,
                              fSize: 12.0,
                              tColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.grey[400], thickness: 1),

            // Videos Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: kText(
                text: "Videos",
                fWeight: FontWeight.bold,
                fSize: 18.0,
              ),
            ),
            Column(
              children: List.generate(videos.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: Image.network(
                            videos[index]['thumbnail']!,
                            height: Get.height / 4,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Video Info
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Channel Icon
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: appblueColor,
                              ),
                              const SizedBox(width: 10),
                              // Video Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    kText(
                                      text: videos[index]['title']!,
                                      fWeight: FontWeight.bold,
                                      fSize: 14.0,
                                    ),
                                    const SizedBox(height: 5),
                                    kText(
                                      text:
                                          '${videos[index]['channel']} • ${videos[index]['views']} • ${videos[index]['time']}',
                                      fWeight: FontWeight.w400,
                                      fSize: 12.0,
                                      tColor: const Color.fromARGB(
                                          255, 117, 117, 117),
                                    ),
                                  ],
                                ),
                              ),
                              // More Options Icon
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
