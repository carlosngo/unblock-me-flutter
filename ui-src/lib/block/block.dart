import 'package:flutter/material.dart';

import '../puzzle/puzzle.dart';

part './block_widget.dart';

typedef void BlockHorizontalDragStartCallback(
    DragStartDetails dragStartDetails, 
        int blockIndex);
typedef void BlockHorizontalDragUpdateCallback(
    DragUpdateDetails dragUpdateDetails,
        int blockIndex);
typedef void BlockVerticalDragStartCallback(
    DragStartDetails dragStartDetails, 
        int blockIndex);
typedef void BlockVerticalDragUpdateCallback(
    DragUpdateDetails dragUpdateDetails, 
        int blockIndex);

class Block {
  Block({this.isVertical, this.isRed, this.length});

  final isVertical;
  final bool isRed;
  final int length;
  int _row;
  int _column;

  int get row {
    return _row;
  }

  int get column {
    return _column;
  }

  set row(int row) {
    this._row = row;
  }

  set column(int column) {
    this._column = column;
  }

}
