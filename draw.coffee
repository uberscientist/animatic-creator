$ = (id) -> document.getElementById(id)

drawing = false
drop = false

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
  color_select = $("color")
  color = "##{color_select.value}"
  x = e.offsetX
  y = e.offsetY

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
      pixelStack = []
      
      #Makes colorjs rgb canvas rgba
      fillColor = color_select.color.rgb.map (value) -> Math.round(value * 255)
      fillColor.push(255)

      data = context.getImageData(0,0,640,400)
      pixels = data.data

      originalPos = (y * 640 + x) * 4
      originalPix = ''
      for i in [0..3]
        originalPix += pixels[originalPos + i]

      pixelStack.push([x,y])

      while pixelStack.length > 0
        coord = pixelStack.pop()
        px = coord[0]
        py = coord[1]
        scanPos = ((py--) * 640 + px) * 4

        while comparePix(originalPix, scanPos, pixels) and py > 0
          scanPos = ((py--) * 640 + px) * 4
        
          rightPos = (py * 640 + px + 2) * 4
          leftPos = (py * 640 + px - 2) * 4
          if comparePix(originalPix, rightPos, pixels) and px < 640
            console.log "left push"
            pixelStack.push([px + 1,py])
          if comparePix(originalPix, leftPos, pixels) and px > 0
            pixelStack.push([px - 1,py])
            console.log "right push"

        paintPos = (py+=1 * 640 + px) * 4

        while comparePix(originalPix, paintPos, pixels) and py < 400
          for i in [0..3]
            pixels[paintPos + i] = fillColor[i]
          paintPos = (py++ * 640 + px) * 4
      
      context.putImageData(data,0,0)

comparePix = (originalPix, pixPosB, pixels) ->
  pixB = ''
  for i in [0..3]
    pixB += pixels[pixPosB + i].toString()
  if originalPix == pixB then return true else return false

window.initTools = () ->
  tools = document.getElementsByClassName("tool")
  for tool in tools
    tool.addEventListener("click", (e) ->
      if @id == "clear"
        window.clearCanvas("draw")
      else
        window.tool = @id
    )
