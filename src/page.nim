import thing

web thing page:
  use thing styling
  use thing grid


  var gridDisplay = newStyles()
  gridDisplay.display = "flex"
  gridDisplay.justifyContent = "center"
  gridDisplay.alignItems = "center"
  gridDisplay.width = "100%"
  gridDisplay.height = "90%"

  return web:
    styling

    h1 "2048"

    box:
      style gridDisplay
      grid