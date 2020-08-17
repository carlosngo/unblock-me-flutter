part of './puzzle.dart';


class PuzzleList extends StatelessWidget {
  PuzzleList({this.puzzles, this.movesToComplete,
      this.puzzleCompletionCallback});

  final List<Puzzle> puzzles;
  final List<int> movesToComplete;
  final PuzzleCompletionCallback puzzleCompletionCallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text("Puzzles")
          ]
        )
      ),
      body: ListView.builder(
        itemCount: puzzles.length,
        itemBuilder: (context, index) {
          int i = index + 1;
          int moves = movesToComplete[index];
          return ListTile(
            title: Text('Puzzle $i'),
            subtitle: moves == -1 ?
                Text('Not yet completed') :
                Text('Completed with the best of $moves moves.'),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => PuzzleWidget(
                    puzzles: puzzles,
                    movesToComplete: movesToComplete,
                    puzzleCompletionCallback: puzzleCompletionCallback,
                    currentPuzzle: i
                  )
                )
              );
            }
          );
        }
      )
    
    );
  }
}