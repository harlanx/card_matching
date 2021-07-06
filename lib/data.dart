import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';

enum Level { Hard, Medium, Easy }

List<String> dataAssets() {
  return [
    'assets/pokemon_pics/bulbasaur.png',
    'assets/pokemon_pics/bulbasaur.png',
    'assets/pokemon_pics/charmander.png',
    'assets/pokemon_pics/charmander.png',
    'assets/pokemon_pics/gengar.png',
    'assets/pokemon_pics/gengar.png',
    'assets/pokemon_pics/pikachu.png',
    'assets/pokemon_pics/pikachu.png',
    'assets/pokemon_pics/squirtle.png',
    'assets/pokemon_pics/squirtle.png',
    'assets/pokemon_pics/togepi.png',
    'assets/pokemon_pics/togepi.png',
    'assets/pokemon_pics/jiggly_puff.png',
    'assets/pokemon_pics/jiggly_puff.png',
    'assets/pokemon_pics/snorlax.png',
    'assets/pokemon_pics/snorlax.png',
    'assets/pokemon_pics/psyduck.png',
    'assets/pokemon_pics/psyduck.png',
  ];
}

List<String> levelItems(Level level) {
  List<String> itemList = [];
  List itemData = dataAssets();
  if (level == Level.Hard) {
    for (int i = 0; i < 18; i++) {
      itemList.add(itemData[i]);
    }
  } else if (level == Level.Medium) {
    for (int i = 0; i < 12; i++) {
      itemList.add(itemData[i]);
    }
  } else if (level == Level.Easy) {
    for (int i = 0; i < 6; i++) {
      itemList.add(itemData[i]);
    }
  }

  itemList.shuffle();
  return itemList;
}

List<bool> getInitialItemState(Level level) {
  List<bool> initialItemState = [];
  if (level == Level.Hard) {
    for (int i = 0; i < 18; i++) {
      initialItemState.add(true);
    }
  } else if (level == Level.Medium) {
    for (int i = 0; i < 12; i++) {
      initialItemState.add(true);
    }
  } else if (level == Level.Easy) {
    for (int i = 0; i < 6; i++) {
      initialItemState.add(true);
    }
  }
  return initialItemState;
}

List<GlobalKey<FlipCardState>> getCardStateKeys(Level level) {
  List<GlobalKey<FlipCardState>> cardStateKeys = [];
  if (level == Level.Hard) {
    for (int i = 0; i < 18; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
    }
  } else if (level == Level.Medium) {
    for (int i = 0; i < 12; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
    }
  } else if (level == Level.Easy) {
    for (int i = 0; i < 6; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
    }
  }
  return cardStateKeys;
}
