package azeus.ojt2020.unblockme;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "puzzle")
public class Puzzle implements Serializable {
  private static final long serialVersionUID = -2343243243242432341L;

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private long id;

  @Column(name = "string")
  private String puzzleString;

  protected Puzzle() {
  }

  public Puzzle(long id, String puzzleString) {
    this.id = id;
    this.puzzleString = puzzleString;
  }

  public long getId() {
    return id;
  }

  public String getPuzzleString() {
    return puzzleString;
  }
}