import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<dynamic> resultsData = [];

  @override
  void initState() {
    super.initState();
    loadResultsData();
  }

  Future<void> loadResultsData() async {
    final String response =
        await rootBundle.loadString('assets/data/results.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      resultsData =
          data['results'] ?? []; // Use an empty list if 'results' is null
    });
  }

  @override
  Widget build(BuildContext context) {
    return resultsData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text(
                      'Mock data',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildMedalIcon(Colors.yellow[700]!,
                            FontAwesomeIcons.medal), // Gold
                        _buildMedalIcon(Colors.grey[400]!,
                            FontAwesomeIcons.medal), // Silver
                        _buildMedalIcon(Colors.brown[300]!,
                            FontAwesomeIcons.medal), // Bronze
                        // You can remove the last Container if you want
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: resultsData.length,
                  itemBuilder: (context, index) {
                    final result = resultsData[index];
                    return GestureDetector(
                      onTap: () {
                        List<Competitor> competitors =
                            (result['competitors'] as List?)
                                    ?.map((c) => Competitor(
                                          name: c['name'],
                                          avatarPath: c['avatarPath'],
                                          skillName: c['skillName'],
                                          medalType: c['medalType'],
                                        ))
                                    .toList() ??
                                []; // Use empty list if competitors is null
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultDetailPage(
                              country: result['country'],
                              flagAssetPath: result['flag_image_url'],
                              competitors: competitors,
                            ),
                          ),
                        );
                      },
                      child: ResultCard(
                        country: result['country'],
                        rank: result['rank'],
                        flagAssetPath: result['flag_image_url'],
                        medals: _getMedalCounts(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildMedalIcon(Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        icon,
        color: color,
        size: 20, // Adjust size as needed
      ),
    );
  }

  Map<String, int> _getMedalCounts(int index) {
    if (index == 0) return {'gold': 7, 'silver': 6, 'bronze': 2, 'total': 26};
    if (index == 1) return {'gold': 5, 'silver': 5, 'bronze': 5, 'total': 23};
    if (index == 2) return {'gold': 3, 'silver': 5, 'bronze': 6, 'total': 27};
    return {'gold': 2, 'silver': 3, 'bronze': 4, 'total': 9};
  }
}

class ResultCard extends StatelessWidget {
  final String country;
  final int rank;
  final String flagAssetPath;
  final Map<String, int> medals;

  const ResultCard({
    Key? key,
    required this.country,
    required this.rank,
    required this.flagAssetPath,
    required this.medals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            flagAssetPath,
            width: 30,
            height: 20,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildMedalCount(medals['gold'] ?? 0),
              _buildMedalCount(medals['silver'] ?? 0),
              _buildMedalCount(medals['bronze'] ?? 0),
              const SizedBox(width: 8),
              Text(
                '${medals['total']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedalCount(int count) {
    return Container(
      width: 24,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        count.toString(),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class ResultDetailPage extends StatelessWidget {
  final String country;
  final String flagAssetPath;
  final List<Competitor> competitors;

  const ResultDetailPage({
    Key? key,
    required this.country,
    required this.flagAssetPath,
    required this.competitors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('Results'),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Column(
              children: [
                Image.asset(
                  flagAssetPath,
                  width: 60,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  country,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMedalSection(
                  'Gold Medals',
                  competitors.where((c) => c.medalType == 'gold').toList(),
                  Colors.yellow[700]!,
                  FontAwesomeIcons.medal,
                ),
                _buildMedalSection(
                  'Silver Medals',
                  competitors.where((c) => c.medalType == 'silver').toList(),
                  Colors.grey[400]!,
                  FontAwesomeIcons.medal,
                ),
                _buildMedalSection(
                  'Bronze Medals',
                  competitors.where((c) => c.medalType == 'bronze').toList(),
                  Colors.brown[300]!,
                  FontAwesomeIcons.medal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalSection(
      String title, List<Competitor> competitors, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the start
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8), // Space between icon and text
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.right, // Align text to the right
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                childAspectRatio: 0.75, // Adjust aspect ratio as needed
                crossAxisSpacing: 16.0, // Space between cards
                mainAxisSpacing: 16.0, // Space between rows
              ),
              padding: const EdgeInsets.all(16),
              itemCount: competitors.length,
              itemBuilder: (context, index) {
                return CompetitorCard(competitor: competitors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Competitor {
  final String name;
  final String avatarPath;
  final String skillName;
  final String medalType;

  const Competitor({
    required this.name,
    required this.avatarPath,
    required this.skillName,
    required this.medalType,
  });
}

class CompetitorsCarousel extends StatefulWidget {
  final List<Competitor> competitors;

  const CompetitorsCarousel({
    Key? key,
    required this.competitors,
  }) : super(key: key);

  @override
  State<CompetitorsCarousel> createState() => _CompetitorsCarouselState();
}

class _CompetitorsCarouselState extends State<CompetitorsCarousel> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.competitors.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // Add scaling animation for current card
              return AnimatedScale(
                scale: currentIndex == index ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 300),
                child: AnimatedOpacity(
                  opacity: currentIndex == index ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < 0 &&
                            currentIndex < widget.competitors.length - 1) {
                          // Swipe left to next
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else if (details.primaryVelocity! > 0 &&
                            currentIndex > 0) {
                          // Swipe right to previous
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child:
                          CompetitorCard(competitor: widget.competitors[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Add page indicator dots
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.competitors.length,
              (index) => Container(
                width: currentIndex == index ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: currentIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CompetitorCard extends StatelessWidget {
  final Competitor competitor;

  const CompetitorCard({
    Key? key,
    required this.competitor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: competitor.avatarPath.isNotEmpty
                  ? AssetImage(competitor.avatarPath)
                  : null,
              child: competitor.avatarPath.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              competitor.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              competitor.skillName,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
