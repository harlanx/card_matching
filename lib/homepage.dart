import 'dart:async';
import 'package:card_matching/audio_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'flip_card_game.dart';
import 'data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers = [];
  late List<Animation> _colorAnimations = [];
  late List<Animation> _transformAnimations = [];
  AudioManager _homeAudioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _levelList.forEach((element) {
      _animationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 50)));
    });

    _levelList.forEachIndexed((index, element) {
      _colorAnimations.add(ColorTween(begin: element.color, end: Colors.white).animate(_animationControllers[index])
        ..addListener(() {
          setState(() {});
        }));
    });

    _levelList.forEachIndexed((index, element) {
      _transformAnimations.add(Tween<double>(begin: 1, end: 1.05).animate(_animationControllers[index])
        ..addListener(() {
          setState(() {});
        }));
    });
    _homeAudioManager.init();
    _homeAudioManager.musicPlayer.setVolume(0.5);
    _homeAudioManager.musicPlay('Startup');
    _homeAudioManager.musicPlayer.onPlayerCompletion.listen((event) {
      _homeAudioManager.musicPlay('Filler');
    });
  }

  @override
  void dispose() {
    _animationControllers.forEach((element) {
      element.dispose();
    });
    _homeAudioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/pokemon_pics/pokemon_background.jpg'), fit: BoxFit.cover),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: 200,
              child: Column(
                children: [
                  Expanded(
                    flex: 70,
                    child: Image.asset(
                      'assets/pokemon_pics/pokemon_logo.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Image.asset(
                      'assets/pokemon_pics/gotta_matc_em_all.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: List.generate(_levelList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        TickerFuture tickerFuture = _animationControllers[index].repeat(reverse: true);
                        tickerFuture.timeout(Duration(milliseconds: 700), onTimeout: () {
                          _animationControllers[index].forward(from: 0);
                          _animationControllers[index].stop(canceled: true);
                        });
                        _homeAudioManager.musicPlayer.pause();
                        _homeAudioManager.eventPlay('Select');
                        Timer(Duration(milliseconds: 500), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => _levelList[index].levelPage,
                            ),
                          ).then((value) => _homeAudioManager.musicPlayer.resume());
                        });
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Transform.scale(
                            scale: _transformAnimations[index].value,
                            child: Container(
                              padding: EdgeInsets.only(bottom: 5),
                              height: MediaQuery.of(context).size.height * 0.13,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _colorAnimations[index].value,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(blurRadius: 4, color: Colors.black12, spreadRadius: 0.3, offset: Offset(5, 3)),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 65,
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text(
                                        _levelList[index].name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.5),
                                              blurRadius: 2,
                                              offset: Offset(1.2, 1.2),
                                            ),
                                            Shadow(
                                              color: _levelList[index].color.withOpacity(0.5),
                                              blurRadius: 2,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 35,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: difficultyIcon(_levelList[index].iconCount),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> difficultyIcon(int count) {
    List<Widget> _icons = [];
    for (int i = 0; i < count; i++) {
      _icons.insert(i, Image.asset('assets/pokemon_pics/poke_ball.png', fit: BoxFit.fitHeight));
    }
    return _icons;
  }
}

class LevelDetails {
  String name;
  Color color;
  Widget levelPage;
  int iconCount;

  LevelDetails({
    required this.name,
    required this.color,
    required this.iconCount,
    required this.levelPage,
  });
}

List<LevelDetails> _levelList = [
  LevelDetails(name: "EASY", color: Colors.green.shade300, iconCount: 1, levelPage: FlipCardGame(Level.Easy)),
  LevelDetails(name: "NORMAL", color: Colors.orange.shade300, iconCount: 2, levelPage: FlipCardGame(Level.Medium)),
  LevelDetails(name: "HARD", color: Colors.red.shade300, iconCount: 3, levelPage: FlipCardGame(Level.Hard)),
];
