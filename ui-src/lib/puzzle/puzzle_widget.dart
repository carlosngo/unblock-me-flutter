part of './puzzle.dart';

class PuzzleWidget extends StatefulWidget {
  PuzzleWidget({this.puzzles, this.movesToComplete,
      this.puzzleCompletionCallback, this.currentPuzzle,
      this.savedStates});
  
  static const double cellSize = 100;
  static const double cellSpacing = 2.0;
  static const double puzzleHeight = Puzzle.numberOfRows
      * (PuzzleWidget.cellSize + 2 * PuzzleWidget.cellSpacing);
  static const double puzzleWidth = Puzzle.numberOfColumns 
      * (PuzzleWidget.cellSize + 2 * PuzzleWidget.cellSpacing);
  
  final List<Puzzle> puzzles;
  final List<int> movesToComplete;
  final int currentPuzzle;
  final List<String> savedStates;
  final PuzzleCompletionCallback puzzleCompletionCallback;

  @override
  _PuzzleWidgetState createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  int _puzzleNumber;

  int _numberOfMoves;

  Puzzle _puzzle;

  List<String> _undoStack;
  List<String> _redoStack;
  Offset _dragStart;
  Offset _dragUpdate;

  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _clearSavedState();
    _puzzleNumber = widget.currentPuzzle;
    _numberOfMoves = 0;
    _puzzle = Puzzle.parsePuzzle(widget.puzzles[_puzzleNumber - 1].toString());
    _undoStack = List<String>();
    _redoStack = List<String>();
    _focusNode = FocusNode();
    if (widget.savedStates != null) {
      _puzzle = Puzzle.parsePuzzle(widget.savedStates.removeLast());
      _undoStack.addAll(widget.savedStates);
      _numberOfMoves = widget.savedStates.length;
    }
  }
  
  void _clearSavedState() async {
    LocalStorage storage = new LocalStorage('unblockme');
    if (await storage.ready) {
      storage.deleteItem('savedData');
    }
  }


  void _clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
    _numberOfMoves = 0;
  }

  void _backToHome() {
    Navigator.popUntil(
      context, 
      ModalRoute.withName("/")
    );
  }

  void _handleHomeButtonPressed() {
    if (_undoStack.length == 0) return _backToHome();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Save Progess?"),
          content: Text("Do you wish to save your progress before exiting?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Stay in this Window'),
              onPressed: () {
                Navigator.of(context).pop();
              } 
            ),
            FlatButton(
              child: Text('Exit without Saving'),
              onPressed: () {
                Navigator.of(context).pop();
                _backToHome();
              } 
            ),
            FlatButton(
              child: Text('Save and Exit'),
              onPressed: () async {
                LocalStorage storage = new LocalStorage('unblockme');
                Map<String, dynamic> saveData = Map<String, dynamic>();
                StringBuffer buffer = StringBuffer();
                for (int i = 0; i < _undoStack.length; i++) {
                  buffer.write(_undoStack[i]);
                  buffer.write(',');
                }
                buffer.write(_puzzle.toString());
                saveData['savedPuzzleNumber'] = _puzzleNumber;
                saveData['savedStates'] = buffer.toString();
                if (await storage.ready) {
                  storage.setItem('savedData', saveData);
                }
                Navigator.of(context).pop();
                _backToHome();
              }
            )
          ]
        );
      }
    );
  }

  void _handleWin() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nice!"),
          content: Text("You have cleared this puzzle."),
          actions: <Widget>[
            _puzzleNumber >= widget.puzzles.length ? SizedBox.shrink() 
                : FlatButton(
                  child: Text('Next Puzzle'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleSwitchPuzzle(_puzzleNumber + 1);
                  } 
                ),
            FlatButton(
              child: Text('Reset Puzzle'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleReset();
              } 
            ),
            FlatButton(
              child: Text('Back to Home'),
              onPressed: () {
                Navigator.of(context).pop();
                _backToHome();
              }
            )
          ]
        );
      }
    );
    widget.puzzleCompletionCallback(_puzzleNumber, _numberOfMoves);
  }

  void _handleSwitchPuzzle(int puzzle) {
    setState(() {
      _puzzleNumber = puzzle;
      _puzzle = Puzzle
          .parsePuzzle(widget.puzzles[_puzzleNumber - 1].toString());
      _clearHistory();
    });
  }

  void _handleBlockHorizontalDragStart(
      DragStartDetails dragStartDetails, 
      int blockIndex) {
    _dragStart = dragStartDetails.globalPosition; 
  }

  void _handleBlockHorizontalDragUpdate(
      DragUpdateDetails dragUpdateDetails,
      int blockIndex) {
    String currentState = _puzzle.toString();
    _dragUpdate = dragUpdateDetails.globalPosition;
    double delta = _dragUpdate.dx - _dragStart.dx;
    Offset offset;

    if (delta.abs() > PuzzleWidget.cellSize) {
      bool stateChanged;
      if (delta < 0) {
        offset = Offset(_dragStart.dx - PuzzleWidget.cellSize, _dragStart.dy);
        stateChanged = _puzzle.moveBlockLeft(blockIndex);
      } else {
        offset = Offset(_dragStart.dx + PuzzleWidget.cellSize, _dragStart.dy);
        stateChanged = _puzzle.moveBlockRight(blockIndex);
      }
      if (stateChanged) {
        _undoStack.add(currentState);
        _redoStack = List<String>();
        _dragStart = offset;
        _numberOfMoves++;
        if (_puzzle.hasWon()) {
          _handleWin();
        }
        setState(() {});
      }  
    }
  }

  void _handleBlockVerticalDragStart(
      DragStartDetails dragStartDetails,
      int blockIndex) {
    _dragStart = dragStartDetails.globalPosition; 
  }

  void _handleBlockVerticalDragUpdate(
      DragUpdateDetails dragUpdateDetails, 
      int blockIndex) {
    String currentState = _puzzle.toString();
    _dragUpdate = dragUpdateDetails.globalPosition;
    double delta = _dragUpdate.dy - _dragStart.dy;
    Offset offset;

    if (delta.abs() > PuzzleWidget.cellSize) {
      bool stateChanged;
      if (delta < 0) {
        offset = Offset(_dragStart.dx, _dragStart.dy - PuzzleWidget.cellSize);
        stateChanged = _puzzle.moveBlockUp(blockIndex);
      } else {
        offset = Offset(_dragStart.dx, _dragStart.dy + PuzzleWidget.cellSize);
        stateChanged = _puzzle.moveBlockDown(blockIndex);
      }
      if (stateChanged) {
        _undoStack.add(currentState);
        _redoStack = List<String>();
        _dragStart = offset;
        _numberOfMoves++;
        setState(() {});
      }  
    }
  }

  void _handleUndo() {
    setState(() {
      String currentState = _puzzle.toString();
      String previousState = _undoStack.removeLast();
      _redoStack.add(currentState);
      _puzzle = Puzzle.parsePuzzle(previousState);
      _numberOfMoves--;
    });
  }

  void _handleRedo() {
    setState(() {
      String currentState = _puzzle.toString();
      String undidState = _redoStack.removeLast();
      _undoStack.add(currentState);
      _puzzle = Puzzle.parsePuzzle(undidState);
      _numberOfMoves++;
    });
  }

  void _handleReset() {
    setState(() {
      _puzzle = Puzzle
          .parsePuzzle(widget.puzzles[_puzzleNumber - 1].toString());
      _clearHistory();
    });
  }

  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        if (event.runtimeType == RawKeyDownEvent &&
            event.isControlPressed) {
          if (event.isShiftPressed 
              && event.logicalKey == LogicalKeyboardKey.keyZ) {
            if (_undoStack.length != 0) {
              _handleReset();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
            if (_redoStack.length != 0) {
              _handleRedo();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
            if (_undoStack.length != 0) {
              _handleUndo();
            }
          } 
        }
      }, 
      child: Container(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(5.0),
              width: PuzzleWidget.puzzleWidth,
              child: PuzzleControl(
                puzzleNumber: _puzzleNumber,
                maxPuzzleNumber: widget.puzzles.length,
                numberOfMoves: _numberOfMoves,
                handleSwitchPuzzle: _handleSwitchPuzzle,
                bestRecord: widget.movesToComplete[_puzzleNumber - 1]
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              height: PuzzleWidget.puzzleHeight,
              width: PuzzleWidget.puzzleWidth,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: _puzzle._blocks.asMap().map((i, block) => 
                      MapEntry(i, 
                          BlockWidget(
                            block: block,
                            blockIndex: i,
                            blockHorizontalDragStartCallback: 
                                _handleBlockHorizontalDragStart,
                            blockHorizontalDragUpdateCallback: 
                                _handleBlockHorizontalDragUpdate,
                            blockVerticalDragStartCallback: 
                                _handleBlockVerticalDragStart,
                            blockVerticalDragUpdateCallback: 
                                _handleBlockVerticalDragUpdate,
                          )
                      )
                  ).values.toList(),
                )
              )
            ),
            Container(
              width: PuzzleWidget.puzzleWidth,
              margin: const EdgeInsets.all(5.0),
              child: PuzzleStateControl(
                undoStack: _undoStack,
                redoStack: _redoStack,
                handleUndo: _handleUndo,
                handleRedo: _handleRedo,
                handleReset: _handleReset,
                handleHome: _handleHomeButtonPressed,
              )
            )
            
          ]
        )
      )
    );
  }

  

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
