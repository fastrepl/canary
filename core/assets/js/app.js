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

import { createLiveToastHook } from "../../deps/live_toast";

import { getHooks } from "live_svelte";
import * as Components from "../svelte/**/*.svelte";

import { format } from "timeago.js";
import ClipboardJS from "clipboard";
import Chart from "chart.js/auto";
import { parse } from "best-effort-json-parser";

import { codeToHtml } from "shiki";
import {
  transformerNotationHighlight,
  transformerNotationDiff,
} from "@shikijs/transformers";

import * as Sentry from "@sentry/browser";
import Tracker from "@openreplay/tracker";
import { SENTRY_KEY, OPENREPLAY_KEY } from "../config";

if (SENTRY_KEY) {
  Sentry.init({ dsn: SENTRY_KEY });
}

if (OPENREPLAY_KEY) {
  new Tracker({ projectKey: OPENREPLAY_KEY }).start().catch(console.error);
}

import "@getcanary/web/components/canary-root.js";
import "@getcanary/web/components/canary-provider-cloud.js";
import "@getcanary/web/components/canary-modal.js";
import "@getcanary/web/components/canary-trigger-searchbar.js";
import "@getcanary/web/components/canary-content.js";
import "@getcanary/web/components/canary-input.js";
import "@getcanary/web/components/canary-search.js";
import "@getcanary/web/components/canary-search-results.js";
import "@getcanary/web/components/canary-search-match-github-issue.js";
import "@getcanary/web/components/canary-search-match-github-discussion.js";
import "@getcanary/web/components/canary-ask.js";
import "@getcanary/web/components/canary-ask-results.js";
import "@getcanary/web/components/canary-tooltip.js";
import "@getcanary/web/components/canary-footer.js";
import "@getcanary/web/components/canary-filter-tabs-glob.js";
import "@getcanary/web/components/canary-filter-tags.js";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const hooks = {
  ...getHooks(Components),
  LiveToast: createLiveToastHook(),
  Prompt: window.Prompt,
  EnterToSubmit: {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if (e.key == "Enter") {
          e.preventDefault();
          this.el.form.dispatchEvent(
            new Event("submit", { bubbles: true, cancelable: true }),
          );
        }
      });
    },
  },
  HighlightAll: {
    mounted() {
      this.run();
    },
    updated() {
      this.run();
    },
    run() {
      const elements = this.el.querySelectorAll("code");
      for (const element of elements) {
        codeToHtml(element.textContent, {
          lang: "javascript",
          theme: "rose-pine-dawn",
        }).then((html) => {
          element.innerHTML = html;
        });
      }
    },
  },
  Highlight: {
    mounted() {
      this.run();
    },
    updated() {
      this.run();
    },
    run() {
      codeToHtml(this.el.textContent, {
        lang: "html",
        theme: "rose-pine-dawn",
        transformers: [
          transformerNotationHighlight(),
          transformerNotationDiff(),
        ],
      }).then((html) => {
        this.el.innerHTML = html;
        this.el.classList.remove("invisible");
      });
    },
  },
  BarChart: {
    title() {
      return this.el.dataset.title;
    },
    labels() {
      return JSON.parse(this.el.dataset.labels);
    },
    points() {
      return JSON.parse(this.el.dataset.points);
    },
    render() {
      /** @type {Chart} */
      const config = {
        type: "bar",
        data: {
          labels: this.labels(),
          datasets: [
            {
              data: this.points(),
              backgroundColor: "#f4d47c",
              barThickness: 24,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: {
              grid: {
                drawOnChartArea: false,
              },
              ticks: {
                callback(value, index, ticks) {
                  const ticksToShow = Math.min(ticks.length, 20);

                  if (index < ticksToShow) {
                    return this.getLabelForValue(value);
                  }

                  return "";
                },
                autoSkip: false,
              },
            },
            y: {
              beginAtZero: true,
              grid: {
                drawOnChartArea: false,
              },
              ticks: {
                format: {
                  minimumFractionDigits: 0,
                  maximumFractionDigits: 0,
                },
              },
            },
          },
          plugins: {
            tooltip: {
              enabled: true,
            },
            legend: {
              display: false,
            },
            title: {
              display: !!this.title(),
              text: this.title(),
            },
          },
        },
      };

      new Chart(this.el, config);
    },
    mounted() {
      this.render();
    },
    updated() {
      const existing = Chart.getChart(this.el);
      if (existing) {
        existing.update();
      } else {
        this.render();
      }
    },
  },
  LocalTime: {
    mounted() {
      this.fn();
    },
    updated() {
      this.fn();
    },
    fn() {
      const dt = new Date(this.el.textContent);
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
  PartialJSON: {
    mounted() {
      this.fn();
    },
    updated() {
      this.fn();
    },
    fn() {
      const parsed = parse(this.el.textContent);
      this.el.textContent = JSON.stringify(parsed, null, 2);
    },
  },
};

const liveSocket = new LiveSocket("/live", Socket, {
  hooks,
  params: {
    _csrf_token: csrfToken,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  },
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
