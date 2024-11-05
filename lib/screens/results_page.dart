import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                        _buildMedal(Colors.yellow[700]!),
                        _buildMedal(Colors.grey[400]!),
                        _buildMedal(Colors.brown[300]!),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                        ),
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

  Widget _buildMedal(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
          alignment: Alignment.centerLeft,
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
                    Colors.yellow[700]!),
                _buildMedalSection(
                    'Silver Medals',
                    competitors.where((c) => c.medalType == 'silver').toList(),
                    Colors.grey[400]!),
                _buildMedalSection(
                    'Bronze Medals',
                    competitors.where((c) => c.medalType == 'bronze').toList(),
                    Colors.brown[300]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalSection(
      String title, List<Competitor> competitors, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
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

class CompetitorCard extends StatelessWidget {
  final Competitor competitor;

  const CompetitorCard({
    Key? key,
    required this.competitor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: competitor.avatarPath.isNotEmpty
                  ? AssetImage(competitor.avatarPath)
                  : null,
              child: competitor.avatarPath.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              competitor.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              competitor.skillName,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
