/* DocBook xslTNG version 1.11.1
 *
 * This is controls.js providing JavaScript controls.
 *
 * See https://xsltng.docbook.org/
 *
 */

(function() {
  const prefersDark = window.matchMedia
        && window.matchMedia('(prefers-color-scheme: dark)').matches;
  const html = document.querySelector("html");
  const body = document.querySelector("body");
  const controlScript = document.querySelector("#db-js-controls");
  let themeList = [];
  let togglesFieldset = null;
  let themesFieldset = null;
  let toggleAnnotations = "#db-js-annotations_";
  let toggleXLinks = "#db-js-xlinks_";
  let jsControlsReload = "#db-js-controls-reload_";
  let controls = null;
  let menu = null;

  const activateControls = function() {
    let open = controls.querySelector(".controls-open");
    open = body.appendChild(open);
    open.style.position = "fixed";
    open.style.left = "10px";
    open.style.top = "0";
    open.style.cursor = "pointer";
    open.onclick = function(event) {
      showMenu(event);
    };

    menu = controls.querySelector(".js-controls-wrapper");
    menu = body.appendChild(menu);
    let close = menu.querySelector(".js-controls-close");
    close.onclick = function(event) {
      hideMenu(event);
    };

    let nodes = menu.querySelectorAll("button");
    nodes[0].style.cursor = "pointer";
    nodes[0].onclick = function(event) {
      hideMenu(event);
    };
    nodes[1].style.cursor = "pointer";
    nodes[1].onclick = function(event) {
      updateSettings(event);
    };

    nodes = menu.querySelectorAll("fieldset");
    togglesFieldset = nodes[0];
    themesFieldset = nodes[1];

    let random = togglesFieldset.getAttribute("db-random");
    toggleAnnotations = toggleAnnotations + random;
    toggleXLinks = toggleXLinks + random;
    jsControlsReload = jsControlsReload + random;

    let check = document.querySelector(toggleAnnotations);
    check.onchange = function (event) {
      let check = document.querySelector(toggleAnnotations);
      window.localStorage.setItem("docbook-js-annotations", check.checked);
      checkReload(event);
    };
    check.checked = html.classList.contains("js-annotations");

    check = document.querySelector(toggleXLinks);
    check.onchange = function (event) {
      let check = document.querySelector(toggleXLinks);
      window.localStorage.setItem("docbook-js-xlinks", check.checked);
      checkReload(event);
    };
    check.checked = html.classList.contains("js-xlinks");

    let theme = window.localStorage.getItem("docbook-theme");
    if (theme) {
      document.querySelectorAll("input[name='db-theme']").forEach(function(input) {
        if (input.value === theme) {
          input.checked = true;
        } else {
          input.checked = false;
        }
      });
    }
  };

  const showMenu = function(event) {
    let toggles = menu.querySelector("fieldset.js-controls-toggles");
    if (event.shiftKey) {
      toggles.style.display = "block";
    } else {
      toggles.style.display = "none";
    }

    let theme = currentTheme();
    document.querySelectorAll("input[name='db-theme']").forEach(function(input) {
      if (input.value === theme) {
        input.checked = true;
      } else {
        input.checked = false;
      }
    });

    menu.style.display = "block";
  };

  const checkReload = function(event) {
    let reload = false;
    let value = window.localStorage.getItem("docbook-js-annotations") === "true";
    reload = reload || value !== document.querySelector(toggleAnnotations).checked;
    value = window.localStorage.getItem("docbook-js-xlinks") === "true";
    reload = reload || value !== document.querySelector(toggleXLinks).checked;

    if (reload) {
      document.querySelector(jsControlsReload).innerHTML = "Reload required";
    } else {
      document.querySelector(jsControlsReload).innerHTML = "";
    }

    return false;
  };

  const currentTheme = function() {
    let theme = null;
    themeList.forEach(function(item) {
      if (html.classList.contains(item)) {
        theme = item;
      }
    });
    return theme;
  };

  const setTheme = function(theme) {
    themeList.forEach(function(item) {
      html.classList.remove(item);
    });
    html.classList.add(theme);
  };

  const updateSettings = function(event) {
    menu.style.display = "none";

    const newTheme = document.querySelector("input[name='db-theme']:checked");
    if (newTheme) {
      setTheme(newTheme.value);
      window.localStorage.setItem("docbook-theme", newTheme.value);
    }
  };

  const hideMenu = function(event) {
    menu.style.display = "none";
  };

  if (controlScript) {
    controls = document.createElement("DIV");
    controls.innerHTML = controlScript.innerHTML;
    activateControls();

    // Find the controls in the document
    document.querySelectorAll(".js-controls-wrapper").forEach(function(div) {
      // The controls will be the last one, in the unlikely event there's
      // more than one. (It's possible for a document to use that class.)
      controls = div;
    });

    // Populate the themes list
    document.querySelectorAll("input[name='db-theme']").forEach(function(input) {
      themeList.push(input.value);
    });

    let theme = window.localStorage.getItem("docbook-theme");
    if (theme !== null) {
      setTheme(theme);
    } else {
      let dark = controls.querySelector("div").getAttribute("db-dark-theme");
      if (dark && prefersDark) {
        setTheme(dark);
      }
    }

    html.style.display = "block";
  }
})();
