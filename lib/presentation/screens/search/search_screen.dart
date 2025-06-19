import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/search_view_model.dart';
import '../dashboard/feed/model/youtubeModel.dart';
import 'models/google_result.dart';
import 'models/news_article.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: vm.search,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
              bottom: TabBar(
                controller: _controller,
                tabs: const [
                  Tab(text: 'Web'),
                  Tab(text: 'Videos'),
                  Tab(text: 'News'),
                ],
              ),
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _controller,
                    children: [
                      _buildWeb(vm.webResults),
                      _buildVideos(vm.videoResults),
                      _buildNews(vm.newsResults),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildWeb(List<GoogleResult> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No results'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: item.imageUrl != null
              ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
              : null,
          title: Text(item.title),
          subtitle: Text(item.snippet),
          onTap: () {
            // open link using url_launcher if available
          },
        );
      },
    );
  }

  Widget _buildVideos(List<Item> videos) {
    if (videos.isEmpty) {
      return const Center(child: Text('No videos'));
    }
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final item = videos[index];
        final thumb = item.snippet?.thumbnails?.thumbnailsDefault?.url;
        return ListTile(
          leading: thumb != null
              ? Image.network(thumb, width: 80, fit: BoxFit.cover)
              : null,
          title: Text(item.snippet?.title ?? ''),
          subtitle: Text(item.snippet?.channelTitle ?? ''),
        );
      },
    );
  }

  Widget _buildNews(List<NewsArticle> news) {
    if (news.isEmpty) {
      return const Center(child: Text('No news'));
    }
    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        final item = news[index];
        return ListTile(
          leading: item.imageUrl != null
              ? Image.network(item.imageUrl!, width: 80, fit: BoxFit.cover)
              : null,
          title: Text(item.title),
          subtitle: Text(item.source ?? ''),
        );
      },
    );
  }
}
