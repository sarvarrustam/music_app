import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/Provider/song_model_provider.dart';
import 'package:music_app/Screens/now_playing.dart';
import 'package:music_app/Widgets/music_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key});

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> allSongs = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() async {
    if (Platform.isAndroid) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Music Player",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return Center(
              child: Column(
                children: const [
                  CupertinoActivityIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Loading..."),
                ],
              ),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("Nothing found!"));
          }
          return Stack(
            children: [
              ListView.builder(
                itemCount: item.data!.length,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                itemBuilder: (context, index) {
                  allSongs.addAll(item.data!);
                  return GestureDetector(
                    onTap: () {
                      context
                          .read<SongModelProvider>()
                          .setId(item.data![index].id);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NowPlayiong(
                                  songModelList: allSongs,
                                  // songModelList: [item.data![index]],
                                  audioPlayer: _audioPlayer)));
                    },
                    child: MusicTile(
                      songModell: item.data![index],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NowPlayiong(
                                songModelList: allSongs,
                                audioPlayer: _audioPlayer)));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 15, 15),
                    child: const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.pause),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
