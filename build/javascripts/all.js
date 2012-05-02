(function() {

  $(function() {
    return $("code.run").each(function() {
      var canvas, codeElement, compiledJs, source;
      codeElement = $(this);
      source = codeElement.text();
      compiledJs = CoffeeScript.compile(source, {
        bare: true
      });
      canvas = $("<canvas width=200 height=150/>").pixieCanvas();
      codeElement.after(canvas);
      return eval(compiledJs);
    });
  });

}).call(this);
