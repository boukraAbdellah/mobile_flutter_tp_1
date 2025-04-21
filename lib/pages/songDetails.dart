import 'package:flutter/material.dart';

class SongDetails extends StatelessWidget {
  final Map<String, String> song;

  const SongDetails({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Center(
              child: Text(
                song['title'] ?? 'Unknown Title',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Description header
            Row(
              children: [
                Icon(Icons.description, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description content
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                song['description'] ?? 'No description available',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),

          
          ],
        ),
      ),
    );
  }
}
