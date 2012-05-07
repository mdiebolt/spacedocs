# require coffee-script
# require corelib
# require pixie_canvas
# require color

$ ->
  $(".documentation").on "click", ".toggle_source", (e) ->
    e.preventDefault()

    $(this).next().toggle()

  $("code.run").each ->
    # Assume it's a PixieCanvas example
    codeElement = $(this)

    source = codeElement.text()

    compiledJs = CoffeeScript.compile source, bare: true

    canvas = $("<canvas width=200 height=150/>").pixieCanvas()

    codeElement.after(canvas)

    eval compiledJs