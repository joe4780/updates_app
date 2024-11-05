import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoryPage extends StatefulWidget {
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
          await rootBundle.loadString('assets/history.json');
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
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text('History'),
          ],
        ),
        backgroundColor: const Color(0xFF003B5C),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : historyData.isEmpty
                ? const Center(child: Text('No history data available'))
                : ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      return TimelineItem(
                        event: historyData[index],
                        isLast: index == historyData.length - 1,
                      );
                    },
                  ),
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isLast;

  const TimelineItem({
    Key? key,
    required this.event,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isUpcomingEvent(event['date'])
                        ? Colors.white
                        : const Color(0xFF003B5C),
                    border: Border.all(
                      color: const Color(0xFF003B5C),
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFF003B5C),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['date'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003B5C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003B5C),
                  ),
                ),
                const SizedBox(height: 12),
                if (event['image'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Image.asset(
                      event['image'],
                      height: 32,
                    ),
                  ),
                Text(
                  event['content'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isUpcomingEvent(String? date) {
    if (date == null) return false;
    try {
      // Check if the date contains a year
      final year = int.parse(date.split(RegExp(r'[- ]')).firstWhere(
            (element) => element.length == 4,
            orElse: () => '0',
          ));
      return year >= DateTime.now().year;
    } catch (e) {
      return false;
    }
  }
}
