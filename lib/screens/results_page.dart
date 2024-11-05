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
      resultsData = data['results'];
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
                    return ResultCard(
                      country: result['country'],
                      rank: result['rank'],
                      flagAssetPath: result['flag_image_url'],
                      medals: _getMedalCounts(index),
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

  // Mock medal counts based on rank
  Map<String, int> _getMedalCounts(int index) {
    if (index == 0) return {'gold': 7, 'silver': 6, 'bronze': 2, 'total': 26};
    if (index == 1) return {'gold': 5, 'silver': 5, 'bronze': 5, 'total': 23};
    if (index == 2) return {'gold': 3, 'silver': 5, 'bronze': 6, 'total': 27};
    if (index == 3) return {'gold': 3, 'silver': 5, 'bronze': 6, 'total': 13};
    if (index == 5) return {'gold': 3, 'silver': 4, 'bronze': 6, 'total': 20};
    if (index == 6) return {'gold': 3, 'silver': 3, 'bronze': 6, 'total': 25};
    if (index == 7) return {'gold': 0, 'silver': 5, 'bronze': 6, 'total': 24};
    if (index == 8) return {'gold': 0, 'silver': 2, 'bronze': 6, 'total': 12};
    if (index == 9) return {'gold': 0, 'silver': 5, 'bronze': 6, 'total': 11};
    if (index == 10) return {'gold': 0, 'silver': 5, 'bronze': 6, 'total': 10};
    if (index == 11) return {'gold': 0, 'silver': 5, 'bronze': 6, 'total': 11};
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
