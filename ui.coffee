window.initTabs = () ->
  #this colors the tabs
  tabs = document.getElementsByClassName("tab")
  for tab in tabs
    tab.addEventListener("click", (e) ->
      for tab in tabs
        tab.style.backgroundColor = "#FFF"
      e.srcElement.style.backgroundColor = "#C3DBDF"
    )

#These functions are for the tabs at the top of #view-container
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
