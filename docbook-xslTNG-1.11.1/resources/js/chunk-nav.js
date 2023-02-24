/* DocBook xslTNG version 1.11.1
 *
 * This is chunk-nav.js providing support for keyboard
 * navigation between chunks.
 *
 * See https://xsltng.docbook.org/
 *
 * There are a few things going on here.
 *
 * 1. The stylesheets store next/prev/up/home links in the HTML head
 *    using link/@rel elements.
 * 2. If chunk-nav.js is loaded, N/→, P/←, U/↑, and H/Home navigate to
 *    the next, previous, "up", and home pages.
 * 3. If the HTML pages contain a meta element with the name
 *    "localStorage.key", the value of that element is used as a key
 *    in the browser's localStorage API to track the Window location.
 * 4. The S key can be used to switch between a normal view and a
 *    speaker notes view. This requires a stylesheet customization
 *    that renders the speaker notes view.
 * 5. If the HTML pages contain a meta element with the name
 *    "progressiveReveal.key", then navigation interacts with lists in
 *    the following way: if the in-scope class for a list is 'reveal',
 *    then each list item will be progressively revealed by "next"
 *    navigation (and progressively hidden by "previous" navigation.
 *    You can use 'A' to reveal them all, and 'R' to toggle the
 *    progressive reveal behavior.
 *
 *    You can avoid flicker if you configure CSS to hide the things
 *    that should be hidden by default. This JavaScript will handle
 *    that case, even when progressiveReveal is disabled.
 */

(function() {
  const KEY_N = 78;
  const KEY_RIGHT = 39;

  const KEY_P = 80;
  const KEY_LEFT = 37;

  const KEY_U = 85;
  const KEY_UP = 38;

  const KEY_H = 72;
  const KEY_HOME = 36;

  const KEY_A = 65;
  const KEY_R = 82;
  const KEY_S = 83;

  const KEY_SPACE = 32;
  const KEY_DOWN = 40;

  const KEY_SHIFT = 16;
  const KEY_QUESTION = 191;

  const body = document.querySelector("body");

  let meta = document.querySelector("head meta[name='localStorage.key']");
  const localStorageKey = meta && meta.getAttribute("content");
  const notesKey = "viewingNotes";
  let notesView = false;

  meta = document.querySelector("head meta[name='progressiveReveal.key']");
  const progressiveRevealKey = meta && meta.getAttribute("content");
  let progressiveReveal = "true"; // String because it goes in localStorage
  let revealedKey = "revealedKey";
  let toBeRevealed = false;
  let threeDots = null;

  const nav = function(event) {
    event = event || window.event;
    let keyCode = event.keyCode || event.which;

    if (event.srcElement && event.srcElement.classList.contains("ptoc-search")) {
      // Don't navigate if the user is typing in the persistent toc search box
      return true;
    }

    switch (keyCode) {
      case KEY_A:
        revealAll();
        break;
      case KEY_N:
      case KEY_RIGHT:
        if (toBeRevealed && !event.shiftKey) {
          revealNext();
        } else {
          nav_to(event, "next");
        }
        break;
      case KEY_P:
      case KEY_LEFT:
        nav_to(event, "prev");
        break;
      case KEY_U:
      case KEY_UP:
        nav_to(event, "up");
        break;
      case KEY_H:
      case KEY_HOME:
        nav_to(event, "home");
        break;
      case KEY_SPACE:
      case KEY_DOWN:
        revealNext();
        break;
      case KEY_S:
        if (localStorageKey) {
          viewNotes(!notesView);
        }
        break;
      case KEY_R:
        if (event.shiftKey) {
          resetProgressiveReveal();
        } else {
          toggleProgressiveReveal();
        }
        break;
      case KEY_QUESTION:
        debugInfo();
        break;
      case KEY_SHIFT:
        break;
      default:
        break;
    }

    return false;
  };

  const nav_to = function(event, rel) {
    event.preventDefault();
    let link = document.querySelector(`head link[rel='${rel}']`);
    if (link && link.hasAttribute("href")) {
      window.location.href = link.getAttribute("href");
    }
  };

  const viewNotes = function(view) {
    if (view) {
      document.querySelectorAll("main > .foil > .foil").forEach(function(div) {
        div.style.display = "none";
      });
      document.querySelectorAll(".speaker-notes").forEach(function(div) {
        div.style.display = "block";
      });
    } else {
      document.querySelectorAll("main > .foil > .foil").forEach(function(div) {
        div.style.display = "block";
      });
      document.querySelectorAll(".speaker-notes").forEach(function(div) {
        div.style.display = "none";
      });
    }
    notesView = view;
    window.sessionStorage.setItem(notesKey, notesView);
  };

  const storageChange = function(changes, areaName) {
    if (changes.key === localStorageKey) {
      if (changes.newValue !== window.location) {
        window.location.href = changes.newValue;
      }
    }
  };

  const configureRevealList = function(list) {
    const revealThisList = list.classList.contains("reveal");
    if (revealThisList) {
      let itemnum = 0;
      list.querySelectorAll(":scope > li").forEach(function(item) {
        itemnum++;

        if (item.classList.contains("noreveal")) {
          item.style.display = "list-item";
        } else {
          if (itemnum > 1) {
            item.classList.add("toberevealed");
            item.style.display = "none";
            if (progressiveReveal !== "true") {
              reveal(item);
            }
          }
        }

        // Now process the descendants of the list items
        item.querySelectorAll(":scope > *").forEach(function(child) {
          configureReveal(child);
        });
      });
    } else {
      // If the list doesn't have a reveal, check its children
      list.querySelectorAll("li").forEach(function(item) {
        configureReveal(item);
      });
    }

    toBeRevealed = (progressiveReveal === "true")
      && (toBeRevealed || revealThisList);
  };

  const configureReveal = function(elem) {
    if (elem.tagName === "UL" && elem.classList.contains("toc")) {
      // nop; don't attempt to do reveal processing on tables of contents
    } else if (elem.tagName === "UL" || elem.tagName === "OL") {
      // Lists are special; hide all but the first item by default
      configureRevealList(elem);
    } else if (elem.tagName === "SCRIPT") {
      // don't look in script elements
    } else if (elem.classList.contains("speaker-notes")) {
      // don't do reveals in speaker-notes
    } else {
      if (elem.classList.contains("reveal")) {
        elem.classList.add("toberevealed");
        elem.style.display = "none";
        if (progressiveReveal === "true") {
          toBeRevealed = true;
        } else {
          reveal(elem);
        }
      } else {
        elem.querySelectorAll(":scope > *").forEach(function(item) {
          configureReveal(item);
        });
      }
    }
  };

  const reveal = function(item) {
    item.classList.replace("toberevealed", "revealed");
    if (item.tagName === "LI") {
      item.style.display = "list-item";
    } else if (item.tagName === "SPAN") {
      item.style.display = "inline";
    } else {
      item.style.display = "block";
    }
  };

  const revealAll = function() {
    while (document.querySelector(".toberevealed")) {
      revealNext();
    }
  };

  const revealNext = function() {
    if (document.querySelector(".toberevealed")) {
      revealNextWalk(body);
    }
  };

  const revealNextWalk = function(elem) {
    if (elem.classList.contains("toberevealed")) {
      reveal(elem);
      toBeRevealed = (document.querySelector(".toberevealed") !== null);
      if (!toBeRevealed) {
        if (threeDots) {
          threeDots.style.display = "none";
        }
        saveRevealed();
      }
      return true;
    }

    let found = false;
    elem.querySelectorAll(":scope > *").forEach(function(child) {
      if (!found) {
        found = revealNextWalk(child);
      }
      if (!found) {
        if (child.classList.contains("transitory")) {
          child.style.display = "none";
        }
      }
    });

    return found;
  };

  const toggleProgressiveReveal = function() {
    if (!progressiveRevealKey) {
      return;
    }

    if (progressiveReveal === "true") {
      revealAll();
      progressiveReveal = "false";
    } else {
      progressiveReveal = "true";
    }
    window.localStorage.setItem(progressiveRevealKey, progressiveReveal);

    let message = document.createElement("DIV");
    if (progressiveReveal === "true") {
      message.innerHTML = "Progressive reveal: on";
    } else {
      message.innerHTML = "Progressive reveal: off";
    }
    message.style.position = "absolute";
    message.style.bottom = 0;
    message.style.left = 0;
    message.style.opacity = 1;
    message.style.transition = "opacity 1s linear";
    body.appendChild(message);

    // Wait a moment and then turn off the opacity to trigger the transition.
    window.setTimeout(function () {
      message.style.opacity = 0;
    }, 25);
  };

  const resetProgressiveReveal = function() {
    if (progressiveRevealKey) {
      progressiveReveal = "true";
      window.localStorage.setItem(progressiveRevealKey, progressiveReveal);
      window.localStorage.setItem(revealedKey, "");
    }
  };

  const saveRevealed = function() {
    if (progressiveRevealKey) {
      let loc = window.location.toString().replace(",", "%2C");
      let curlocs = window.localStorage.getItem(revealedKey);
      if (!curlocs) {
        curlocs = [];
      } else {
        curlocs = curlocs.split(",");
      }
      if (!curlocs.includes(loc)) {
        curlocs.push(loc);
        window.localStorage.setItem(revealedKey, curlocs.join(","));
      }
    }
  };

  const hasBeenRevealed = function() {
    if (progressiveRevealKey) {
      let loc = window.location.toString().replace(",", "%2C");
      let curlocs = window.localStorage.getItem(revealedKey);
      if (!curlocs) {
        curlocs = [];
      } else {
        curlocs = curlocs.split(",");
      }
      return curlocs.includes(loc);
    }
    return false;
  };

  const debugInfo = function() {
    console.log("Progressive reveal:", progressiveReveal);
    console.log("Progressive reveal key:", progressiveRevealKey);
    console.log("Local storage key:", localStorageKey);

    let count = 0;
    document.querySelectorAll(".toberevealed").forEach(function(item) {
      console.log(item);
      count += 1;
    });
    console.log(count, "items to be revealed on this page.");

    if (progressiveRevealKey) {
      let curlocs = window.localStorage.getItem(revealedKey);
      if (!curlocs) {
        curlocs = [];
      } else {
        curlocs = curlocs.split(",");
      }
      console.log("Pages revealed:", curlocs.length);
      if (hasBeenRevealed()) {
        console.log("This page has been revealed.");
      } else {
        console.log("This page has not been revealed.");
      }
    }

    return false;
  };

  if (progressiveRevealKey) {
    if (window.localStorage.getItem(progressiveRevealKey) === null) {
      window.localStorage.setItem(progressiveRevealKey, progressiveReveal);
      window.localStorage.setItem(revealedKey, "");
    } else {
      progressiveReveal = window.localStorage.getItem(progressiveRevealKey);
    }

    configureReveal(body);

    if (toBeRevealed) {
      threeDots = document.createElement("DIV");
      threeDots.innerHTML = "⋮";
      threeDots.style.position = "absolute";
      threeDots.style.bottom = 0;
      threeDots.style.left = 0;

      if (progressiveReveal !== "true") {
        threeDots.style.display = "none";
      }

      body.appendChild(threeDots);
    }

    if (hasBeenRevealed()) {
      revealAll();
    }
  } else {
    progressiveReveal = "false";
    configureReveal(body);
  }

  if (localStorageKey) {
    if (!window.localStorage.getItem(localStorageKey)
        || window.localStorage.getItem(localStorageKey) !== window.location) {
      window.localStorage.setItem(localStorageKey, window.location);
    }
    window.addEventListener("storage", storageChange);

    if (window.sessionStorage.getItem(notesKey) !== null) {
      viewNotes(window.sessionStorage.getItem(notesKey) === "true");
    }
  }

  window.onkeyup = nav;
})();
