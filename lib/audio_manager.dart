import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioCache musicCache = AudioCache();
  AudioPlayer musicPlayer = AudioPlayer();
  AudioCache eventCache = AudioCache();
  AudioPlayer eventPlayer = AudioPlayer();

  init() {
    musicCache = AudioCache(fixedPlayer: musicPlayer, prefix: 'assets/music/background/');
    eventCache = AudioCache(fixedPlayer: eventPlayer, prefix: 'assets/music/events/');
  }

  musicPlay(String music, {bool loop = false}) {
    if (loop) {
      musicCache.loop(musics[music]);
    } else {
      musicCache.play(musics[music]);
    }
  }

  musicResume() {
    musicPlayer.resume();
  }

  musicPause() {
    musicPlayer.pause();
  }

  musicStop() {
    musicPlayer.stop();
  }

  eventPlay(String event) {
    eventCache.play(events[event]);
  }

  dispose() {
    musicPlayer.release();
    musicPlayer.dispose();
    eventPlayer.release();
    eventPlayer.dispose();
    musicCache.clearAll();
    eventCache.clearAll();
  }

  Map<String, dynamic> get musics => {
        'Startup': 'startup.mp3',
        'Start': 'start.mp3',
        'Filler': 'filler.mp3',
        'Fin': 'fin.mp3',
      };

  Map<String, dynamic> get events => {
        'Select': 'select.mp3',
        'Correct': 'correct.mp3',
        'Wrong': 'wrong.mp3',
        'Win': 'win.mp3',
      };
}
