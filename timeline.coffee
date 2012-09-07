#[ms after last frame, frame-name]
#animatic = [[0, "4"]
#            [150, "3"]
#            [180, "2"]
#            [280, "1"]]
$ = (id) -> document.getElementById(id)
delay = (ms, func) -> setTimeout func, ms

window.onload = () ->
  #create empties
  window.frame_index = 0
  window.animatic = []
  window.frames = {}

  #initialize drawing canvas
  window.initCanvas()
  window.initTools()
  window.initTabs()
  window.initOnion()

  #Setup onplaying event listener to start animatic
  $("audio").addEventListener("playing", (e) -> startAnimatic())

window.addFrame = () ->
  name = $("insert-pic-select").value
  if name
    time = if window.animatic.length < 1 then 0 else 300
    frame = [time, name] #create animatic frame
    window.animatic.push(frame)
    drawTimeline(window.animatic)

window.drawTimeline = () ->

  for frame, index in animatic
    if frame != null
      duration = frame[0]
      frame_name = frame[1]

      #Thumbnail element
      thumb_img = document.createElement("img")
      thumb_img.id = "thumb-#{index}"
      thumb_img.height = 75
      thumb_img.width = 100
      thumb_img.src = window.frames[frame_name]

      #Clone frame select
      select = $("insert-pic-select")
      select_clone = select.cloneNode(true)
      select_clone.value = frame_name
      select_clone.index = index

      #ms duration input element
      duration_input = document.createElement("input")
      duration_input.value = duration
      duration_input.index = index
      duration_input.type = 'number'

      #Delete hyperlink
      delete_link = document.createElement("a")
      delete_link.innerText = "del"
      delete_link.href = "#"
      delete_link.index = index

      #Resizable timing chunk
      chunk_div = document.createElement("div")
      chunk_div.index = index

      chunk_div.appendChild(thumb_img)
      chunk_div.appendChild(select_clone)
      chunk_div.appendChild(duration_input)
      chunk_div.appendChild(delete_link)

      $("timeline-div").appendChild(chunk_div)

      #setup event listeners
      select_clone.addEventListener("change", () ->
        animatic[@index][1] = @value
        thumb = $("thumb-#{@index}")
        thumb.src = window.frames[@value]
      )
      duration_input.addEventListener("blur", () ->
        animatic[@index][0] = parseInt(@value)
      )
      delete_link.addEventListener("click", () ->
        window.animatic.splice(parseInt(@index),1)
        drawTimeline()
      )

startAnimatic = () ->
  timeOffset = 0
  view = $("view")
  file = 1

  for frame in animatic
    if frame
      image = window.frames[frame[1]]
      do (image) ->
          timeOffset += frame[0]
          delay timeOffset, -> view.style.backgroundImage = "url('#{image}')"
