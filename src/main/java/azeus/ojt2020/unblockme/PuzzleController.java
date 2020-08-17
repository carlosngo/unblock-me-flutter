package azeus.ojt2020.unblockme;

import azeus.ojt2020.unblockme.Puzzle;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class PuzzleController {
  @Autowired
  PuzzleRepository repository;

  @GetMapping("/puzzles")
  public List<Puzzle> puzzles() {
    List<Puzzle> puzzles = repository.findAll();
    return puzzles;
  }

  @GetMapping("/puzzle")
  public Puzzle puzzle(
      @RequestParam(
        value = "id", 
        defaultValue= "1"
      ) String puzzleString) {
    Puzzle puzzle = null;
    return puzzle;
  }
}