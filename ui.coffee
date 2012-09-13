$ = (id) -> document.getElementById(id)

window.initTabs = () ->
  tabs = document.getElementsByClassName("tab")
  for tab in tabs
    tab.addEventListener("click", (e) ->
      for tab in tabs
        tab.style.backgroundColor = "#C3DBDF"
      srcEl = if e.srcElement then e.srcElement else e.target
      srcEl.style.backgroundColor = "#FFF"

      switch @id
        when "tab-animatic"
          $("audio").style.display = ""
          $("view").style.display = ""
          $("options-container").style.display = "none"
          $("draw-container").style.display = "none"
        when "tab-draw"
          $("audio").style.display = "none"
          $("view").style.display = "none"
          $("options-container").style.display = "none"
          $("draw-container").style.display = "block"
        when "tab-options"
          $("audio").style.display = "none"
          $("view").style.display = "none"
          $("options-container").style.display = "block"
          $("draw-container").style.display = "none"
    )

window.message = (msg) ->
  alert msg

#for the stinkin' onion checkbox
window.initOnion = () ->
  onion_toggle = $("onion-toggle")
  onion_toggle.addEventListener("change", () -> turnOnOnion())

pushFrame = (data) ->
  frame_index += 1
  window.frames[frame_index] = data

window.saveFrame = () ->
  edit = $("edit-select")
  data_url = $("draw").toDataURL()
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
  if $("edit-select")
    frame = $("edit-select").value
    delete window.frames[frame]
    for chunk, index in window.animatic
      #console.log "#{frame} index #{index} and #{chunk[1]}"
      if chunk != null and chunk[1] == frame then window.animatic[index] = null

    drawTimeline()
    createFrameList()
    clearCanvas("draw")

window.cloneFrame = () ->
  data_url = $("draw").toDataURL()
  pushFrame(data_url)
  createFrameList()
  $("edit-select").value = $("insert-pic-select").value

createFrameList = () ->
  select = $("insert-pic-select")
  select.options.length = 0 #clear options

  for frame of window.frames #repopulate options
    select.options[select.options.length] = new Option(frame, frame)

  select.value = frame #default to created frame
  createOtherSelects(select)

turnOnOnion = () ->
  onionSelect = $("onion-select")
  if onionSelect
    frame = onionSelect.value
    onion_toggle = $("onion-toggle")
    clearCanvas("onion-canvas")

    if onion_toggle.checked
      onion_canvas = $("onion-canvas")
      context = onion_canvas.getContext("2d")
      context.globalAlpha = .2
      img_obj = new Image()
      img_obj.src = window.frames[frame]
      img_obj.onload = () ->
        context.drawImage(img_obj, 0, 0)
  else
    message "You must have a frame to create an onion skin"

editFrame = (frame) ->
  clearCanvas("draw")
  if frame != "edit"
    canvas = $("draw")
    context = canvas.getContext("2d")
    context.globalCompositeOperation = "source-over"
    img_obj = new Image()
    img_obj.src = window.frames[frame]
    img_obj.onload = () ->
      context.drawImage(img_obj, 0, 0)

createOtherSelects = (select) ->
  #Create onion select list
  draw_container = $("draw-container")
  select_clone = select.cloneNode(true)
  select_clone.id = 'onion-select'
  select_clone.value = select.value

  onion_select = $("onion-select")
  onion_select.parentNode.removeChild(onion_select) if onion_select
  draw_container.appendChild(select_clone)
  turnOnOnion()

  onion_select = $("onion-select")
  onion_select.addEventListener("change", () -> turnOnOnion())

  #Create edit/clone select list
  select_clone_0 = select.cloneNode(true)
  select_clone_0.id = 'edit-select'
  select_clone_0.options[select.options.length] = new Option("Edit", "edit")
  select_clone_0.value = 'edit'

  save_button = $("save-frame")
  edit_select = $("edit-select")
  edit_select.parentNode.removeChild(edit_select) if edit_select
  draw_container.insertBefore(select_clone_0, save_button)
  edit_select = $("edit-select")
  edit_select.addEventListener("change", () -> editFrame(edit_select.value))
