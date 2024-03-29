// Generated by CoffeeScript 1.3.3
(function() {
  var $, activeTool, drawing, drop;

  $ = function(id) {
    return document.getElementById(id);
  };

  drawing = false;

  drop = false;

  window.initCanvas = function() {
    var drawCanvas, drawContext, onionCanvas, onionContext;
    window.tool = "pencil";
    onionCanvas = $("onion-canvas");
    drawCanvas = $("draw");
    onionContext = onionCanvas.getContext("2d");
    drawContext = drawCanvas.getContext("2d");
    drawContext.fillStyle = "#FFF";
    drawContext.fillRect(0, 0, drawCanvas.width, drawCanvas.height);
    onionCanvas.addEventListener("mouseover", function(e) {
      return document.body.style.cursor = "crosshair";
    });
    onionCanvas.addEventListener("mouseout", function(e) {
      return document.body.style.cursor = "default";
    });
    onionCanvas.addEventListener("mousedown", function(e) {
      return activeTool(e);
    });
    onionCanvas.addEventListener("mousemove", function(e) {
      return activeTool(e);
    });
    return onionCanvas.addEventListener("mouseup", function(e) {
      return activeTool(e);
    });
  };

  window.initTools = function() {
    var tool, tools, _i, _len, _results;
    tools = document.getElementsByClassName("tool");
    _results = [];
    for (_i = 0, _len = tools.length; _i < _len; _i++) {
      tool = tools[_i];
      _results.push(tool.addEventListener("click", function(e) {
        var srcEl, _j, _len1;
        if (this.id === "clear") {
          return window.clearCanvas("draw");
        } else {
          window.tool = this.id;
          tools = document.getElementsByClassName("tool");
          srcEl = e.srcElement ? e.srcElement : e.target;
          for (_j = 0, _len1 = tools.length; _j < _len1; _j++) {
            tool = tools[_j];
            tool.style.backgroundColor = "#FFF";
          }
          return srcEl.style.backgroundColor = "#C3DBDF";
        }
      }));
    }
    return _results;
  };

  window.clearCanvas = function(canvas_id) {
    var canvas, context;
    canvas = $(canvas_id);
    context = canvas.getContext("2d");
    context.clearRect(0, 0, canvas.width, canvas.height);
    if (canvas_id === "draw") {
      context.fillStyle = "#FFF";
      return context.fillRect(0, 0, canvas.width, canvas.height);
    }
  };

  activeTool = function(e) {
    var canvas, canvasHeight, canvasWidth, color, colorLayer, colorPixel, color_select, context, drawingBoundTop, i, matchStartColor, newPos, pixel, pixelPos, pixelStack, reachLeft, reachRight, startPix, width, x, y;
    canvas = $("draw");
    context = canvas.getContext("2d");
    width = 3;
    color_select = $("color");
    color = "#" + color_select.value;
    x = e.offsetX ? e.offsetX : e.layerX;
    y = e.offsetY ? e.offsetY : e.layerY;
    if (window.tool === "pencil" || window.tool === "eraser") {
      if (window.tool === "pencil") {
        width = 3;
        context.globalCompositeOperation = "source-over";
      } else if (window.tool === "eraser") {
        width = 10;
        context.globalCompositeOperation = "destination-out";
      }
      switch (e.type) {
        case "mousedown":
          drawing = true;
          context.fillStyle = color;
          context.strokeStyle = color;
          context.beginPath();
          context.arc(x, y, Math.round(width / 2), 0, 2 * Math.PI, false);
          context.fill();
          context.beginPath();
          context.lineCap = "round";
          return context.moveTo(x, y);
        case "mousemove":
          if (drawing === true) {
            context.lineTo(x, y);
            context.lineWidth = width;
            return context.stroke();
          }
          break;
        case "mouseup":
          return drawing = false;
      }
    } else if (window.tool === "dropper") {
      switch (e.type) {
        case "mousedown":
          drop = true;
          pixel = context.getImageData(x, y, 1, 1).data;
          return color_select.color.fromRGB(pixel[0] / 255, pixel[1] / 255, pixel[2] / 255);
        case "mouseup":
          return drop = false;
        case "mousemove":
          if (drop === true) {
            pixel = context.getImageData(x, y, 1, 1).data;
            return color_select.color.fromRGB(pixel[0] / 255, pixel[1] / 255, pixel[2] / 255);
          }
      }
    } else if (window.tool === "fill") {
      if (e.type === "mouseup") {
        canvasWidth = canvas.width;
        canvasHeight = canvas.height;
        drawingBoundTop = 0;
        colorLayer = context.getImageData(0, 0, canvasWidth, canvasHeight);
        pixelStack = [[x, y]];
        pixelPos = (pixelStack[0][1] * canvasWidth + pixelStack[0][0]) * 4;
        startPix = (function() {
          var _i, _results;
          _results = [];
          for (i = _i = 0; _i <= 3; i = ++_i) {
            _results.push(colorLayer.data[pixelPos + i]);
          }
          return _results;
        })();
        matchStartColor = function(pixelPos) {
          var pix;
          pix = (function() {
            var _i, _results;
            _results = [];
            for (i = _i = 0; _i <= 3; i = ++_i) {
              _results.push(colorLayer.data[pixelPos + i]);
            }
            return _results;
          })();
          return pix[0] === startPix[0] && pix[1] === startPix[1] && pix[2] === startPix[2] && pix[3] === startPix[3];
        };
        colorPixel = function(pixelPos) {
          var _i;
          for (i = _i = 0; _i <= 2; i = ++_i) {
            colorLayer.data[pixelPos + i] = Math.round(color_select.color.rgb[i] * 255);
          }
          return colorLayer.data[pixelPos + 3] = 255;
        };
        while (pixelStack.length) {
          newPos = pixelStack.pop();
          x = newPos[0];
          y = newPos[1];
          pixelPos = (y * canvasWidth + x) * 4;
          while (y-- >= drawingBoundTop && matchStartColor(pixelPos)) {
            pixelPos -= canvasWidth * 4;
          }
          pixelPos += canvasWidth * 4;
          ++y;
          reachLeft = false;
          reachRight = false;
          while (y++ < canvasHeight - 1 && matchStartColor(pixelPos)) {
            colorPixel(pixelPos);
            if (x > 0) {
              if (matchStartColor(pixelPos - 4)) {
                if (!reachLeft) {
                  pixelStack.push([x - 1, y]);
                  reachLeft = true;
                }
              } else if (reachLeft) {
                reachLeft = false;
              }
            }
            if (x < canvasWidth - 1) {
              if (matchStartColor(pixelPos + 4)) {
                if (!reachRight) {
                  pixelStack.push([x + 1, y]);
                  reachRight = true;
                }
              } else if (reachRight) {
                reachRight = false;
              }
            }
            pixelPos += canvasWidth * 4;
          }
        }
        return context.putImageData(colorLayer, 0, 0);
      }
    }
  };

}).call(this);
