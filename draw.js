// Generated by CoffeeScript 1.3.3
(function() {
  var $, activeTool, comparePix, drawing, drop;

  $ = function(id) {
    return document.getElementById(id);
  };

  drawing = false;

  drop = false;

  window.initCanvas = function() {
    var canvas, context;
    window.tool = "pencil";
    canvas = $("draw");
    context = canvas.getContext("2d");
    canvas.addEventListener("mouseover", function(e) {
      return document.body.style.cursor = "crosshair";
    });
    canvas.addEventListener("mouseout", function(e) {
      return document.body.style.cursor = "default";
    });
    canvas.addEventListener("mousedown", function(e) {
      return activeTool(e);
    });
    canvas.addEventListener("mousemove", function(e) {
      return activeTool(e);
    });
    return canvas.addEventListener("mouseup", function(e) {
      return activeTool(e);
    });
  };

  activeTool = function(e) {
    var canvas, canvasHeight, canvasWidth, color, colorLayer, colorPixel, color_select, context, drawingBoundTop, matchStartColor, mx, my, newPos, pixel, pixelPos, pixelStack, reachLeft, reachRight, startB, startG, startR, width, x, y;
    canvas = $("draw");
    context = canvas.getContext("2d");
    width = 3;
    color_select = $("color");
    color = "#" + color_select.value;
    x = e.offsetX;
    y = e.offsetY;
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
        mx = e.offsetX;
        my = e.offsetY;
        canvasWidth = canvas.width;
        canvasHeight = canvas.height;
        drawingBoundTop = 0;
        colorLayer = context.getImageData(0, 0, canvasWidth, canvasHeight);
        pixelStack = [[mx, my]];
        pixelPos = (pixelStack[0][1] * canvasWidth + pixelStack[0][0]) * 4;
        startR = colorLayer.data[pixelPos];
        startG = colorLayer.data[pixelPos + 1];
        startB = colorLayer.data[pixelPos + 2];
        matchStartColor = function(pixelPos) {
          var b, g, r;
          r = colorLayer.data[pixelPos];
          g = colorLayer.data[pixelPos + 1];
          b = colorLayer.data[pixelPos + 2];
          return r === startR && g === startG && b === startB;
        };
        colorPixel = function(pixelPos) {
          colorLayer.data[pixelPos] = 255;
          colorLayer.data[pixelPos + 1] = 0;
          colorLayer.data[pixelPos + 2] = 0;
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

  comparePix = function(originalPix, pixPosB, pixels) {
    var i, pixB, _i;
    pixB = '';
    for (i = _i = 0; _i <= 3; i = ++_i) {
      pixB += pixels[pixPosB + i].toString();
    }
    if (originalPix === pixB) {
      return true;
    } else {
      return false;
    }
  };

  window.initTools = function() {
    var tool, tools, _i, _len, _results;
    tools = document.getElementsByClassName("tool");
    _results = [];
    for (_i = 0, _len = tools.length; _i < _len; _i++) {
      tool = tools[_i];
      _results.push(tool.addEventListener("click", function(e) {
        if (this.id === "clear") {
          return window.clearCanvas("draw");
        } else {
          return window.tool = this.id;
        }
      }));
    }
    return _results;
  };

}).call(this);
