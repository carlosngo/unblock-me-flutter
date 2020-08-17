package azeus.ojt2020.unblockme;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import azeus.ojt2020.unblockme.Puzzle;

import java.util.List;


@Repository
public interface PuzzleRepository extends JpaRepository<Puzzle, Long> {
  List<Puzzle> findAll(); 
}