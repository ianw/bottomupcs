/* DocBook xslTNG version 1.11.1
 *
 * This is persistent-toc.js providing support for the ToC popup
 *
 * See https://xsltng.docbook.org/
 *
 */

(function() {
  const ESC = 27;
  const SPACE = 32;
  const toc = document.querySelector("nav.toc");
  let tocPersist = null;
  let borderLeftColor = "white";
  let curpress = null;
  let searchListener = false;

  const showToC = function(event) {
    toc.style.width = "300px";
    toc.style["padding-left"] = "1em";
    toc.style["padding-right"] = "1em";
    toc.style["border-left"] = `1px solid ${borderLeftColor}`;

    // Make sure the tocPersist checkbox is created
    tocPersistCheckbox();

    if (event) {
      event.preventDefault();
    }

    // Turn off any search markers that might have been set
    toc.querySelectorAll("li").forEach(function (li) {
      const link = li.querySelector("a");
      li.style.display = "list-item";
      link.classList.remove("found");
    });

    // Give the current click event a chance to settle?
    window.setTimeout(function () {
      const tocClose = toc.querySelector("header .close");
      curpress = document.onkeyup;
      tocClose.onclick = function (event) {
        hideToC(event);
      };
      document.onkeyup = function (event) {
        event = event || window.event;
        if (event.srcElement && event.srcElement.classList.contains("ptoc-search")) {
          // Don't navigate if the user is typing in the persistent toc search box
          return false;
        } else {
          let charCode = event.keyCode || event.which;
          if (charCode == SPACE || charCode == ESC) {
            hideToC(event);
            return false;
          }
          return true;
        }
      };

      let url = window.location.href;
      let hash = "";
      let pos = url.indexOf("#");
      if (pos > 0) {
        hash = url.substring(pos);
        url = url.substring(0,pos);
      }
      
      pos = url.indexOf("?");
      if (pos >= 0) {
        tocPersistCheckbox();
        if (tocPersist) {
          tocPersist.checked = true;
        }
        url = url.substring(0, pos);
      }
      url = url + hash;

      // Remove ?toc from the URI so that if it's bookmarked,
      // the ToC reference isn't part of the bookmark.
      window.history.replaceState({}, document.title, url);

      pos = url.lastIndexOf("/");
      url = url.substring(pos+1);
      let target = document.querySelector("nav.toc div a[href='"+url+"']");
      if (target) {
        target.scrollIntoView();
      } else {
        // Maybe it's just a link in this page?
        pos = url.indexOf("#");
        if (pos > 0) {
          let hash = url.substring(pos);
          target = document.querySelector("nav.toc div a[href='"+hash+"']");
          if (target) {
            target.scrollIntoView();
          } else {
            console.log(`No target: ${url} (or ${hash})`);
          }
        }
      }

      if (!searchListener) {
        configureSearch();
        searchListener = true;
      }
    }, 400);

    return false;
  };

  const hideToC = function(event) {
    document.onkeyup = curpress;
    toc.classList.add("slide");
    toc.style.width = "0px";
    toc.style["padding-left"] = "0";
    toc.style["padding-right"] = "0";
    toc.style["border-left"] = "none";

    if (event) {
      event.preventDefault();
    }

    const searchp = toc.querySelector(".ptoc-search");
    if (searchp) {
      const search = searchp.querySelector("input");
      if (search) {
        search.value = "";
      }
    }
    toc.querySelectorAll("li").forEach(function (li) {
      li.style.display = "list-item";
    });

    return false;
  };

  const tocPersistCheckbox = function() {
    if (tocPersist != null) {
      return;
    }

    let ptoc = toc.querySelector("p.ptoc-search");
    let sbox = ptoc.querySelector("input.ptoc-search");
    if (sbox) {
      sbox.setAttribute("title", "Simple text search in ToC");
      let pcheck = document.createElement("input");
      pcheck.classList.add("persist");
      pcheck.setAttribute("type", "checkbox");
      pcheck.setAttribute("title", "Keep ToC open when following links");
      pcheck.checked = (window.location.href.indexOf("?toc") >= 0);
      ptoc.appendChild(pcheck);
    }

    tocPersist = toc.querySelector("p.ptoc-search .persist");
  };

  const patchLink = function(event, anchor) {
    if (!tocPersist || !tocPersist.checked) {
      return false;
    }

    let href = anchor.getAttribute("href");
    let pos = href.indexOf("#");

    if (pos === 0) {
      // If the anchor is a same-document reference, we don't
      // need to do any of this query string business.
      return false;
    }

    if (pos > 0) {
      href = href.substring(0, pos) + "?toc" + href.substring(pos);
    } else {
      href = href + "?toc";
    }

    event = event || window.event;
    if (event) {
      event.preventDefault();
    }
    window.location.href = href;
    return false;
  };

  const configureSearch = function() {
    const searchp = toc.querySelector(".ptoc-search");
    if (searchp == null) {
      return;
    }
    const search = searchp.querySelector("input");
    search.onkeyup = function (event) {
      event = event || window.event;
      if (event) {
        event.preventDefault();
      }
      let charCode = event.keyCode || event.which;
      if (charCode == ESC) {
        hideToC(event);
        return false;
      }

      const value = search.value.toLowerCase().trim();
      let restr = value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(" ", ".*");
      const regex = RegExp(restr);

      toc.querySelectorAll("li").forEach(function (li) {
        const link = li.querySelector("a");
        if (restr === "") {
          li.style.display = "list-item";
          link.classList.remove("found");
        } else {
          if (li.textContent.toLowerCase().match(regex)) {
            li.style.display = "list-item";
            if (link.textContent.toLowerCase().match(regex)) {
              link.classList.add("found");
            } else {
              link.classList.remove("found");
            }
          } else {
            li.style.display = "none";
          }
        }
      });

      return false;
    };
  };

  // Setting the border-left-style in CSS will put a thin border-colored
  // stripe down the right hand side of the window. Here we get the color
  // of that stripe and then remove it. We'll put it back when we
  // expand the ToC.
  borderLeftColor = window.getComputedStyle(toc)["border-left-color"];
  toc.style["border-left"] = "none";

  const tocOpenScript = document.querySelector("script.tocopen");
  const tocOpen = document.querySelector("nav.tocopen");
  tocOpen.innerHTML = tocOpenScript.innerHTML;
  tocOpen.onclick = showToC;

  const tocScript = document.querySelector("script.toc");
  toc.innerHTML = tocScript.innerHTML;

  tocOpen.style.display = "inline";

  document.querySelectorAll("nav.toc div a").forEach(function (anchor) {
    anchor.onclick = function(event) {
      if (!tocPersist || !tocPersist.checked) {
        hideToC();
      }
      patchLink(event, anchor);
    };
  });

  let tocJump = false;
  let pos = window.location.href.indexOf("?");
  if (pos >= 0) { // How could it be zero?
    let query = window.location.href.substring(pos+1);
    pos = query.indexOf("#");
    if (pos >= 0) {
      query = query.substring(0, pos);
    }
    query.split("&").forEach(function(item) {
      tocJump = tocJump || (item === "toc" || item === "toc=1" || item === "toc=true");
    });
  }

  if (tocJump) {
    showToC(null);
  } else {
    // If we're not going to jump immediately to the ToC,
    // add the slide class for aesthetics if the user clicks
    // on it.
    toc.classList.add("slide");
  }
})();
