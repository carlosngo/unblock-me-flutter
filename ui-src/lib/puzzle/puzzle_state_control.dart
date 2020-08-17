part of './puzzle.dart';

typedef void UndoCallback();
typedef void RedoCallback();
typedef void ResetCallback();
typedef void HomeCallback();

class PuzzleStateControl extends StatelessWidget {
  PuzzleStateControl({this.undoStack, this.redoStack, 
      this.handleUndo, this.handleRedo, this.handleReset,
      this.handleHome});

  final List<String> undoStack;
  final List<String> redoStack;
  final UndoCallback handleUndo;
  final RedoCallback handleRedo;
  final ResetCallback handleReset;
  final HomeCallback handleHome;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Expanded(
            child: Material(
              child: IconButton(
                icon: Icon(Icons.home),
                onPressed: handleHome
              )
            )
          ),
          Expanded(
            child: Material(
              child: IconButton(
                icon: Icon(Icons.undo),
                onPressed: undoStack.isEmpty ? null 
                    : handleUndo
              )
            )
          ),
          Expanded(
            child: Material(
              child: IconButton(
                icon: Icon(Icons.redo),
                onPressed: redoStack.isEmpty ? null 
                    : handleRedo
              )
            )
          ),
          Expanded(
            child: Material(
              child: IconButton(
                icon: Icon(Icons.restore),
                onPressed: undoStack.isEmpty ? null 
                    : handleReset
              )   
            ),
          ),
        ]
      )
    );
  }
}

