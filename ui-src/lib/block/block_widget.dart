part of './block.dart';

class BlockWidget extends StatelessWidget {
  BlockWidget({
    this.block, 
    this.blockIndex,
    this.blockHorizontalDragStartCallback, 
    this.blockHorizontalDragUpdateCallback,
    this.blockVerticalDragStartCallback, 
    this.blockVerticalDragUpdateCallback
  });

  final Block block;
  final int blockIndex;
  final BlockHorizontalDragStartCallback blockHorizontalDragStartCallback;
  final BlockHorizontalDragUpdateCallback blockHorizontalDragUpdateCallback;
  final BlockVerticalDragStartCallback blockVerticalDragStartCallback;
  final BlockVerticalDragUpdateCallback blockVerticalDragUpdateCallback;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: block.row * 
          (PuzzleWidget.cellSize + 2 * PuzzleWidget.cellSpacing) 
              + PuzzleWidget.cellSpacing,
      left: block.column * 
          (PuzzleWidget.cellSize + 2 * PuzzleWidget.cellSpacing)
              + PuzzleWidget.cellSpacing,
      duration: Duration(milliseconds: 100),
      child: GestureDetector(
        onHorizontalDragStart: block.isVertical ? null :
            (dragStartDetails) => 
                blockHorizontalDragStartCallback(dragStartDetails,
                    blockIndex),
        onHorizontalDragUpdate: block.isVertical ? null :
            (dragUpdateDetails) => 
                blockHorizontalDragUpdateCallback(dragUpdateDetails,
                    blockIndex),
        onVerticalDragStart: !block.isVertical ? null :
            (dragStartDetails) => 
                blockVerticalDragStartCallback(dragStartDetails, 
                    blockIndex),
        onVerticalDragUpdate: !block.isVertical ? null :
            (dragUpdateDetails) => 
                blockVerticalDragUpdateCallback(dragUpdateDetails, 
                    blockIndex),
        child: Container(
          width: block.isVertical ? PuzzleWidget.cellSize 
              : (PuzzleWidget.cellSize + 2 * PuzzleWidget.cellSpacing) 
                  * block.length - 2 * PuzzleWidget.cellSpacing,
          height: !block.isVertical ? PuzzleWidget.cellSize 
              : (PuzzleWidget.cellSize + 2 * PuzzleWidget.cellSpacing) 
                  * block.length - 2 * PuzzleWidget.cellSpacing,
          decoration: BoxDecoration(
            color: block.isRed ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(10),
          )
        )
      )
    );
  }
}