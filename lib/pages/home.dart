import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tp_1/pages/favorites.dart';
import 'package:tp_1/main.dart';
import 'package:tp_1/database_helper.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quran Player',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Favorites()),
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SongPlayer(),
      ),
    );
  }
}

class SongPlayer extends StatefulWidget {
  const SongPlayer({super.key});

  @override
  State<SongPlayer> createState() => _SongPlayerState();
}

List<Map<String, String>> favoriteSongs = [];

class _SongPlayerState extends State<SongPlayer>
    with WidgetsBindingObserver, RouteAware {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int currentIndex = 0;
  Duration _duration = Duration.zero;
  bool isFavorite = false;

  final List<Map<String, String>> songs = [
    {
      'title': 'سورة العاديات',
      'artist': 'بدر التركي',
      'path': 'surah1.mp3',
      'description':
          'سورة العاديات هي السورة رقم 100 في القرآن الكريم، وهي من السور المكية. تحتوي على 11 آية وتتحدث عن الخيول المغيرة في ساحات القتال، وعن طبيعة الإنسان وحبه للمال، وعن البعث والحساب. تعتبر من السور القصيرة والقوية في معانيها.',
    },
    {
      'title': 'سورة القارعة',
      'artist': 'بدر التركي',
      'path': 'surah2.mp3',
      'description':
          'سورة القارعة هي السورة رقم 101 في القرآن الكريم، وهي من السور المكية. تتكون من 11 آية وتتحدث عن يوم القيامة ووصف أهواله. القارعة هي اسم من أسماء يوم القيامة، لأنها تقرع القلوب بالفزع والخوف.',
    },
    {
      'title': 'سورة النصر',
      'artist': 'بدر التركي',
      'path': 'surah3.mp3',
      'description':
          'سورة النصر هي السورة رقم 110 في القرآن الكريم، وهي من السور المدنية. تتكون من 3 آيات فقط وهي آخر سورة كاملة نزلت على النبي محمد ﷺ، وتعتبر من علامات قرب وفاته. تتحدث عن فتح مكة ودخول الناس في دين الله أفواجا.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPlayerComplete.listen((_) => playNext());
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });

    loadFavoritesFromDB();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (isPlaying) {
      _audioPlayer.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (isPlaying) {
        _audioPlayer.pause();
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (!isPlaying) {
        _audioPlayer.resume();
      }
    }
  }

  // this for router observer
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (isPlaying) {
      _audioPlayer.pause();
    }
  }

  @override
  void didPopNext() {
    if (!isPlaying) {
      _audioPlayer.resume();
    }
  }

  Future<void> playMusic() async {
    try {
      final currentSong = songs[currentIndex];
      final isLocalFile = currentSong['isLocal'] == 'true';

      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (isLocalFile) {
          // Play from device storage
          await _audioPlayer.play(DeviceFileSource(currentSong['path']!));
        } else {
          // Play from assets
          await _audioPlayer.play(AssetSource('audio/${currentSong['path']}'));
        }
      }
    } catch (e) {
      print('Playback error: $e');
    }
  }

  Future<void> playNext() async {
    await _audioPlayer.stop();
    setState(() {
      currentIndex = (currentIndex + 1) % songs.length;
    });
    updateFavoriteStatus();
    playMusic();
  }

  Future<void> playPrevious() async {
    await _audioPlayer.stop();
    setState(() {
      currentIndex = (currentIndex - 1 + songs.length) % songs.length;
    });
    updateFavoriteStatus();
    playMusic();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void updateFavoriteStatus() async {
    final currentSong = songs[currentIndex];
    // Check if the song exists in the database
    final allFavs = await databaseHelper.queryAllRows();
    final songExists = allFavs.any((row) =>
        row[DatabaseHelper.columnTitle] == currentSong['title'] &&
        row[DatabaseHelper.columnArtist] == currentSong['artist']);

    setState(() {
      isFavorite = songExists;
    });
  }

  Future<void> addToFavorites(Map<String, String> song) async {
    // Convert song map to database row format
    final row = {
      DatabaseHelper.columnTitle: song['title'],
      DatabaseHelper.columnArtist: song['artist'],
      DatabaseHelper.columnDescription:
          song['description'] ?? 'No description available',
    };

    await databaseHelper.insert(row);
    // Also update the in-memory list for immediate UI updates
    if (!favoriteSongs.contains(song)) {
      favoriteSongs.add(song);
    }
  }

  Future<void> removeFromFavorites(Map<String, String> song) async {
    // Find the song ID in the database
    final allFavs = await databaseHelper.queryAllRows();
    for (var row in allFavs) {
      if (row[DatabaseHelper.columnTitle] == song['title'] &&
          row[DatabaseHelper.columnArtist] == song['artist']) {
        await databaseHelper.delete(row[DatabaseHelper.columnId]);
        break;
      }
    }

    // Also update the in-memory list
    favoriteSongs.removeWhere((favSong) =>
        favSong['title'] == song['title'] &&
        favSong['artist'] == song['artist']);
  }

  Future<void> loadFavoritesFromDB() async {
    final allFavs = await databaseHelper.queryAllRows();
    final loadedFavs = <Map<String, String>>[];

    for (var row in allFavs) {
      loadedFavs.add({
        'title': row[DatabaseHelper.columnTitle],
        'artist': row[DatabaseHelper.columnArtist],
        'description': row[DatabaseHelper.columnDescription],
      });
    }

    setState(() {
      favoriteSongs = loadedFavs;
    });

    updateFavoriteStatus();
  }

  // Future<void> pickAudioFromDevice() async {
  //   // Request permissions
  //   var status = await Permission.storage.request();
  //   if (status.isGranted) {
  //     try {
  //       // Pick file
  //       FilePickerResult? result = await FilePicker.platform.pickFiles(
  //         type: FileType.audio,
  //       );

  //       if (result != null) {
  //         // Get file path
  //         String filePath = result.files.single.path!;
  //         String fileName = result.files.single.name;

  //         // Create a new song entry
  //         Map<String, String> newSong = {
  //           'title': fileName.replaceAll('.mp3', ''),
  //           'artist': 'Local Audio',
  //           'path': filePath,
  //           'description': 'Audio file from device',
  //           'isLocal': 'true', // Flag to identify device files
  //         };

  //         // Play the picked song
  //         await _audioPlayer.stop();

  //         setState(() {
  //           // Add to songs list if not already present
  //           bool exists = songs.any((song) => song['path'] == filePath);
  //           if (!exists) {
  //             songs.add(newSong);
  //           }

  //           // Find the index of the song in the list
  //           int index = songs.indexWhere((song) => song['path'] == filePath);
  //           if (index != -1) {
  //             currentIndex = index;
  //           }
  //         });

  //         // Play the file
  //         await playMusic();
  //       }
  //     } catch (e) {
  //       print('Error picking audio: $e');
  //     }
  //   } else {
  //     print('Permission denied');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final song = songs[currentIndex];
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Landscape layout
    if (isLandscape) {
      return Row(
        children: [
          // Left side - Song Image
          Expanded(
            flex: 1,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/musique.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Right side - Player Controls
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song['title']!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  song['artist']!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // Favorites row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Favorites()),
                        );
                      },
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 40,
                        ),
                        onPressed: () async {
                          final currentSong = songs[currentIndex];
                          if (isFavorite) {
                            await removeFromFavorites(currentSong);
                          } else {
                            await addToFavorites(currentSong);
                          }
                          updateFavoriteStatus();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add to Favorites',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Add this after the Favorites row in landscape layout
                // const SizedBox(height: 10),
                // ElevatedButton.icon(
                //   onPressed: pickAudioFromDevice,
                //   icon: const Icon(Icons.add, color: Colors.white),
                //   label: const Text('Add Audio',
                //       style: TextStyle(color: Colors.white)),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 20, vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //   ),
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 40),
                      onPressed: playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          size: 60),
                      onPressed: playMusic,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 40),
                      onPressed: playNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Portrait layout (unchanged)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: 220,
          width: 220,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/musique.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          song['title']!,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          song['artist']!,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(formatTime(_position)),
              // Text(formatTime(_duration)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Favorites()),
                );
              },
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 40,
                ),
                onPressed: () async {
                  final currentSong = songs[currentIndex];
                  if (isFavorite) {
                    await removeFromFavorites(currentSong);
                  } else {
                    await addToFavorites(currentSong);
                  }
                  updateFavoriteStatus();
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Add to Favorites',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 40),
              onPressed: playPrevious,
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 60),
              onPressed: playMusic,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, size: 40),
              onPressed: playNext,
            ),
          ],
        ),
        // Add this after the player controls row in portrait layout
        // const SizedBox(height: 20),
        // ElevatedButton.icon(
        //   onPressed: pickAudioFromDevice,
        //   icon: const Icon(Icons.add, color: Colors.white),
        //   label: const Text('Add Audio', style: TextStyle(color: Colors.white)),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.blue,
        //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(30),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
