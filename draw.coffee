$ = (id) -> document.getElementById(id)

drawing = false

window.initCanvas = () ->
  window.tool = "pencil"
  canvas = $("draw")
  context = canvas.getContext("2d")

  canvas.addEventListener("mouseover", (e) ->
    document.body.style.cursor = "crosshair"
  )
  canvas.addEventListener("mouseout", (e) ->
    document.body.style.cursor = "default"
  )

  canvas.addEventListener("mousedown", (e) -> activeTool(e))
  canvas.addEventListener("mousemove", (e) -> activeTool(e))
  canvas.addEventListener("mouseup", (e) -> activeTool(e))

activeTool = (e) ->
  canvas = $("draw")
  context = canvas.getContext("2d")
  width = 3
  color = "##{$("color").value}"

  if window.tool == "pencil"
    width = 3
    context.globalCompositeOperation = "source-over"
    context.fillStyle = color
    context.strokeStyle = color
  else if window.tool == "eraser"
    width = 10
    context.globalCompositeOperation = "destination-out"
    context.strokeStyle = "#000"

  switch e.type
    when "mousedown"
      drawing = true
      context.beginPath() #draw circle
      context.arc(e.offsetX, e.offsetY, Math.round(width/2), 0, 2 * Math.PI, false)
      context.fill()
      context.beginPath() #start line
      context.lineCap = "round"
      context.moveTo(e.offsetX, e.offsetY)
    when "mousemove"
      if drawing == true
        context.lineTo(e.offsetX, e.offsetY)
        context.lineWidth = width
        context.stroke()
    when "mouseup"
      drawing = false

window.initTools = () ->
  tools = document.getElementsByClassName("tool")
  for tool in tools
    tool.addEventListener("click", (e) ->
      if @id == "clear"
        window.clearCanvas("draw")
      else
        window.tool = @id
    )
