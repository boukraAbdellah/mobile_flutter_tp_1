import 'package:flutter/material.dart';
import 'package:tp_1/pages/songDetails.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, String> song;

  const DetailsPage({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          song['title'] ?? 'Song Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SafeArea(
        child: SongDetails(song: song),
      ),
    );
  }
}
