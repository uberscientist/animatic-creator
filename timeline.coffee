#[ms after last frame, frame-file]
#animatic = [[0, "4.png"]
#            [150, "3.png"]
#            [180, "2.png"]
#            [280, "1.png"]]

delay = (ms, func) -> setTimeout func, ms

window.onload = () ->
  #create empties
  window.frame_index = 0
  window.animatic = []
  window.frames = {}

  #initialize drawing canvas
  window.initCanvas()
  window.initTabs()
  window.initOnion()

  #Setup onplaying event listener to start animatic
  audio = document.getElementById("audio")
  audio.addEventListener("playing", (e) -> startAnimatic())

window.addFrame = () ->
  name = document.getElementById("insert-pic-select").value
  if name
    frame = [300, name] #create animatic frame, 300ms default and frame-name
    window.animatic.push(frame)
    drawTimeline(window.animatic)

window.drawTimeline = () ->
  timeline = document.getElementById("timeline-table")

  timeline.innerHTML = '<th>Thumb</th><th>Image</th><th>Duration</th>'

  for frame, index in animatic
    if frame != null
      duration = frame[0]
      frame_name = frame[1]

      chunk_tr = document.createElement("tr")
      chunk_td_thumb = document.createElement("td")
      chunk_td_image = document.createElement("td")
      chunk_td_duration = document.createElement("td")

      thumb_img = document.createElement("img")
      thumb_img.id = "thumb-#{index}"
      thumb_img.height = 75
      thumb_img.width = 100
      thumb_img.src = window.frames[frame_name]

      select = document.getElementById("insert-pic-select")
      select_clone = select.cloneNode(true)
      select_clone.value = frame_name
      select_clone.index = index

      duration_input = document.createElement("input")
      duration_input.value = duration
      duration_input.index = index
      duration_input.type = 'number'

      delete_link = document.createElement("a")
      delete_link.innerText = "del"
      delete_link.href = "#"
      delete_link.index = index

      chunk_td_thumb.appendChild(thumb_img)
      chunk_td_image.appendChild(select_clone)
      chunk_td_duration.appendChild(duration_input)
      chunk_td_duration.appendChild(delete_link)

      chunk_tr.appendChild(chunk_td_thumb)
      chunk_tr.appendChild(chunk_td_image)
      chunk_tr.appendChild(chunk_td_duration)

      #setup event listeners
      select_clone.addEventListener("change", () ->
        animatic[@index][1] = @value
        thumb = document.getElementById("thumb-#{@index}")
        thumb.src = window.frames[@value]
      )
      duration_input.addEventListener("blur", () ->
        animatic[@index][0] = parseInt(@value)
      )
      delete_link.addEventListener("click", () ->
        window.animatic.splice(parseInt(@index),1)
        drawTimeline()
      )

      timeline.appendChild(chunk_tr)

startAnimatic = () ->
  timeOffset = 0
  view = document.getElementById("view")
  file = 1

  for frame in animatic
    image = window.frames[frame[1]]
    do (image) ->
      timeOffset += frame[0]
      delay timeOffset, -> view.style.backgroundImage = "url('#{image}')"
