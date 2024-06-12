import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:yes_or_no/src/widget/puzzle/enum/chimera.dart';
import 'package:yes_or_no/src/widget/puzzle/puzzle_shape.dart';
import 'package:yes_or_no/src/widget/swipe_cards/match_engine.dart';
import 'package:yes_or_no/src/widget/swipe_cards/swipe_cards.dart';

void main() => runApp(const MyApp());

List<(Color, String)> _dataList = [
  (Colors.red, "Red"),
  (Colors.blue, "Blue"),
  (Colors.green, "Green"),
  (Colors.yellow, "Yellow"),
  (Colors.orange, "Orange"),
  (Colors.grey, "Grey"),
  (Colors.purple, "Purple"),
  (Colors.pink, "Pink"),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yes or No',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulHookWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MatchEngine _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    _matchEngine = MatchEngine(
      itemCount: _dataList.length,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isFinish = useState(false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Yes or No"),
      ),
      body: !isFinish.value
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SwipeCards(
                  matchEngine: _matchEngine,
                  upSwipeAllowed: false,
                  leftTag: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 72,
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.grey,
                        size: 64,
                      ),
                    ],
                  ),
                  rightTag: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 72,
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 64,
                      ),
                    ],
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: _dataList[index].$1,
                        shape: const PuzzleShape(
                          top: Chimera.convex,
                          left: Chimera.concave,
                          right: Chimera.convex,
                          bottom: Chimera.concave,
                        ),
                      ),
                      child: Text(
                        _dataList[index].$2,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    );
                  },
                  onSlideRegionUpdate: (index, region) {
                    debugPrint("onSlideRegionUpdate index: $index, region: $region");
                  },
                  onItemSlided: (index, direction) {
                    debugPrint("onItemSlided index: $index, direction: $direction");
                  },
                  onStackFinished: () {
                    debugPrint("onStackFinished");

                    isFinish.value = true;
                  },
                ),
              ],
            )
          : Center(
              child: Center(
                child: Text(
                  "Quiz ends",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isFinish.value) {
            _matchEngine.rewindMatch();
          } else {
            _matchEngine.resetMatch();
            isFinish.value = false;
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
