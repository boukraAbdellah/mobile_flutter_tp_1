import 'package:flutter/material.dart';
import 'home.dart'; // Import the global favorites list
import 'DetailsPage.dart'; // Import the DetailsPage
import 'songDetails.dart'; // Import the SongDetails widget
import 'package:tp_1/database_helper.dart'; // Add this import

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance; // Add this line
  int? selectedSongIndex;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : isLandscape
              // Horizontal
              ? Row(
                  children: [
                    // Left side: favorites song
                    Expanded(
                      flex: 2,
                      child: _buildSongsList(),
                    ),
                    // Vertical divider
                    Container(
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    // Right side
                    Expanded(
                      flex: 3,
                      child: selectedSongIndex != null
                          ? SongDetails(song: favoriteSongs[selectedSongIndex!])
                          : const Center(
                              child: Text(
                                'Select a song to view details',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                    ),
                  ],
                )
              // Portrait layout with full-width list
              : _buildSongsList(),
    );
  }

  Widget _buildSongsList() {
    return ListView.builder(
      itemCount: favoriteSongs.length,
      itemBuilder: (context, index) {
        final song = favoriteSongs[index];
        final isSelected = selectedSongIndex == index;
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        return ListTile(
          title: Text(
            song['title'] ?? 'Unknown Title',
            style: TextStyle(
              fontWeight: isSelected && isLandscape
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected && isLandscape ? Colors.blue : Colors.black,
            ),
          ),
          subtitle: Text(song['artist'] ?? 'Unknown Artist'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show info button in portrait mode
              if (!isLandscape)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(song: song),
                      ),
                    );
                  },
                ),
              // Remove from favorites button
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () async {
                  await removeFromDatabase(song);
                  setState(() {
                    favoriteSongs.removeAt(index);
                    if (selectedSongIndex == index) {
                      selectedSongIndex = null;
                    } else if (selectedSongIndex != null &&
                        selectedSongIndex! > index) {
                      selectedSongIndex = selectedSongIndex! - 1;
                    }
                  });
                },
              ),
            ],
          ),
          onTap: () {
            if (isLandscape) {
              // In landscape, select the song to show details on the right
              setState(() {
                selectedSongIndex = index;
              });
            } else {
              // In portrait, navigate to details page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(song: song),
                ),
              );
            }
          },
          // Highlight selected item in landscape mode
          tileColor:
              isSelected && isLandscape ? Colors.blue.withOpacity(0.1) : null,
        );
      },
    );
  }

  // Add this method to handle database deletion
  Future<void> removeFromDatabase(Map<String, String> song) async {
    // Find the song ID in the database
    final allFavs = await databaseHelper.queryAllRows();
    for (var row in allFavs) {
      if (row[DatabaseHelper.columnTitle] == song['title'] && 
          row[DatabaseHelper.columnArtist] == song['artist']) {
        await databaseHelper.delete(row[DatabaseHelper.columnId]);
        break;
      }
    }
  }
}
