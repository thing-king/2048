web thing tileRow:
  input children: HTML

  var styles = newStyles()
  styles.display = "flex"
  styles.justifyContent = "space-evenly"
  styles.height = "calc(25% - (var(--tile-border-width) * 5))"

  return web:
    box:
      name "tileRow"
      style styles
      children
      

