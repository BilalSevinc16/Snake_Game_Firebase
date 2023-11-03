import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game_firebase/blank_pixel.dart';
import 'package:snake_game_firebase/food_pixel.dart';
import 'package:snake_game_firebase/highscore_tile.dart';
import 'package:snake_game_firebase/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SnakeDirection { up, down, left, right }

class _HomePageState extends State<HomePage> {
  // grid dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  // game settings
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  // user score
  int currentScore = 0;

  // snake position
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  // snake direction is initially to the right
  var currentDirection = SnakeDirection.right;

  // food position
  int foodPos = 55;

  // highscore list
  List<String> highscoreDocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) {
      for (var element in value.docs) {
        highscoreDocIds.add(element.reference.id);
      }
    });
  }

  // start the game!
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) {
        setState(
          () {
            // keep the snake moving!
            moveSnake();
            // check if the game is over
            if (gameOver()) {
              timer.cancel();
              // display a message to the user
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Game over"),
                    content: Column(
                      children: [
                        Text("Your score is: $currentScore"),
                        TextField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(hintText: "Enter name"),
                        ),
                      ],
                    ),
                    actions: [
                      MaterialButton(
                        onPressed: () {
                          submitScore();
                          newGame();
                          Navigator.pop(context);
                        },
                        color: Colors.pink,
                        child: const Text("Submit"),
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  void submitScore() {
    // get access to the collection
    var database = FirebaseFirestore.instance;
    // add data to firebase
    database.collection("highscores").add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  Future newGame() async {
    highscoreDocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = SnakeDirection.right;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    // making sure the new food is not where the snake is
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirection.right:
        {
          // add a head
          // if snake is at the right wall, need to re-adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case SnakeDirection.left:
        {
          // add a head
          // if snake is at the right wall, need to re-adjust
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case SnakeDirection.up:
        {
          // add a head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case SnakeDirection.down:
        {
          // add a head
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    // snake is eating food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // remove tail
      snakePos.removeAt(0);
    }
  }

  // game over
  bool gameOver() {
    // the game is over when the snake runs into itself
    // this occurs when there is a duplicate position in the snakePos list
    // this list is the body of the snake (no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != SnakeDirection.up) {
            currentDirection = SnakeDirection.down;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != SnakeDirection.down) {
            currentDirection = SnakeDirection.up;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != SnakeDirection.right) {
            currentDirection = SnakeDirection.left;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != SnakeDirection.left) {
            currentDirection = SnakeDirection.right;
          }
        },
        child: SizedBox(
          width: screenWidth > 428 ? 428 : screenWidth,
          child: Column(
            children: [
              // scores
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // user current score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Current Score"),
                          Text(
                            currentScore.toString(),
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // highscores, top 5 or 10
                    Expanded(
                      child: gameHasStarted
                          ? Container()
                          : FutureBuilder(
                              future: letsGetDocIds,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: highscoreDocIds.length,
                                  itemBuilder: ((context, index) {
                                    return HighScoreTile(
                                        documentId: highscoreDocIds[index]);
                                  }),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              // game grid
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != SnakeDirection.up) {
                      currentDirection = SnakeDirection.down;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != SnakeDirection.down) {
                      currentDirection = SnakeDirection.up;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != SnakeDirection.left) {
                      currentDirection = SnakeDirection.right;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != SnakeDirection.right) {
                      currentDirection = SnakeDirection.left;
                    }
                  },
                  child: GridView.builder(
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize,
                    ),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    },
                  ),
                ),
              ),
              // play button
              Expanded(
                child: Center(
                  child: MaterialButton(
                    color: gameHasStarted ? Colors.grey : Colors.pink,
                    onPressed: gameHasStarted ? () {} : startGame,
                    child: const Text("PLAY"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
