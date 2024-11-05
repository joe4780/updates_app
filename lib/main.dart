import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/results_page.dart'; // Ensure this imports the correct results page
// Import the HistoryPage

void main() {
  runApp(const UpdatesApp());
}

class UpdatesApp extends StatelessWidget {
  const UpdatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorldSkills Updates',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A4B8E),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 18),
                  ),
                  Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      _toggleDarkMode();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor:
                  _isDarkMode ? Colors.black : const Color(0xFF1A4B8E),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double currentHeight = constraints.biggest.height;
                  final double expandRatio =
                      ((currentHeight - kToolbarHeight - 48) /
                              (120.0 - kToolbarHeight - 48))
                          .clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: Opacity(
                      opacity: 1.0,
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/logo.png',
                          height: 30 + (expandRatio * 30),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _openSettings(context),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(text: 'News'),
                    Tab(text: 'Results'),
                    Tab(text: 'History'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Color.fromARGB(179, 253, 253, 253),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            NewsPage(),
            const ResultsPage(),
            HistoryPage(),
          ],
        ),
      ),
      backgroundColor:
          _isDarkMode ? const Color.fromARGB(255, 41, 39, 39) : Colors.white,
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsData = [];

  @override
  void initState() {
    super.initState();
    loadNewsData();
  }

  Future<void> loadNewsData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/news.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        newsData = data['news'];
      });
    } catch (e) {
      print("Error loading news data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return newsData.isNotEmpty
        ? ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: newsData.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFE5E5E5),
            ),
            itemBuilder: (context, index) {
              var newsItem = newsData[index];
              return NewsCard(newsItem: newsItem);
            },
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> newsItem;

  const NewsCard({Key? key, required this.newsItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(newsItem: newsItem),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                newsItem['image_url'] ?? 'assets/placeholder.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsItem['headline'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    newsItem['content'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailPage({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'News Detail',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              newsItem['image_url'] ?? 'assets/placeholder.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsItem['headline'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    newsItem['content'] ?? newsItem['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistoryData();
  }

  Future<void> loadHistoryData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/history.json');
      final data = json.decode(response);
      setState(() {
        historyData = data['events'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error loading history data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Continuous vertical line
                  Positioned(
                    left: 35, // Adjust this value to align with dots
                    top: 40, // Start from below first dot
                    bottom: 24, // End before last dot
                    child: Container(
                      width: 2,
                      color: const Color(0xFF003B5C),
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      var event = historyData[index];
                      return HistoryEvent(
                        event: event,
                        isActive: index == 1,
                        isLast: index == historyData.length - 1,
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class HistoryEvent extends StatelessWidget {
  final dynamic event;
  final bool isActive;
  final bool isLast;

  const HistoryEvent({
    Key? key,
    required this.event,
    this.isActive = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 24,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF003B5C) : Colors.white,
                border: Border.all(
                  color: const Color(0xFF003B5C),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['date'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF003B5C),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF003B5C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event['image'] != null)
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 16),
                        child: Image.asset(
                          event['image'],
                          height: 80,
                          fit: BoxFit.contain,
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        event['content'] ?? '',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
