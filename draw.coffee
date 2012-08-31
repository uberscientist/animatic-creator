#These functions are for the tabs at the top of #view-container
window.displayDraw = () ->
  document.getElementById("audio").style.display = "none"
  document.getElementById("view").style.display = "none"
  document.getElementById("draw-container").style.display = "inline-block"

window.displayAnimatic = () ->
  document.getElementById("audio").style.display = ""
  document.getElementById("view").style.display = ""
  document.getElementById("draw-container").style.display = "none"

window.saveFrame = () ->
  data_url = document.getElementById("draw").toDataURL()
  name = document.getElementById("save-frame-name").value
  window.frames[name] = data_url
  createFrameList()

createFrameList = () ->
  select = document.getElementById("insert-pic-select")
  select.options.length = 0 #clear options

  for name of window.frames #repopulate options
    select.options[select.options.length] = new Option(name, name)

  select.value = name #default to created frame

window.initCanvas = () ->
  canvas = document.getElementById("draw")
  context = canvas.getContext("2d")
  drawing = false
  width = 3

  canvas.addEventListener("mouseover", (e) ->
    document.body.style.cursor = "crosshair"
  )
  canvas.addEventListener("mouseout", (e) ->
    document.body.style.cursor = "default"
  )

  canvas.addEventListener("mousedown", (e) ->
    drawing = true

    context.beginPath() #draw circle
    context.arc(e.offsetX, e.offsetY, width/2, 0, 2 * Math.PI, false)
    context.fillStyle = "#000"
    context.fill()

    context.beginPath() #start line
    context.moveTo(e.offsetX, e.offsetY)
  )
  canvas.addEventListener("mousemove", (e) ->
    document.body.style.cursor = "crosshair"
    if drawing == true
      context.lineTo(e.offsetX, e.offsetY)
      context.strokeStyle = "#000"
      context.lineWidth = width
      context.stroke()
  )
  canvas.addEventListener("mouseup", (e) ->
    drawing = false)
