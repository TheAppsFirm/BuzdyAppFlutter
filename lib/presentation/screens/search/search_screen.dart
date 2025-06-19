import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/search_view_model.dart';
import '../dashboard/feed/model/youtubeModel.dart';
import 'models/news_article.dart';
import 'article_webview.dart';
import '../dashboard/feed/videoplayer.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  /// [query] is kept for backward compatibility if callers use `query:`
  const SearchScreen({super.key, String? initialQuery, String? query})
      : initialQuery = initialQuery ?? query ?? '';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final TextEditingController _searchController = TextEditingController();
  late SearchViewModel _viewModel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _viewModel = SearchViewModel();
    _searchController.text = widget.initialQuery;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.initialQuery.isNotEmpty) {
      _viewModel.search(widget.initialQuery);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
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
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Videos'),
                  Tab(text: 'News'),
                ],
              ),
            ),
            body: Column(
              children: [
                if (vm.isLoading) const LinearProgressIndicator(),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      _buildVideos(vm.videoResults),
                      _buildNews(vm.newsResults),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
        final id = item.videoId ?? item.id ?? '';
        return ListTile(
          leading: thumb != null
              ? Image.network(thumb, width: 80, fit: BoxFit.cover)
              : null,
          title: Text(item.snippet?.title ?? ''),
          subtitle: Text(item.snippet?.channelTitle ?? ''),
          onTap: id.isEmpty
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        videoId: id,
                        videoTitle: item.snippet?.title,
                      ),
                    ),
                  );
                },
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArticleWebView(url: item.url),
              ),
            );
          },
        );
      },
    );
  }

  // Future extension: add web results list
}
