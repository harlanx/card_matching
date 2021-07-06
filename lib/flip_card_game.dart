import 'package:card_matching/audio_manager.dart';
import 'package:confetti/confetti.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'dart:async';

class FlipCardGame extends StatefulWidget {
  final Level _level;
  FlipCardGame(this._level);
  @override
  _FlipCardGameState createState() => _FlipCardGameState(_level);
}

class _FlipCardGameState extends State<FlipCardGame> {
  _FlipCardGameState(this._level);
  int _previousIndex = -1;
  bool _flip = false;
  bool _start = false;
  bool _wait = false;
  Level _level;
  late Timer _timer;
  late int _time;
  late int _left;
  late bool _isFinished;
  late List<String> _data;
  late List<bool> _cardFlips;
  late List<GlobalKey<FlipCardState>> _cardStateKeys;
  AudioManager _gameAudioManager = AudioManager();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _confettiController = ConfettiController(duration: Duration(seconds: 15));
    _gameAudioManager.init();
    restart();
    _gameAudioManager.musicPlayer.setVolume(0.25);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _gameAudioManager.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isFinished
        ? Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/pokemon_pics/pokemon_background.jpg'), fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/pokemon_pics/pokemon_badges.png'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          "You've won!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            restart();
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            "Play Again",
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFCC0000),
                      Color(0xFF3B4CCA),
                      Color(0xFFFFDE00),
                      Color(0xFFB3A125),
                    ],
                    blastDirectionality: BlastDirectionality.explosive,
                    blastDirection: 4.71239, //This is 270 Degrees ((3 * pi) / 2) = Direction towards bottom
                  ),
                )
              ],
            ),
          )
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: _time > 0
                  ? Text('$_time', style: Theme.of(context).textTheme.headline3)
                  : Text('Left:$_left', style: Theme.of(context).textTheme.headline3),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/pokemon_pics/pokemon_background.jpg'), fit: BoxFit.cover),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(
                      _data.length,
                      (index) => _start
                          ? FlipCard(
                              key: _cardStateKeys[index],
                              direction: FlipDirection.HORIZONTAL,
                              front: Container(
                                height: 100,
                                width: 100,
                                color: Colors.transparent,
                                child: Image.asset(
                                  "assets/pokemon_pics/pokemon_card_back.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                              back: getItem(index),
                              flipOnTouch: _wait ? false : _cardFlips[index],
                              onFlip: () {
                                if (!_flip) {
                                  _flip = true;
                                  _previousIndex = index;
                                } else {
                                  _flip = false;
                                  if (_previousIndex != index) {
                                    if (_data[_previousIndex] != _data[index]) {
                                      _wait = true;
                                      Future.delayed(Duration(milliseconds: 800), () {
                                        _cardStateKeys[_previousIndex].currentState!.toggleCard();
                                        _gameAudioManager.eventPlay('Wrong');
                                        _previousIndex = index;
                                        _cardStateKeys[_previousIndex].currentState!.toggleCard();
                                        Future.delayed(Duration(milliseconds: 1), () {
                                          setState(() {
                                            _wait = false;
                                          });
                                        });
                                      });
                                    } else {
                                      _cardFlips[_previousIndex] = false;
                                      _cardFlips[index] = false;
                                      setState(() {
                                        _left -= 1;
                                      });
                                      if (_cardFlips.every((result) => result == false)) {
                                        Future.delayed(const Duration(milliseconds: 1), () {
                                          setState(() {
                                            _isFinished = true;
                                            _start = false;
                                            _gameAudioManager.musicPlayer.stop();
                                            _gameAudioManager.eventPlay('Win');
                                            _gameAudioManager.eventPlayer.onPlayerCompletion.listen((event) {
                                              if (_isFinished) _gameAudioManager.musicPlay('Fin', loop: true);
                                            });
                                            _confettiController.play();
                                          });
                                        });
                                      } else {
                                        _gameAudioManager.eventPlay('Correct');
                                      }
                                    }
                                  }
                                }
                                setState(() {});
                              },
                            )
                          : getItem(index),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget getItem(int index) {
    return Container(
      height: 100,
      width: 100,
      padding: EdgeInsets.all(4),
      child: Image.asset(
        _data[index],
        fit: BoxFit.contain,
      ),
    );
  }

  startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (this.mounted) {
        setState(() {
          _time = _time - 1;
        });
        Future.delayed(
          const Duration(milliseconds: 4000),
          () {
            if (this.mounted) {
              setState(() {
                _start = true;
                _timer.cancel();
              });
            }
          },
        );
      }
    });
  }

  void restart() {
    _gameAudioManager.musicPlay('Start', loop: true);
    _gameAudioManager.eventPlayer.stop();
    _confettiController.stop();
    _time = 5;
    _isFinished = false;
    _data = levelItems(_level);
    _left = (_data.length ~/ 2);
    _cardStateKeys = getCardStateKeys(_level);
    _cardFlips = getInitialItemState(_level);
    startTimer();
  }
}
