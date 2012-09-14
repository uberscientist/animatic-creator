$ = (id) -> document.getElementById(id)

window.initOptions = () ->
  $("project-save").addEventListener("click", (e) ->
    $("audio").src = "comic1.mp3"
    console.log $("audio")
  )
