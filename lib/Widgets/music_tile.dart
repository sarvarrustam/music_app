import 'package:flutter/material.dart';
import 'package:music_app/utils/song_model_extension.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicTile extends StatelessWidget {
  final SongModel songModell;

  const MusicTile({super.key, required this.songModell});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        songModell.displayNameWOExt,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(songModell.additionalSongInfo),
      trailing: const Icon(Icons.more_horiz),
      leading: QueryArtworkWidget(
        id: songModell.id,
        type: ArtworkType.AUDIO,
        nullArtworkWidget: const Icon(Icons.music_note),
      ),
    );
  }
}
