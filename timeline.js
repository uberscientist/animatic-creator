// Generated by CoffeeScript 1.3.3
(function() {
  var $, delay, nextOffset, scale, startAnimatic;

  $ = function(id) {
    return document.getElementById(id);
  };

  delay = function(ms, func) {
    var animation;
    return animation = setTimeout(func, ms);
  };

  Array.prototype.swap = function(a, b) {
    this[a] = this.splice(b, 1, this[a])[0];
    return this;
  };

  nextOffset = 300;

  scale = .1;

  window.onload = function() {
    window.frame_index = 0;
    window.animatic = [];
    window.frames = {};
    window.initCanvas();
    window.initTools();
    window.initTabs();
    window.initOnion();
    $("audio").addEventListener("playing", function(e) {
      return startAnimatic();
    });
    return $("scale-range").addEventListener("change", function(e) {
      scale = this.value;
      return drawTimeline();
    });
  };

  window.addFrame = function() {
    var frame, name, time;
    name = $("insert-pic-select").value;
    if (name) {
      time = nextOffset;
      frame = [time, name];
      window.animatic.push(frame);
      return drawTimeline(window.animatic);
    }
  };

  window.drawTimeline = function() {
    var chunk_div, clearDiv, delete_link, dragged, frame, frame_name, index, offset, origWidth, resizeEnable, resizeStartX, resizing, select, select_clone, timeline, timeline_container, _i, _len;
    resizeEnable = false;
    resizing = null;
    dragged = null;
    origWidth = null;
    resizeStartX = null;
    timeline = $("timeline");
    if (timeline) {
      timeline.parentNode.removeChild(timeline);
    }
    timeline = document.createElement("div");
    timeline.id = "timeline";
    for (index = _i = 0, _len = animatic.length; _i < _len; index = ++_i) {
      frame = animatic[index];
      if (frame !== null) {
        offset = frame[0];
        frame_name = frame[1];
        select = $("insert-pic-select");
        select_clone = select.cloneNode(true);
        select_clone.value = frame_name;
        select_clone.index = index;
        delete_link = document.createElement("a");
        delete_link.innerText = "del";
        delete_link.href = "#";
        delete_link.index = index;
        chunk_div = document.createElement("div");
        chunk_div.style.backgroundImage = "url('" + window.frames[frame_name] + "')";
        chunk_div.style.backgroundSize = "64px 48px";
        chunk_div.style.width = animatic[index][0] * scale + "px";
        chunk_div.className = "chunk";
        chunk_div.index = index;
        chunk_div.id = "chunk-" + index;
        chunk_div.appendChild(select_clone);
        chunk_div.appendChild(delete_link);
        timeline.appendChild(chunk_div);
        chunk_div.addEventListener("mouseout", function(e) {
          document.body.style.cursor = "default";
          return resizeEnable = false;
        });
        chunk_div.addEventListener("mousemove", function(e) {
          var chunkWidth, x;
          x = e.offsetX;
          chunkWidth = parseInt(this.style.width.match(/\d*/));
          if (x > chunkWidth - 20 && x < chunkWidth - 5) {
            this.draggable = false;
            document.body.style.cursor = "col-resize";
            return resizeEnable = true;
          } else {
            document.body.style.cursor = "move";
            resizeEnable = false;
            return this.draggable = true;
          }
        });
        chunk_div.addEventListener("mousedown", function(e) {
          if (resizeEnable) {
            return resizing = this;
          }
        });
        select_clone.addEventListener("change", function() {
          animatic[this.index][1] = this.value;
          return drawTimeline();
        });
        delete_link.addEventListener("click", function() {
          window.animatic.splice(parseInt(this.index), 1);
          return drawTimeline();
        });
        chunk_div.addEventListener("dragstart", function() {
          this.style.opacity = '0.4';
          return dragged = this;
        });
        chunk_div.addEventListener("dragend", function() {
          this.style.opacity = '1';
          return dragged = null;
        });
        chunk_div.addEventListener("dragover", function(e) {
          if (e.preventDefault) {
            e.preventDefault();
          }
          return this.style.borderLeft = "2px red dotted";
        });
        chunk_div.addEventListener("dragleave", function() {
          return this.style.borderLeft = "";
        });
        chunk_div.addEventListener("drop", function(e) {
          var draggged, spliceOffset;
          if (e.stopPropagation) {
            e.stopPropagation();
            draggged = window.animatic[dragged.index];
            spliceOffset = dragged.index > this.index ? 1 : 0;
            window.animatic.splice(this.index, 0, window.animatic[dragged.index]);
            window.animatic.splice(dragged.index + spliceOffset, 1);
            this.style.borderLeft = "";
            return drawTimeline();
          }
        });
      }
    }
    timeline_container = $("timeline-container");
    timeline_container.appendChild(timeline);
    clearDiv = document.createElement("div");
    clearDiv.style.clear = "both";
    timeline_container.appendChild(clearDiv);
    timeline_container.addEventListener("mousedown", function(e) {
      if (resizing) {
        resizeStartX = e.pageX;
        return origWidth = parseInt(resizing.style.width.match(/\d*/));
      }
    });
    timeline_container.addEventListener("mousemove", function(e) {
      if (resizing) {
        return resizing.style.width = origWidth + (e.pageX - resizeStartX) + "px";
      }
    });
    return timeline_container.addEventListener("mouseup", function(e) {
      var width;
      if (resizing) {
        width = parseInt(resizing.style.width.match(/\d*/));
        index = resizing.index;
        animatic[index][0] = Math.round(width / scale);
        return resizing = null;
      }
    });
  };

  startAnimatic = function() {
    var frame, image, index, timeOffset, view, _i, _len, _results;
    timeOffset = 0;
    view = $("view");
    _results = [];
    for (index = _i = 0, _len = animatic.length; _i < _len; index = ++_i) {
      frame = animatic[index];
      if (frame) {
        image = window.frames[frame[1]];
        _results.push((function(image) {
          if (index === 0) {
            timeOffset = 0;
          } else {
            timeOffset += window.animatic[index - 1][0];
          }
          return delay(timeOffset, function() {
            return view.style.backgroundImage = "url('" + image + "')";
          });
        })(image));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

}).call(this);
