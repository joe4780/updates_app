import 'package:flutter/material.dart';

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
        title: const Text('Results'),
      ),
      body: Column(
        children: [
          // Country header
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
          // Competitors grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
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
  final String medalType; // 'gold', 'silver', 'bronze' or null

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
          children: [
            // Medal indicator if exists
            if (competitor.medalType != null)
              Align(
                alignment: Alignment.topRight,
                child: _buildMedalIcon(competitor.medalType),
              ),
            // Avatar
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
            const SizedBox(height: 12),
            // Name
            Text(
              competitor.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Skill name with marquee if needed
            Container(
              height: 20,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  competitor.skillName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalIcon(String medalType) {
    final Color medalColor = {
          'gold': Colors.yellow[700]!,
          'silver': Colors.grey[400]!,
          'bronze': Colors.brown[300]!,
        }[medalType] ??
        Colors.transparent;

    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: medalColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
