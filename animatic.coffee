#[ms after last frame, frame-file]
animatic = [[0, "4.png"]
            [150, "3.png"]
            [180, "2.png"]
            [280, "1.png"]]

delay = (ms, func) -> setTimeout func, ms

addLoadEvent = (func) ->
  oldonload = window.onload
  if !window.onload
    window.onload = func
  else
    window.onload = () ->
      if oldonload
        oldonload()
      func()

addLoadEvent(()  ->
  audio = document.getElementById("audio")
  audio.addEventListener("playing", (e) -> startAnimatic())
)

startAnimatic = () ->
  #console.log "started animatic"
  timeOffset = 0
  view = document.getElementById("view")
  file = 1

  for frame in animatic
    image = frame[1]
    do (image) ->
      timeOffset += frame[0]
      delay timeOffset, -> view.style.backgroundImage = "url('#{image}')"
