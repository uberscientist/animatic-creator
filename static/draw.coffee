$ = (id) -> document.getElementById(id)

drawing = false
drop = false

window.initCanvas = () ->
  window.tool = "pencil"

  onionCanvas = $("onion-canvas")
  drawCanvas = $("draw")
  onionContext = onionCanvas.getContext("2d")
  drawContext = drawCanvas.getContext("2d")

  #white background
  drawContext.fillStyle = "#FFF"
  drawContext.fillRect(0,0,drawCanvas.width, drawCanvas.height)

  onionCanvas.addEventListener("mouseover", (e) ->
    document.body.style.cursor = "crosshair"
  )
  onionCanvas.addEventListener("mouseout", (e) ->
    document.body.style.cursor = "default"
  )

  onionCanvas.addEventListener("mousedown", (e) -> activeTool(e))
  onionCanvas.addEventListener("mousemove", (e) -> activeTool(e))
  onionCanvas.addEventListener("mouseup", (e) -> activeTool(e))

window.initTools = () ->
  tools = document.getElementsByClassName("tool")

  for tool in tools
    tool.addEventListener("click", (e) ->
      if @id == "clear"
        window.clearCanvas("draw")
      else
        window.tool = @id

        tools = document.getElementsByClassName("tool")
        srcEl = if e.srcElement then e.srcElement else e.target

        for tool in tools
          tool.style.backgroundColor = "#FFF"

        srcEl.style.backgroundColor = "#C3DBDF"
    )

window.clearCanvas = (canvas_id) ->
  canvas = $(canvas_id)
  context = canvas.getContext("2d")
  context.clearRect(0, 0, canvas.width, canvas.height)

  if canvas_id == "draw"
    context.fillStyle = "#FFF"
    context.fillRect(0,0, canvas.width, canvas.height)

activeTool = (e) ->
  canvas = $("draw")
  context = canvas.getContext("2d")
  width = 3
  color_select = $("color")
  color = "#" + color_select.value
  x = if e.offsetX then e.offsetX else e.layerX
  y = if e.offsetY then e.offsetY else e.layerY

  #Pencil and Eraser
  if window.tool == "pencil" or window.tool == "eraser"
    if window.tool == "pencil"
      width = 3
      context.globalCompositeOperation = "source-over"

    else if window.tool == "eraser"
      width = 10
      context.globalCompositeOperation = "destination-out"

    switch e.type
      when "mousedown"
        drawing = true
        context.fillStyle = color
        context.strokeStyle = color
        context.beginPath() #draw circle
        context.arc(x, y, Math.round(width/2), 0, 2 * Math.PI, false)
        context.fill()
        context.beginPath() #start line
        context.lineCap = "round"
        context.moveTo(x, y)
      when "mousemove"
        if drawing == true
          context.lineTo(x, y)
          context.lineWidth = width
          context.stroke()
      when "mouseup"
        drawing = false

  #Dropper
  else if window.tool == "dropper"
    switch e.type
      when "mousedown"
        drop = true
        pixel = context.getImageData(x, y,1,1).data
        color_select.color.fromRGB(pixel[0]/255, pixel[1]/255, pixel[2]/255)
      when "mouseup"
        drop = false
      when "mousemove"
        if drop == true
          pixel = context.getImageData(x, y,1,1).data
          color_select.color.fromRGB(pixel[0]/255, pixel[1]/255, pixel[2]/255)

  #Fill
  else if window.tool == "fill"
    if e.type == "mouseup"

        canvasWidth = canvas.width
        canvasHeight = canvas.height
        drawingBoundTop = 0
        colorLayer = context.getImageData(0,0,canvasWidth, canvasHeight)
        
        pixelStack = [[x, y]]
        pixelPos = (pixelStack[0][1] * canvasWidth + pixelStack[0][0]) * 4

        startPix = (colorLayer.data[pixelPos + i] for i in [0..3])

        matchStartColor = (pixelPos) ->
          pix = (colorLayer.data[pixelPos + i] for i in [0..3])
          (pix[0] == startPix[0] and pix[1] == startPix[1] and pix[2] == startPix[2] and pix[3] == startPix[3])

        colorPixel = (pixelPos) ->
          for i in [0..2]
            colorLayer.data[pixelPos + i] = Math.round(color_select.color.rgb[i] * 255)
          colorLayer.data[pixelPos+3] = 255

        while pixelStack.length
          newPos = pixelStack.pop()
          x = newPos[0]
          y = newPos[1]
          
          pixelPos = (y*canvasWidth + x) * 4

          while y-- >= drawingBoundTop and matchStartColor(pixelPos)
            pixelPos -= canvasWidth * 4
          
          pixelPos += canvasWidth * 4
          ++y
          reachLeft = false
          reachRight = false
          while y++ < canvasHeight-1 and matchStartColor(pixelPos)
            colorPixel(pixelPos)
            if x > 0
              if matchStartColor(pixelPos - 4)
                if !reachLeft
                  pixelStack.push([x - 1, y])
                  reachLeft = true
              else if reachLeft
                reachLeft = false
            if x < canvasWidth-1
              if matchStartColor(pixelPos + 4)
                if !reachRight
                  pixelStack.push([x + 1, y])
                  reachRight = true
              else if reachRight
                reachRight = false
            pixelPos += canvasWidth * 4
        context.putImageData(colorLayer, 0, 0)
