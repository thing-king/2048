web thing grid:
  use thing tile
  use thing tileRow
  use thing move
  use random

  type Tile = object
    value: int
    isNew: bool
    move: Move
    mergedDistance: int  # Changed from tuple to a single integer
    mergedNumber: int  # Added to store the value of the merged tile
    mergedFromDir: MoveDir  # Direction from which the tile was merged

  var styles = newStyles()
  styles.backgroundColor = "var(--tile-background-color)"
  styles.borderRadius    = "var(--tile-border-radius)"
  styles.aspectRatio     = "1 / 1"
  styles.width           = "var(--tile-board-size)"
  styles.position        = "absolute"
  styles.display         = "flex"
  styles.flexDirection   = "column"
  styles.justifyContent  = "space-evenly"

  proc randomNumber(): int =
    if rand(100) < 90:
      return 2
    else:
      return 4

  var initialRows: array[4, array[4, Tile]]
  for i in 0 ..< 4:
    for j in 0 ..< 4:
      initialRows[i][j] = Tile(value: 0, isNew: false, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)
  var randomPos1 = (rand(3), rand(3))
  var randomPos2 = (rand(3), rand(3))
  while randomPos1 == randomPos2:
    randomPos2 = (rand(3), rand(3))
  initialRows[randomPos1[0]][randomPos1[1]] = Tile(value: randomNumber(), isNew: true, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)
  initialRows[randomPos2[0]][randomPos2[1]] = Tile(value: randomNumber(), isNew: true, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)

  let (rows, setRows, updateRows) = useState(initialRows)

  var gridBody: HTML = @[]
  for i in 0 ..< 4:
    var row: HTML = @[]
    for j in 0 ..< 4:
      let tile = tile(
        number = rows[i][j].value, 
        isNew = rows[i][j].isNew, 
        move = rows[i][j].move,
        mergedDistance = rows[i][j].mergedDistance,
        mergedNumber = rows[i][j].mergedNumber,
        mergedFromDir = rows[i][j].mergedFromDir
      )
      row.add(tile)
    gridBody.add(tileRow(children = row))

  useEffect(proc() {.gcsafe.} =
    proc handleKeyPress(e: Event) {.gcsafe.} =
      let keyEvent = cast[KeyboardEvent](e)
      let key = ($keyEvent.key).toLowerAscii()

      if key in ["w", "arrowup", "s", "arrowdown", "a", "arrowleft", "d", "arrowright"]:
        keyEvent.preventDefault()

        updateRows(proc(oldRows: array[4, array[4, Tile]]): array[4, array[4, Tile]] {.gcsafe.} =
          var newRows: array[4, array[4, Tile]]
          # Create a copy of the old state and reset move info
          for i in 0 ..< 4:
            for j in 0 ..< 4:
              newRows[i][j] = Tile(
                value: oldRows[i][j].value,
                isNew: false,
                move: Move(dir: mdNone, distance: 0),
                mergedDistance: 0,
                mergedNumber: 0,
                mergedFromDir: mdNone
              )
          
          var moved = false

          if key in ["a", "arrowleft"]:
            for i in 0 ..< 4:
              var nonZeros: seq[int] = @[]
              var positions: seq[int] = @[]
              
              # Collect non-zero values and their positions
              for j in 0 ..< 4:
                if newRows[i][j].value != 0:
                  nonZeros.add(newRows[i][j].value)
                  positions.add(j)
              
              # Process merges
              var merged: seq[int] = @[]
              var mergeInfo: seq[tuple[mergedPos: int, mergedVal: int]] = @[]
              var j = 0
              
              while j < nonZeros.len:
                if j + 1 < nonZeros.len and nonZeros[j] == nonZeros[j + 1]:
                  # This is a merge - track the position and value of the merged tile
                  merged.add(nonZeros[j] * 2)
                  # Calculate the merge distance - how far the second tile traveled
                  let mergeDistance = if j + 1 < positions.len: positions[j+1] - j else: 0
                  mergeInfo.add((mergedPos: mergeDistance, mergedVal: nonZeros[j]))
                  j += 2
                else:
                  merged.add(nonZeros[j])
                  mergeInfo.add((mergedPos: 0, mergedVal: 0))  # No merge
                  j += 1
              
              # Clear the row first
              for j in 0 ..< 4:
                newRows[i][j] = Tile(value: 0, isNew: false, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)
              
              # Apply new state
              j = 0
              while j < merged.len:
                # Calculate correct distance for the move
                let distance = if j < positions.len: positions[j] - j else: 0
                
                # Set up the tile with proper merge info
                newRows[i][j] = Tile(
                  value: merged[j], 
                  isNew: false, 
                  move: Move(dir: mdLeft, distance: distance),
                  mergedDistance: mergeInfo[j].mergedPos,
                  mergedNumber: mergeInfo[j].mergedVal,
                  mergedFromDir: if mergeInfo[j].mergedVal != 0: mdRight else: mdNone  # Coming from right to left
                )
                
                moved = true
                j += 1

          elif key in ["d", "arrowright"]:
            for i in 0 ..< 4:
              var nonZeros: seq[int] = @[]
              var positions: seq[int] = @[]
              
              # Collect non-zero values and their positions (from right to left)
              for j in countdown(3, 0):
                if newRows[i][j].value != 0:
                  nonZeros.add(newRows[i][j].value)
                  positions.add(j)
              
              # Process merges
              var merged: seq[int] = @[]
              var mergeInfo: seq[tuple[mergedPos: int, mergedVal: int]] = @[]
              var j = 0
              
              while j < nonZeros.len:
                if j + 1 < nonZeros.len and nonZeros[j] == nonZeros[j + 1]:
                  # This is a merge
                  merged.add(nonZeros[j] * 2)
                  # Calculate the merge distance for right movement
                  let mergeDistance = if j + 1 < positions.len: (3 - j) - positions[j+1] else: 0
                  mergeInfo.add((mergedPos: mergeDistance, mergedVal: nonZeros[j]))
                  j += 2
                else:
                  merged.add(nonZeros[j])
                  mergeInfo.add((mergedPos: 0, mergedVal: 0))  # No merge
                  j += 1
              
              # Clear the row first
              for j in 0 ..< 4:
                newRows[i][j] = Tile(value: 0, isNew: false, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)
              
              # Apply new state
              j = 0
              while j < merged.len:
                let targetPos = 3 - j
                
                # Calculate correct distance for the move
                let originalPos = if j < positions.len: positions[j] else: targetPos
                let distance = targetPos - originalPos
                
                # Set up the tile with proper merge info
                newRows[i][targetPos] = Tile(
                  value: merged[j], 
                  isNew: false, 
                  move: Move(dir: mdRight, distance: distance),
                  mergedDistance: mergeInfo[j].mergedPos,
                  mergedNumber: mergeInfo[j].mergedVal,
                  mergedFromDir: if mergeInfo[j].mergedVal != 0: mdLeft else: mdNone  # Coming from left to right
                )
                
                moved = true
                j += 1

          elif key in ["w", "arrowup"]:
            for j in 0 ..< 4:
              var nonZeros: seq[int] = @[]
              var positions: seq[int] = @[]
              
              # Collect non-zero values and their positions
              for i in 0 ..< 4:
                if newRows[i][j].value != 0:
                  nonZeros.add(newRows[i][j].value)
                  positions.add(i)
              
              # Process merges
              var merged: seq[int] = @[]
              var mergeInfo: seq[tuple[mergedPos: int, mergedVal: int]] = @[]
              var i = 0
              
              while i < nonZeros.len:
                if i + 1 < nonZeros.len and nonZeros[i] == nonZeros[i + 1]:
                  # This is a merge
                  merged.add(nonZeros[i] * 2)
                  # Calculate the merge distance for upward movement
                  let mergeDistance = if i + 1 < positions.len: positions[i+1] - i else: 0
                  mergeInfo.add((mergedPos: mergeDistance, mergedVal: nonZeros[i]))
                  i += 2
                else:
                  merged.add(nonZeros[i])
                  mergeInfo.add((mergedPos: 0, mergedVal: 0))  # No merge
                  i += 1
              
              # Clear the column first
              for i in 0 ..< 4:
                newRows[i][j] = Tile(value: 0, isNew: false, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)
              
              # Apply new state
              i = 0
              while i < merged.len:
                # Calculate correct distance for the move
                let originalPos = if i < positions.len: positions[i] else: i
                let distance = originalPos - i
                
                # Set up the tile with proper merge info
                newRows[i][j] = Tile(
                  value: merged[i], 
                  isNew: false, 
                  move: Move(dir: mdUp, distance: distance),
                  mergedDistance: mergeInfo[i].mergedPos,
                  mergedNumber: mergeInfo[i].mergedVal,
                  mergedFromDir: if mergeInfo[i].mergedVal != 0: mdDown else: mdNone  # Coming from bottom to top
                )
                
                moved = true
                i += 1

          elif key in ["s", "arrowdown"]:
            for j in 0 ..< 4:
              var nonZeros: seq[int] = @[]
              var positions: seq[int] = @[]
              
              # Collect non-zero values and their positions (from bottom to top)
              for i in countdown(3, 0):
                if newRows[i][j].value != 0:
                  nonZeros.add(newRows[i][j].value)
                  positions.add(i)
              
              # Process merges
              var merged: seq[int] = @[]
              var mergeInfo: seq[tuple[mergedPos: int, mergedVal: int]] = @[]
              var i = 0
              
              while i < nonZeros.len:
                if i + 1 < nonZeros.len and nonZeros[i] == nonZeros[i + 1]:
                  # This is a merge
                  merged.add(nonZeros[i] * 2)
                  # Calculate the merge distance for downward movement
                  let mergeDistance = if i + 1 < positions.len: (3 - i) - positions[i+1] else: 0
                  mergeInfo.add((mergedPos: mergeDistance, mergedVal: nonZeros[i]))
                  i += 2
                else:
                  merged.add(nonZeros[i])
                  mergeInfo.add((mergedPos: 0, mergedVal: 0))  # No merge
                  i += 1
              
              # Clear the column first
              for i in 0 ..< 4:
                newRows[i][j] = Tile(value: 0, isNew: false, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)
              
              # Apply new state
              i = 0
              while i < merged.len:
                let targetPos = 3 - i
                
                # Calculate correct distance for the move
                let originalPos = if i < positions.len: positions[i] else: targetPos
                let distance = targetPos - originalPos
                
                # Set up the tile with proper merge info
                newRows[targetPos][j] = Tile(
                  value: merged[i], 
                  isNew: false, 
                  move: Move(dir: mdDown, distance: distance),
                  mergedDistance: mergeInfo[i].mergedPos,
                  mergedNumber: mergeInfo[i].mergedVal,
                  mergedFromDir: if mergeInfo[i].mergedVal != 0: mdUp else: mdNone  # Coming from top to bottom
                )
                
                moved = true
                i += 1

          if moved:
            var emptyPositions: seq[(int, int)] = @[]
            for i in 0 ..< 4:
              for j in 0 ..< 4:
                if newRows[i][j].value == 0:
                  emptyPositions.add((i, j))
            if emptyPositions.len > 0:
              let randomIndex = rand(emptyPositions.len - 1)
              let (i, j) = emptyPositions[randomIndex]
              newRows[i][j] = Tile(value: randomNumber(), isNew: true, move: Move(dir: mdNone, distance: 0), mergedDistance: 0, mergedNumber: 0, mergedFromDir: mdNone)

          return newRows
        )

    window.addEventListener("keydown", handleKeyPress)
  , [])

  let grid = web:
    box:
      style styles
      gridBody

  return web:
    grid

echo toBody(grid)