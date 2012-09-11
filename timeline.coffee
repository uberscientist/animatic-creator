#[ms after last frame, frame-name]
#animatic = [[0, "4"]
#            [150, "3"]
#            [180, "2"]
#            [280, "1"]]
$ = (id) -> document.getElementById(id)
delay = (ms, func) -> animation = setTimeout func, ms
Array.prototype.swap = (a,b) ->
  this[a] = @splice(b, 1, this[a])[0]
  return this

nextOffset = 300
scale = .1

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

  $("scale-range").addEventListener("change", (e) ->
    scale = @value
    drawTimeline()
  )

window.addFrame = () ->
  name = $("insert-pic-select").value
  if name
    time = nextOffset
    #reset offset to default once used
    frame = [time, name] #create animatic frame
    window.animatic.push(frame)
    drawTimeline(window.animatic)

window.drawTimeline = () ->
  
  resizeEnable = false
  resizing = null
  dragged = null
  origWidth = null
  resizeStartX = null

  #Remove chunks in order to draw them again
  timeline = $("timeline")
  if timeline
    timeline.parentNode.removeChild(timeline)

  #Create timeline div to contain chunk divs
  timeline = document.createElement("div")
  timeline.id = "timeline"

  #Create chunks
  for frame, index in animatic
    if frame != null
      offset = frame[0]
      frame_name = frame[1]

      #Clone frame select
      select = $("insert-pic-select")
      select_clone = select.cloneNode(true)
      select_clone.value = frame_name
      select_clone.index = index

      #Delete hyperlink
      delete_link = document.createElement("a")
      delete_link.innerText = "del"
      delete_link.href = "#"
      delete_link.index = index

      #Resizable timing chunk
      chunk_div = document.createElement("div")

      #Add background image
      chunk_div.style.backgroundImage = "url('#{window.frames[frame_name]}')"
      chunk_div.style.backgroundSize = "64px 48px"

      #Set initial width
      chunk_div.style.width = animatic[index][0] * scale + "px"

      chunk_div.className = "chunk"
      chunk_div.index = index
      chunk_div.id = "chunk-" + index
      chunk_div.appendChild(select_clone)
      chunk_div.appendChild(delete_link)

      timeline.appendChild(chunk_div)

      #resize event listeners
      chunk_div.addEventListener("mouseout", (e) ->
        document.body.style.cursor = "default"
        resizeEnable = false
      )

      chunk_div.addEventListener("mousemove", (e) ->
        x = e.offsetX
        chunkWidth = parseInt(@style.width.match(/\d*/))

        if x > chunkWidth - 20 and x < chunkWidth - 5
          @draggable = false
          document.body.style.cursor = "col-resize"
          resizeEnable = true
        else
          document.body.style.cursor = "move"
          resizeEnable = false
          @draggable = true
      )

      chunk_div.addEventListener("mousedown", (e) ->
        if resizeEnable
          resizing = this
      )

      #setup frame options event listeners
      select_clone.addEventListener("change", () ->
        animatic[@index][1] = @value
        drawTimeline()
      )

      delete_link.addEventListener("click", () ->
        window.animatic.splice(parseInt(@index),1)
        drawTimeline()
      )

      #Dragging chunks event listeners
      chunk_div.addEventListener("dragstart", () ->
        @style.opacity = '0.4'
        dragged = this
      )
      chunk_div.addEventListener("dragend", () ->
        @style.opacity = '1'
        dragged = null
      )
      chunk_div.addEventListener("dragover", (e) ->
        if (e.preventDefault)
          e.preventDefault() #Allows us to drop...
        @style.borderLeft = "2px red dotted"
      )
      chunk_div.addEventListener("dragleave", () ->
        @style.borderLeft = ""
      )
      chunk_div.addEventListener("drop", (e) -> #emitted from dropped on element
        if(e.stopPropagation)
          e.stopPropagation()

          draggged = window.animatic[dragged.index]
          spliceOffset = if dragged.index > @index then 1 else 0
          window.animatic.splice(@index,0,window.animatic[dragged.index])
          window.animatic.splice(dragged.index + spliceOffset, 1)

          @style.borderLeft = ""
          drawTimeline()
      )

  #Finally append timeline to container
  timeline_container = $("timeline-container")
  timeline_container.appendChild(timeline)
  
  #Fix floating in a div problemo
  clearDiv = document.createElement("div")
  clearDiv.style.clear = "both"
  timeline_container.appendChild(clearDiv)

  #Timeline event listeners for resizing chunks
  timeline_container.addEventListener("mousedown", (e) ->
    if resizing
      resizeStartX = e.pageX
      origWidth = parseInt(resizing.style.width.match(/\d*/))
  )

  timeline_container.addEventListener("mousemove", (e) ->
    if resizing
      resizing.style.width = origWidth + (e.pageX - resizeStartX) + "px"
  )

  timeline_container.addEventListener("mouseup", (e) ->
    if resizing
      width = parseInt(resizing.style.width.match(/\d*/))
      index = resizing.index
      animatic[index][0] = Math.round(width / scale)

      resizing = null
  )

startAnimatic = () ->
  timeOffset = 0
  view = $("view")

  for frame, index in animatic
    if frame
      image = window.frames[frame[1]]
      do (image) ->
          if index == 0
            timeOffset = 0
          else
            timeOffset += window.animatic[index - 1][0]
          delay timeOffset, -> view.style.backgroundImage = "url('#{image}')"
