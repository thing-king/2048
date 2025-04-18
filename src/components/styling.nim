web thing styling:
  return web:
    style:
      import url("https://fonts.googleapis.com/css2?family=Rubik:ital,wght@0,300..900;1,300..900&display=swap")
      
      [root]:
        --tile-board-size: "50vh"
        --tile-border-width-ratio: 300
        --tile-border-radius-ratio: 45

        --background-color: "#faf8f0"
        --tile-background-color: "#9c8a7b"
        --tile-border-width: "calc(var(--tile-board-size) / var(--tile-border-width-ratio))"
        --tile-border-radius: "calc(var(--tile-board-size) / var(--tile-border-radius-ratio))"
        
        --tile-text-color: "#756452"
        --tile-secondary-text-color: "#ffffff"
        
        --tile-empty-color: "#bdac97"
        --tile-two-color: "#eee4da"
        --tile-four-color: "#ebd8b6"
        --tile-eight-color: "#f2b177"
        --tile-sixteen-color: "#f69462"
        --tile-thirty-two-color: "#f77f63"
        --tile-sixty-four-color: "#f76543"
        --tile-above-color: "#f0d26c"
        --tile-last-color: "#3d3a32"

      [_]:
        font-family: "'Rubik', sans-serif"

      body:
        backgroundColor: "var(--background-color)"
      # [root]:




