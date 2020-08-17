import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

import '../block/block.dart';

part './puzzle_widget.dart';
part './puzzle_control.dart';
part './puzzle_state_control.dart';
part './puzzle_list.dart';


typedef void PuzzleCompletionCallback(int puzzleNumber, int newScore);

class Puzzle {
  static const int numberOfRows = 6;
  static const int numberOfColumns = 6;
  static const int _startBlock = 0;
  static const int _emptyCell = -1;
  static const int _winRow = 2;
  static const int _winColumn = 4;

  final List<Block> _blocks = List<Block>();
  final List<List<int>> _puzzle = List<List<int>>();

  Puzzle(List<Block> blocks) {
    // initialize all cells as empty
    for (int i = 0; i < numberOfRows; i++) {
      List<int> arr = List<int>();
      for (int j = 0; j < numberOfColumns; j++) {
        arr.add(_emptyCell);
      }
      if (i == 2) {
        arr.add(_emptyCell);
        arr.add(_emptyCell);
      }
      _puzzle.add(arr);
    }

    // mark cells occupied by blocks
    for (int i = 0; i < blocks.length; i++) {
      Block block = blocks[i];
      _blocks.add(block);
      int row = block.row;
      int column = block.column;
      if (block.isVertical) {
        for (int j = 0; j < block.length; j++) {
          setCell(row, column, i);
          row++;
        }
      } else {
        for (int j = 0; j < block.length; j++) {
          setCell(row, column, i);
          column++;
        }
      }
    }
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    print(Puzzle.parsePuzzle(json['puzzleString']).toString());
    return Puzzle.parsePuzzle(json['puzzleString']);
  }

  int getCell(int row, int column) {
    return _puzzle[row][column];
  }

  void setCell(int row, int column, int value) {
    _puzzle[row][column] = value;
  }

  Block getBlock(int blockNumber) {
    return _blocks[blockNumber];
  }

  void setBlock(int blockNumber, Block block) {
    _blocks[blockNumber] = block;
  }

  bool moveBlockLeft(int blockNumber) {
    Block block = getBlock(blockNumber);
    int nextColumn = block.column - 1;
    if (!_canDrag(blockNumber, block.row, nextColumn)) {
      return false;
    }
    setCell(block.row, block.column + block.length - 1, _emptyCell);
    setCell(block.row, nextColumn, blockNumber);
    block.column = nextColumn;
    return true;
  } 

  bool moveBlockRight(int blockNumber) {
    Block block = getBlock(blockNumber);
    int nextColumn = block.column + 1;
    if (!_canDrag(blockNumber, block.row, nextColumn + block.length - 1)) {
      return false;
    }
    setCell(block.row, block.column, _emptyCell);
    setCell(block.row, nextColumn + block.length - 1, blockNumber);
    block.column = nextColumn;
    return true;
  }

  bool moveBlockUp(int blockNumber) {
    Block block = getBlock(blockNumber);
    int nextRow = block.row - 1;
    if (!_canDrag(blockNumber, nextRow, block.column)) {
      return false;
    }
    setCell(block.row + block.length - 1, block.column, _emptyCell);
    setCell(nextRow, block.column, blockNumber);
    block.row = nextRow;
    return true;
  } 

  bool moveBlockDown(int blockNumber) {
    Block block = getBlock(blockNumber);
    int nextRow = block.row + 1;
    if (!_canDrag(blockNumber, nextRow + block.length - 1, block.column)) {
      return false;
    }
    setCell(block.row, block.column, _emptyCell);
    setCell(nextRow + block.length - 1, block.column, blockNumber);
    block.row = nextRow;
    return true;
  }

  bool _canDrag(int blockNumber, int row, int column) {
    if (row < 0 || row >= Puzzle.numberOfRows || 
        column < 0 || column >= Puzzle.numberOfColumns) {
      return false;
    }
    int cell = getCell(row, column);
    return cell == blockNumber || cell == _emptyCell;
  }
  
  bool hasWon() {
    Block block = getBlock(_startBlock);
    return block.row == _winRow && block.column == _winColumn;
  }

  static Puzzle parsePuzzle(String s) {
    List<List<bool>> visited = List<List<bool>>();
    List<List<int>> grid = List<List<int>>();
  
    for (int i = 0; i < numberOfRows; i++) {
      List<bool> arr = List<bool>();
      List<int> arr2 = List<int>();
      for (int j = 0; j < numberOfColumns; j++) {
        arr.add(false);
        arr2.add(_emptyCell);
      }
      visited.add(arr);
      grid.add(arr2);
    }
    int maxBlockNumber = 0;
    for (int i = 0; i < s.length; i++) {
      int codeUnit = s[i].codeUnitAt(0) - "A".codeUnitAt(0);
      int row = i ~/ numberOfColumns;
      int col = i % numberOfColumns;
      grid[row][col] = codeUnit;
      if (codeUnit > maxBlockNumber) {
        maxBlockNumber = codeUnit;
      }
    }
    List<Block> blocks = List<Block>(maxBlockNumber + 1);
    for (int i = 0; i < numberOfRows; i++) {
      for (int j = 0; j < numberOfColumns; j++) {
        if (!visited[i][j] && grid[i][j] != _emptyCell) {
          visited[i][j] = true;
          int blockNumber = grid[i][j];
          int length = 1;
          bool isVertical;
          bool isRed = blockNumber == _startBlock;
          int rightColumn = j + 1;
          int bottomRow = i + 1;
          
          while (rightColumn < numberOfColumns && 
              grid[i][rightColumn] == blockNumber) { 
            visited[i][rightColumn] = true;
            isVertical = false;
            length++;
            rightColumn++;
          } 

          while (bottomRow < numberOfRows &&
              grid[bottomRow][j] == blockNumber) {
            visited[bottomRow][j] = true;
            isVertical = true;
            length++;
            bottomRow++;
          }
        
          Block block = Block(
            length: length,
            isVertical: isVertical,
            isRed: isRed
          );

          block.row = i;
          block.column = j;

          blocks[blockNumber] = block;
        }
      }
    }
    Puzzle puzzle = Puzzle(blocks);
    return puzzle;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < numberOfRows; i++) {
      for (int j = 0; j < numberOfColumns; j++) {
        int cell = getCell(i, j);
        String char = String.fromCharCode("A".codeUnitAt(0) + cell);
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}