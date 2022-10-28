import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_app/Provider/song_model_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class NowPlayiong extends StatefulWidget {
  final List<SongModel> songModelList;
  final AudioPlayer audioPlayer;
  const NowPlayiong(
      {super.key, required this.audioPlayer, required this.songModelList});

  @override
  State<NowPlayiong> createState() => _NowPlayiongState();
}

class _NowPlayiongState extends State<NowPlayiong> {
  Duration _duration = const Duration();
  Duration _position = const Duration();

  bool _isPlaying = false;
  List<AudioSource> songList = [];

  int currentIndex = 0;

  void popBack() {
    Navigator.pop(context);
  }

  void seekToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }

  @override
  void initState() {
    super.initState();
    parseSong();
  }

  void parseSong() {
    try {
      for (var element in widget.songModelList) {
        songList.add(
          AudioSource.uri(
            Uri.parse(element.uri!),
            tag: MediaItem(
              id: element.id.toString(),
              album: element.album ?? "No Album",
              title: element.displayNameWOExt,
              artUri: Uri.parse(element.id.toString()),
            ),
          ),
        );
      }
      widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: songList),
      );

      widget.audioPlayer.play();
      _isPlaying = true;

      widget.audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });
      widget.audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      listenToEvent();
      listenToSongIndex();
    } on Exception catch (_) {
      popBack();
    }
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen(
      (event) {
        setState(
          () {
            if (event != null) {
              currentIndex = event;
            }
            context
                .read<SongModelProvider>()
                .setId(widget.songModelList[currentIndex].id);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    popBack();
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: ArtWorkWidget(),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.songModelList[currentIndex].displayNameWOExt,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // Text(
                    //   widget.songModelList[currentIndex].displayNameWOExt ==
                    //           "<unknown>"
                    //       ? "Unknown Artist"
                    //       : widget.songModelList[currentIndex].displayNameWOExt,
                    //   overflow: TextOverflow.fade,
                    //   maxLines: 1,
                    //   style: const TextStyle(fontSize: 18),
                    // ),
                    Slider(
                        min: 0.0,
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble() + 1.0,
                        onChanged: (value) {
                          setState(() {
                            seekToSeconds(value.toInt());
                            value = value;
                          });
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(_position.toString().split(".")[0]),
                        Text(_duration.toString().split(".")[0]),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (widget.audioPlayer.hasPrevious) {
                              widget.audioPlayer.seekToPrevious();
                            }
                          },
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              if (_isPlaying) {
                                widget.audioPlayer.pause();
                              } else {
                                if (_position >= _duration) {
                                  seekToSeconds(0);
                                } else {
                                  widget.audioPlayer.play();
                                }
                              }
                              _isPlaying = !_isPlaying;
                            });
                          },
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (widget.audioPlayer.hasNext) {
                              widget.audioPlayer.seekToNext();
                            }
                          },
                          icon: const Icon(
                            Icons.skip_next,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: const Icon(
        Icons.music_note,
        size: 200,
      ),
    );
  }
}
