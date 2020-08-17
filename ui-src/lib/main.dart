import 'dart:convert';
import 'dart:async';


import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

import './puzzle/puzzle.dart';

Future<List<Puzzle>> _fetchPuzzles() async {
  http.Response response = await http.get(
      'http://localhost:8080/puzzles');
  var responseJson = json.decode(response.body);
  return (responseJson as List)
      .map((p) => Puzzle.fromJson(p))
      .toList();
}

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unblock Me Ripoff',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeWidget()
      }
    );
  }
}

class HomeWidget extends StatefulWidget {
  
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<HomeWidget> {
  Future<List<Puzzle>> _puzzles;

  List<int> _movesToComplete;

  @override
  void initState() {
    _puzzles = _fetchPuzzles();
    super.initState();
  }

  void _handlePuzzleCompletion(int puzzleNumber, int newScore) async {

    LocalStorage storage = new LocalStorage('unblockme');
    if (await storage.ready) {
      if (_movesToComplete[puzzleNumber - 1] == -1) {  
        _movesToComplete[puzzleNumber - 1] = newScore;
        storage.setItem("puzzle${puzzleNumber}Record", {'moves': newScore});
      } else if (newScore < _movesToComplete[puzzleNumber - 1]) {
        _movesToComplete[puzzleNumber - 1] = newScore;
        storage.setItem("puzzle${puzzleNumber}Record", {'moves': newScore});
      }
    }    
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: FutureBuilder<List<Puzzle>>(
        future: _puzzles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Unblock"),
                Text("Me"),
                Text("Ripoff"),
                RaisedButton(
                  child: Text("Play"),
                  onPressed: () async {
                    int savedPuzzleNumber;
                    List<String> savedStates;
                    LocalStorage storage = new LocalStorage('unblockme');
                    _movesToComplete = List<int>();
                    if (await storage.ready) {
                      Map<String, dynamic> savedData = 
                          storage.getItem('savedData');
                      if (savedData == null) {
                        savedPuzzleNumber = 1;
                        savedStates = null;
                      } else {
                        savedPuzzleNumber = savedData['savedPuzzleNumber'];
                        savedStates = savedData['savedStates'].split(',');
                        for (int i = 0; i < savedStates.length; i++) {
                          print(savedStates[i]);
                        }  
                      }
                      for (int i = 0; i < snapshot.data.length; i++) {
                        int puzzleId = i + 1;
                        Map<String, dynamic> record = 
                            storage.getItem('puzzle${puzzleId}Record');
                        _movesToComplete.add(record == null ? -1 
                            : record['moves']);
                      }
                    }
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => PuzzleWidget(
                          puzzles: snapshot.data,
                          movesToComplete: _movesToComplete,
                          puzzleCompletionCallback: _handlePuzzleCompletion,
                          currentPuzzle: savedPuzzleNumber,
                          savedStates: savedStates
                        )
                      )
                    );
                  }
                ),
                RaisedButton(
                  child: Text("Select Level"),
                  onPressed: () async {
                    LocalStorage storage = new LocalStorage('unblockme');
                    _movesToComplete = List<int>();
                    if (await storage.ready) {
                      for (int i = 0; i < snapshot.data.length; i++) {
                        int puzzleId = i + 1;
                        Map<String, dynamic> record = 
                            storage.getItem('puzzle${puzzleId}Record');
                        _movesToComplete.add(record == null ? -1 
                            : record['moves']);
                      }
                    }
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => PuzzleList(
                          puzzles: snapshot.data,
                          movesToComplete: _movesToComplete,
                          puzzleCompletionCallback: _handlePuzzleCompletion
                        )
                      )
                    );
                  }
                ),
              ]
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        }
      )
    );
  }
}