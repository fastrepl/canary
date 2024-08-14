// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { getHooks } from "live_svelte";
import * as Components from "../svelte/**/*.svelte";

import { format } from "timeago.js";
import ClipboardJS from "clipboard";

import "@getcanary/web/components/canary-root.js";
import "@getcanary/web/components/canary-provider-cloud.js";
import "@getcanary/web/components/canary-modal.js";
import "@getcanary/web/components/canary-trigger-searchbar.js";
import "@getcanary/web/components/canary-content.js";
import "@getcanary/web/components/canary-search.js";
import "@getcanary/web/components/canary-search-input.js";
import "@getcanary/web/components/canary-search-results.js";
import "@getcanary/web/components/canary-ask.js";
import "@getcanary/web/components/canary-ask-input.js";
import "@getcanary/web/components/canary-ask-results.js";
import "@getcanary/web/components/canary-mode-breadcrumb.js";
import "@getcanary/web/components/canary-search-suggestions.js";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let hooks = {
  ...getHooks(Components),
  LocalTime: {
    mounted() {
      this.fn();
    },
    updated() {
      this.fn();
    },
    fn() {
      let dt = new Date(this.el.textContent);
      this.el.textContent = dt.toLocaleString();
      this.el.classList.remove("invisible");
    },
  },
  TimeAgo: {
    mounted() {
      this.fn();
    },
    updated() {
      this.fn();
    },
    fn() {
      this.el.textContent = format(this.el.textContent, "en_US");
      this.el.classList.remove("invisible");
    },
  },
  Clipboard: {
    mounted() {
      this.clipboard = new ClipboardJS(this.el);
      this.clipboard.on("success", (e) => {
        this.el.textContent = "Copied!";
      });
    },
  },
};
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
