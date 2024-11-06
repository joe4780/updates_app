import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/results_page.dart';

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
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor:
                  _isDarkMode ? Colors.black : const Color(0xFF3949AB),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double currentHeight = constraints.biggest.height;
                  final double expandRatio =
                      ((currentHeight - kToolbarHeight - 48) /
                              (200.0 - kToolbarHeight - 48))
                          .clamp(0.0, 1.0);

                  return Stack(
                    children: [
                      Positioned(
                        bottom: 48, // Height of the tab bar
                        left: 0,
                        right: 0,
                        child: Container(
                          height: expandRatio > 0.5 ? 100 : 50, // Logo height
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => _openSettings(context),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  height: 48,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white24,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3.0,
                    tabs: const [
                      Tab(text: 'News'),
                      Tab(text: 'Results'),
                      Tab(text: 'History'),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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

class NewsDetailPage extends StatefulWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailPage({super.key, required this.newsItem});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _animateIcon() {
    setState(() {
      isLiked = !isLiked;
    });
    _controller.forward(from: 0.0).then((_) {
      _controller.reverse().then((_) {
        _controller.forward().then((_) {
          _controller.reverse();
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'News',
                style: GoogleFonts.poppins(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.newsItem['title'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.newsItem['headline'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                widget.newsItem['image_url'] ?? 'assets/placeholder.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              if (widget.newsItem['content'] != null)
                Text(
                  widget.newsItem['content'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              if (widget.newsItem['impact_statements'] != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Our Impact Statements:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                ...(widget.newsItem['impact_statements'] as List)
                    .map((statement) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                              Expanded(
                                child: Text(
                                  statement,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _animateIcon,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 0.2,
                        child: Icon(
                          Icons.thumb_up,
                          size: 32,
                          color: isLiked ? Colors.blue : Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
