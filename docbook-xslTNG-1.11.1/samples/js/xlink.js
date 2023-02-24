/* DocBook xslTNG version 1.11.1
 *
 * This is xlink.js providing support for multi-targeted links
 *
 * See https://xsltng.docbook.org/
 *
 */

(function() {
  const html = document.querySelector("html");
  let OPEN = "▼";
  let CLOSED = "▶";

  // You can hide alternate open/closed markers in the HTML.
  // Put them in a script element so that they get ignored
  // by screen readers and other non-JS presentations
  let arrow = document.querySelector("script.xlink-icon-open");
  if (arrow) {
    OPEN = arrow.innerHTML;
  }
  arrow = document.querySelector("script.xlink-icon-closed");
  if (arrow) {
    CLOSED = arrow.innerHTML;
  }

  const showXLinks = function(event, span, qsel) {
    span.innerHTML = OPEN;
    const top = span.offsetTop + span.offsetHeight;
    const left = span.offsetLeft;

    let links = document.querySelector(qsel);

    if (links.style.display === "inline-block") {
      // Already displayed: abort!
      return;
    }

    window.setTimeout(function () {
      const width = window.innerWidth
            || document.documentElement.clientWidth
            || document.body.clientWidth;
      checkPosition(links, top, left, width);
    }, 25);

    // Give the current click event a chance to settle?
    window.setTimeout(function () {
      let curclick = document.onclick;
      let curpress = document.onkeyup;
      document.onclick = function (event) {
        unshowXLinks(event, span, qsel, curclick, curpress);
      };
      document.onkeyup = function (event) {
        unshowXLinks(event, span, qsel, curclick, curpress);
      };

      links.style.display = "inline-block";
      links.style.position = "absolute";
      links.style.top = top;
      links.style.left = left;
    }, 25);
  };

  const unshowXLinks = function(event, span, qsel, curclick, curpress) {
    span.innerHTML = CLOSED;
    /*
    span.onclick = function (event) {
      showXLinks(event, span, qsel);
    };
    */

    let links = document.querySelector(qsel);
    links.style.display = "none";

    document.onclick = curclick;
    document.onkeyup = curpress;
  };

  const checkPosition = function(links, top, left, width) {
    if (left + links.offsetWidth + 10 >= width) {
      const newx =  left - 20;
      if (newx >= 0) {
        links.style.left = newx;
        links.style.top = top;
        if (newx == left) {
          console.log("Looping!");
        } else {
          window.setTimeout(function () {
            checkPosition(links, top, newx, width);
          }, 15);
        }
      }
    }
  };

  let jsxlinks = window.localStorage.getItem("docbook-js-xlinks");
  if (jsxlinks === "false") {
    return;
  }
  html.classList.add("js-xlinks");

  // Process XLink multi-targeted links.
  // 1. The link source is a target, but the JS has to operate
  //    on the arc list that (immediately) follows it.
  document.querySelectorAll(".xlink .source").forEach(function(span) {
    span.onclick = function (event) {
      // Be conservative in case some text node or something got introduced
      let arclist = span.nextSibling;
      while (arclist && !arclist.classList.contains("xlink-arc-list")) {
        arclist = arclist.nextSibling;
      }
      if (arclist) {
        showXLinks(event, arclist, "#" + arclist.getAttribute("db-arcs"));
      } else {
        console.log("Document formatting error: no xlink-arc-list");
      }
    };
  });

  // 2. The arc list is also a target.
  document.querySelectorAll(".xlink-arc-list").forEach(function(span) {
    span.innerHTML = CLOSED;
    span.classList.add("js");
    span.onclick = function (event) {
      showXLinks(event, span, "#" + span.getAttribute("db-arcs"));
    };
  });

  document.querySelectorAll(".nhrefs").forEach(function(span) {
    span.classList.add("js");
  });
})();
