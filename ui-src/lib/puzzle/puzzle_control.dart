part of './puzzle.dart';

typedef void PuzzleChangedCallback(int puzzle);

class PuzzleControl extends StatelessWidget {
  PuzzleControl({this.puzzleNumber, this.maxPuzzleNumber, 
      this.numberOfMoves, this.handleSwitchPuzzle,
      this.bestRecord});

  final int puzzleNumber;
  final PuzzleChangedCallback handleSwitchPuzzle;
  final int maxPuzzleNumber;
  final int numberOfMoves;
  final int bestRecord;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 84.0,
        child: Row (
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.only(right: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: <Widget>[
                    Material(
                      shape: CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.arrow_left),
                        onPressed: puzzleNumber == 1 ? null : () {
                          handleSwitchPuzzle(puzzleNumber - 1);
                        }
                      )
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Puzzle'),
                            Text(
                              '$puzzleNumber',
                              style: TextStyle(
                                fontSize:24
                              ),
                            )
                          ]
                        )
                      )
                    ),
                    Material(
                      shape: CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.arrow_right),
                        onPressed: puzzleNumber >= maxPuzzleNumber ? null : () {
                          handleSwitchPuzzle(puzzleNumber + 1);
                        }
                      )
                    )
                  ]
                )
              )
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Moves'),
                    Text(
                      '$numberOfMoves',
                      style: TextStyle(
                        fontSize:24
                      ),
                    ),
                    bestRecord == -1 ? SizedBox.shrink()
                        : Text('Best: $bestRecord')
                  ]
                )
              )
            )
          ],
        ) 
      )
    );
  }
}