const encode = (str) => {
  if (!str) {
    return undefined;
  }

  try {
    const result = decodeURI(str);

    if (result !== str) {
      return result;
    }
  } catch {
    return str;
  }

  return encodeURI(str);
};

const parseURL = (url) => {
  try {
    const { pathname, search } = new URL(url);
    url = pathname + search;
  } catch {
    /* empty */
  }

  return url.split("?")[0];
};

((window) => {
  const { location, document, history } = window;
  const { hostname, href } = location;
  const { currentScript, referrer } = document;

  if (!currentScript) {
    return;
  }

  const attr = currentScript.getAttribute.bind(currentScript);
  const websiteID = attr("data-website-id");
  const endpoint =
    attr("data-endpoint") || "https://getcanary.dev/api/v1/analytics";

  let currentUrl = parseURL(href);
  let currentRef = referrer;
  let title = document.title;
  let initialized = false;

  const handlePathChanges = () => {
    const hook = (_this, method, callback) => {
      const orig = _this[method];

      return (...args) => {
        callback.apply(null, args);

        return orig.apply(_this, args);
      };
    };

    const handlePush = (state, title, url) => {
      if (!url) return;

      currentRef = currentUrl;
      currentUrl = parseURL(url.toString());

      if (currentUrl !== currentRef) {
        setTimeout(track, 100);
      }
    };

    history.pushState = hook(history, "pushState", handlePush);
    history.replaceState = hook(history, "replaceState", handlePush);
  };

  const handleTitleChanges = () => {
    const observer = new MutationObserver(([entry]) => {
      title = entry && entry.target ? entry.target.text : undefined;
    });

    const node = document.querySelector("head > title");

    if (node) {
      observer.observe(node, {
        subtree: true,
        characterData: true,
        childList: true,
      });
    }
  };

  const send = async () => {
    const payload = {
      website: websiteID,
      hostname,
      title: encode(title),
      url: encode(currentUrl),
      referrer: encode(currentRef),
    };

    try {
      return fetch(endpoint, {
        method: "POST",
        body: JSON.stringify({ type: "pageview", payload }),
        headers: { "Content-Type": "application/json" },
      });
    } catch {
      /* empty */
    }
  };

  const init = () => {
    if (document.readyState === "complete" && !initialized) {
      initialized = true;
      setTimeout(send, 100);
    }
  };

  handlePathChanges();
  handleTitleChanges();

  document.addEventListener("readystatechange", init, true);
  init();
})(window);
