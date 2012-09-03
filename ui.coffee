window.initTabs = () ->
  tabs = document.getElementsByClassName("tab")
  for tab in tabs
    tab.addEventListener("click", (e) ->
      for tab in tabs
        tab.style.backgroundColor = "#C3DBDF"
      e.srcElement.style.backgroundColor = "#FFF"
    )

#for the stinkin' onion checkbox
window.initOnion = () ->
  onion_toggle = document.getElementById("onion-toggle")
  onion_toggle.addEventListener("change", () -> turnOnOnion())

#These 3 functions are for the tabs at the top of #view-container
window.displayDraw = () ->
  document.getElementById("audio").style.display = "none"
  document.getElementById("view").style.display = "none"
  document.getElementById("options-container").style.display = "none"
  document.getElementById("draw-container").style.display = "block"

window.displayAnimatic = () ->
  document.getElementById("audio").style.display = ""
  document.getElementById("view").style.display = ""
  document.getElementById("options-container").style.display = "none"
  document.getElementById("draw-container").style.display = "none"

window.displayOptions = () ->
  document.getElementById("audio").style.display = "none"
  document.getElementById("view").style.display = "none"
  document.getElementById("options-container").style.display = "block"
  document.getElementById("draw-container").style.display = "none"

pushFrame = (data) ->
  frame_index += 1
  window.frames[frame_index] = data

window.saveFrame = () ->
  edit = document.getElementById("edit-select")
  data_url = document.getElementById("draw").toDataURL()
  if edit == null
    #first frame saved
    pushFrame(data_url)
    createFrameList()
    addFrame()
  else if edit.value != "edit"
    #editing a frame
    window.frames[edit.value] = data_url
    edit.value = "edit"
    drawTimeline()
  else
    #subsequent frames
    pushFrame(data_url)
    createFrameList()
    addFrame()
  clearCanvas("draw")

window.deleteFrame = () ->
  frame = document.getElementById("edit-select").value
  delete window.frames[frame]
  for chunk, index in window.animatic
    #console.log "#{frame} index #{index} and #{chunk[1]}"
    if chunk != null and chunk[1] == frame then window.animatic[index] = null

  drawTimeline()
  createFrameList()
  clearCanvas("draw")

window.cloneFrame = () ->
  edit = document.getElementById("edit-select")
  data_url = document.getElementById("draw").toDataURL()
  pushFrame(data_url)
  createFrameList()

clearCanvas = (canvas_id) ->
  canvas = document.getElementById(canvas_id)
  context = canvas.getContext("2d")
  context.clearRect(0, 0, canvas.width, canvas.height)

createFrameList = () ->
  select = document.getElementById("insert-pic-select")
  select.options.length = 0 #clear options

  for frame of window.frames #repopulate options
    select.options[select.options.length] = new Option(frame, frame)

  select.value = frame #default to created frame
  createOtherSelects(select)

turnOnOnion = () ->
  frame = document.getElementById("onion-select").value
  onion_toggle = document.getElementById("onion-toggle")
  clearCanvas("onion-canvas")

  if onion_toggle.checked
    onion_canvas = document.getElementById("onion-canvas")
    context = onion_canvas.getContext("2d")
    context.globalAlpha = .2
    img_obj = new Image()
    img_obj.src = window.frames[frame]
    img_obj.onload = () ->
      context.drawImage(img_obj, 0, 0)

editFrame = (frame) ->
  clearCanvas("draw")
  if frame != "edit"
    canvas = document.getElementById("draw")
    context = canvas.getContext("2d")
    img_obj = new Image()
    img_obj.src = window.frames[frame]
    img_obj.onload = () ->
      context.drawImage(img_obj, 0, 0)

createOtherSelects = (select) ->
  #Create onion select list
  draw_container = document.getElementById("draw-container")
  select_clone = select.cloneNode(true)
  select_clone.id = 'onion-select'
  select_clone.value = select.value

  onion_select = document.getElementById("onion-select")
  onion_select.parentNode.removeChild(onion_select) if onion_select
  draw_container.appendChild(select_clone)
  turnOnOnion()

  onion_select = document.getElementById("onion-select")
  onion_select.addEventListener("change", () -> turnOnOnion())

  #Create edit/clone select list
  select_clone_0 = select.cloneNode(true)
  select_clone_0.id = 'edit-select'
  select_clone_0.options[select.options.length] = new Option("Edit", "edit")
  select_clone_0.value = 'edit'

  save_button = document.getElementById("save-frame")
  edit_select = document.getElementById("edit-select")
  edit_select.parentNode.removeChild(edit_select) if edit_select
  draw_container.insertBefore(select_clone_0, save_button)
  edit_select = document.getElementById("edit-select")
  edit_select.addEventListener("change", () -> editFrame(edit_select.value))
