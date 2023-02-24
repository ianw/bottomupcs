/* DocBook xslTNG version 1.11.1
 *
 * This is annotations.js providing support for popup annotations.
 *
 * See https://xsltng.docbook.org/
 *
 */

(function() {
  const html = document.querySelector("html");

  const showAnnotation = function(event, id) {
    let div = document.querySelector(id);
    div.style.display = "block";
    enablePopup(div);

    event.preventDefault();

    // Give the current click event a chance to settle?
    window.setTimeout(function () {
      let curpress = document.onkeyup;
      document.onkeyup = function (event) {
        hideAnnotation(event, id, curpress);
      };
    }, 25);

    return false;
  };

  const hideAnnotation = function(event, id, curpress) {
    let div = document.querySelector(id);
    div.style.display = "none";
    disablePopup(div);

    if (curpress) {
      document.onkeyup = curpress;
    }

    return true;
  };

  const enablePopup = function(div) {
    togglePopup(div, 'popup-', '');
  };

  const disablePopup = function(div) {
    togglePopup(div, '', 'popup-');
  };

  const togglePopup = function(div, on, off) {
    div.classList.remove(`${off}annotation-wrapper`);
    div.classList.add(`${on}annotation-wrapper`);
    ["body", "header", "content"].forEach(function(token) {
      const find = `.${off}annotation-${token}`;
      const addClass = `${on}annotation-${token}`;
      const removeClass = `${off}annotation-${token}`;
      div.querySelectorAll(find).forEach(function (div) {
        div.classList.add(addClass);
        div.classList.remove(removeClass);
      });
    });
  };

  let jsannotations = window.localStorage.getItem("docbook-js-annotations");
  if (jsannotations === "false") {
    return;
  }
  html.classList.add("js-annotations");

  // Turn off the display of the individual annotations
  document.querySelectorAll("footer .annotations > div").forEach(function(div) {
    div.style.display = "none";
  });

  // Change the class on the annotations block to remove its styling
  document.querySelectorAll("footer .annotations").forEach(function(div) {
    // Turn off the annotation styling
    div.classList.add("popup-annotations");
    div.classList.remove("annotations");
  });

  // The annotation close markup is hidden in a script. This prevents
  // it from showing up spuriously all over screen readers and other
  // user agents that don't support JavaScript. Find it and copy it
  // into the annotations.
  let annoClose = document.querySelector("script.annotation-close");
  if (!annoClose) {
    // I have a bad feeling about this...
    annoClose = document.createElement("span");
    annoClose.innerHTML = "╳";
  }
  document.querySelectorAll("div.annotation-close").forEach(function(div) {
    div.innerHTML = annoClose.innerHTML;
  });

  // Setup the onclick event for the annotation marks
  document.querySelectorAll("a.annomark").forEach(function(mark) {
    let id = mark.getAttribute("href");
    // Escape characters that confuse querySelector
    id = id.replace(/\./g, "\\.");
    mark.onclick = function (event) {
      showAnnotation(event, id);
    };
  });

  // Take out the annotation numbers (in the text and the popup titles)
  document.querySelectorAll(".annomark sup.num").forEach(function(sup) {
    sup.style.display = "none";
  });

  // If an annotation is displayed, make clicking on the page hide it
  document.querySelectorAll("div.annotation-close").forEach(function(anno) {
    // Carefully walk up the tree; this might just be the close tag lying
    // around in the footer not actually inside an annotation.
    let id = anno.parentNode.parentNode.parentNode.getAttribute("id");
    // Escape characters that confuse querySelector
    id = id.replace(/\./g, "\\.");
    anno.onclick = function (event) {
      hideAnnotation(event, `#${id}`);
    };
  });
})();
