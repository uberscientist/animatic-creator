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
  name = document.getElementById("save-frame-name")
  window.frames[name.value] = data_url
  name.value = ''
  clearCanvas("draw")
  createFrameList()

clearCanvas = (canvas_id) ->
  canvas = document.getElementById(canvas_id)
  context = canvas.getContext("2d")
  context.clearRect(0, 0, canvas.width, canvas.height)

createFrameList = () ->
  select = document.getElementById("insert-pic-select")
  select.options.length = 0 #clear options

  for name of window.frames #repopulate options
    select.options[select.options.length] = new Option(name, name)

  select.value = name #default to created frame
  createOnionSkinSelect(select)

turnOnOnion = () ->
  name = document.getElementById("onion-select").value
  onion_toggle = document.getElementById("onion-toggle")
  clearCanvas("onion-canvas")

  if onion_toggle.checked
    onion_canvas = document.getElementById("onion-canvas")
    context = onion_canvas.getContext("2d")
    context.globalAlpha = .2
    img_obj = new Image()
    img_obj.src = window.frames[name]
    img_obj.onload = () ->
      context.drawImage(img_obj, 0, 0)

createOnionSkinSelect = (select) ->
  #Create onion select list
  draw_container = document.getElementById("draw-container")
  select_clone = select.cloneNode(true)
  select_clone.id = 'onion-select'
  onion_select = document.getElementById("onion-select")
  onion_select.parentNode.removeChild(onion_select) if onion_select
  draw_container.appendChild(select_clone)
  onion_select = document.getElementById("onion-select")

  onion_toggle = document.getElementById("onion-toggle")

  onion_select.addEventListener("change", () ->
    turnOnOnion()
  )

  onion_toggle.addEventListener("change", (e) ->
    e.stopPropagation()
    turnOnOnion()
  )


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
    context.arc(e.offsetX, e.offsetY, Math.round(width/2), 0, 2 * Math.PI, false)
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
