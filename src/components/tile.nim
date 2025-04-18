web thing tile:
  use thing move

  input number: int = 0
  input isNew: bool = false
  input move: Move
  input mergedDistance: int = -1
  input mergedFromDir: MoveDir = mdNone
  input mergedNumber: int = 0

  proc getColor(number: int): string =
    case number
    of 2:
      return "var(--tile-two-color)"
    of 4:
      return "var(--tile-four-color)"
    of 8:
      return "var(--tile-eight-color)"
    of 16:
      return "var(--tile-sixteen-color)"
    of 32:
      return "var(--tile-thirty-two-color)"
    else: discard
    if number <= 2048:
      return "var(--tile-above-color)"
    else:
      return "var(--tile-last-color)"


  var numberText = ""
  var color = "transparent"
  var textColor = "var(--tile-text-color)"
  if number != 0:
    numberText = $(number)
    if number > 4:
      textColor = "var(--tile-secondary-text-color)"

    color = getColor(number)

  var styles = newStyles()
  styles.backgroundColor = "var(--tile-empty-color)"
  styles.borderRadius    = "var(--tile-border-radius)"
  styles.aspectRatio     = "1 / 1"
  styles.width           = "calc(25% - (var(--tile-border-width) * 5))"
  styles.position        = "relative"  # Added to allow for overlay of merge animations

  var fontSize = "4vh"
  var fontWeight = "650"

  var foregroundStyles = newStyles()
  foregroundStyles.backgroundColor  = color
  foregroundStyles.aspectRatio      = "1 / 1"
  foregroundStyles.width            = "100%"
  foregroundStyles.height           = "100%"
  foregroundStyles.overflow         = "hidden"
  foregroundStyles.borderRadius     = "var(--tile-border-radius)"
  foregroundStyles.display          = "flex"
  foregroundStyles.justifyContent   = "center"
  foregroundStyles.alignItems       = "center"
  foregroundStyles.fontSize         = fontSize
  foregroundStyles.fontWeight       = fontWeight
  foregroundStyles.color            = textColor
  
  if number != 0:
    styles.zIndex = "2"

  # Handle different animation cases
  if isNew:
    foregroundStyles.animation      = "growIn 0.2s ease-out forwards"
    foregroundStyles.animationDelay = "0.85s"
    foregroundStyles.opacity        = "0"
  
  # Set up movement animation if needed
  if move.distance > 0:
    # For moving tiles, play the slide animation
    var name = ""
    case move.dir:
    of mdLeft:
      name = "slideFromRight" & $(move.distance)
    of mdRight:
      name = "slideFromLeft" & $(move.distance)
    of mdUp:
      name = "slideFromDown" & $(move.distance)
    of mdDown:
      name = "slideFromUp" & $(move.distance)
    else:
      name = ""
    styles.animation = name & " 0.2s ease-out"

  var content = web:
    p:
      numberText

    
  # Prepare any additional components for merges
  var mergeComponents: HTML = @[]
  if mergedDistance > 0:
    var mergeEffectStyle = newStyles()
    mergeEffectStyle.position       = "absolute"
    mergeEffectStyle.top            = "0"
    mergeEffectStyle.left           = "0"
    mergeEffectStyle.width          = "100%"
    mergeEffectStyle.height         = "100%"
    mergeEffectStyle.borderRadius   = "var(--tile-border-radius)"
    mergeEffectStyle.zIndex         = "1"
    mergeEffectStyle.animation      = "mergeEffect 0.3s ease-out forwards"
    mergeEffectStyle.animationDelay = "0.2s"
    
    let mergedNumberStr = $(mergedNumber)

    var mergeFromStyle = newStyles()
    mergeFromStyle.position        = "absolute"
    mergeFromStyle.top             = "0"
    mergeFromStyle.left            = "0"
    mergeFromStyle.width           = "100%"
    mergeFromStyle.height          = "100%"
    mergeFromStyle.display         = "flex"
    mergeFromStyle.justifyContent  = "center"
    mergeFromStyle.alignItems      = "center"
    mergeFromStyle.borderRadius   = "var(--tile-border-radius)"
    mergeFromStyle.fontSize        = fontSize
    mergeFromStyle.fontWeight      = fontWeight
    mergeFromStyle.color           = textColor
    mergeFromStyle.backgroundColor = getColor(mergedNumber)

    var name = ""
    case mergedFromDir:
    of mdLeft:
      name = "slideFromLeft" & $(mergedDistance)
    of mdRight:
      name = "slideFromRight" & $(mergedDistance)
    of mdUp:
      name = "slideFromUp" & $(mergedDistance)
    of mdDown:
      name = "slideFromDown" & $(mergedDistance)
    else:
      name = ""
    mergeFromStyle.animation = name & " 0.2s ease-out, mergeFrom 0.2s forwards"
    # mergeFromStyle.animation 

    # Create a merge effect element
    mergeComponents = web:
      box:
        style mergeEffectStyle
      
      box:
        style mergeFromStyle
        mergedNumberStr

  return web:
    style:
      @keyframes growIn:
        "0%":
          transform: scale(0)
          opacity: 0.5
        "90%":
          transform: scale(1.2)
          opacity: 0.9
        "100%":
          transform: scale(1)
          opacity: 1
      
      @keyframes mergeEffect:
        "0%":
          boxShadow: "0 0 0 0 rgba(255, 255, 255, 0.7)"
          opacity: 0.7
        "100%":
          boxShadow: "0 0 0 20px rgba(255, 255, 255, 0)"
          opacity: 0
      
      @keyframes mergeFrom:
        "0%":
          opacity: 1
        "70%":
          opacity: 1
        "90%":
          opacity: 0
        "100%":
          opacity: 0

      @keyframes slideFromLeft1:
        "0%":
          transform: "translateX(calc(-100% - var(--tile-border-width) * 4))"
        "85%":
          transform: "translateX(0.25rem)"
        "100%":
          transform: "translateX(0)"

      @keyframes slideFromLeft2:
        "0%":
          transform: "translateX(calc(-200% - var(--tile-border-width) * 8))"
        "85%":
          transform: "translateX(0.5rem)"
        "100%":
          transform: "translateX(0)"

      @keyframes slideFromLeft3:
        "0%":
          transform: "translateX(calc(-300% - var(--tile-border-width) * 12))"
        "85%":
          transform: "translateX(0.75rem)"
        "100%":
          transform: "translateX(0)"

      @keyframes slideFromRight1:
        "0%":
          transform: "translateX(calc(100% + var(--tile-border-width) * 4))"
        "85%":
          transform: "translateX(-0.25rem)"
        "100%":
          transform: "translateX(0)"

      @keyframes slideFromRight2:
        "0%":
          transform: "translateX(calc(200% + var(--tile-border-width) * 8))"
        "85%":
          transform: "translateX(-0.5rem)"
        "100%":
          transform: "translateX(0)"

      @keyframes slideFromRight3:
        "0%":
          transform: "translateX(calc(300% + var(--tile-border-width) * 12))"
        "85%":
          transform: "translateX(-0.75rem)"
        "100%":
          transform: "translateX(0)"

      @keyframes slideFromUp1:
        "0%":
          transform: "translateY(calc(-100% - var(--tile-border-width) * 4))"
        "85%":
          transform: "translateY(0.25rem)"
        "100%":
          transform: "translateY(0)"

      @keyframes slideFromUp2:
        "0%":
          transform: "translateY(calc(-200% - var(--tile-border-width) * 8))"
        "85%":
          transform: "translateY(0.5rem)"
        "100%":
          transform: "translateY(0)"

      @keyframes slideFromUp3:
        "0%":
          transform: "translateY(calc(-300% - var(--tile-border-width) * 12))"
        "85%":
          transform: "translateY(0.75rem)"
        "100%":
          transform: "translateY(0)"

      @keyframes slideFromDown1:
        "0%":
          transform: "translateY(calc(100% + var(--tile-border-width) * 4))"
        "85%":
          transform: "translateY(-0.25rem)"
        "100%":
          transform: "translateY(0)"

      @keyframes slideFromDown2:
        "0%":
          transform: "translateY(calc(200% + var(--tile-border-width) * 8))"
        "85%":
          transform: "translateY(-0.5rem)"
        "100%":
          transform: "translateY(0)"

      @keyframes slideFromDown3:
        "0%":
          transform: "translateY(calc(300% + var(--tile-border-width) * 12))"
        "85%":
          transform: "translateY(-0.75rem)"
        "100%":
          transform: "translateY(0)"

    box:
      box:
        name "tile-foreground"
        style foregroundStyles
        content
      # Insert merge animation components
      mergeComponents
      name "tile"
      style styles
      