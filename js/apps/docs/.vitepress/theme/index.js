import { h } from "vue";
import DefaultTheme from "vitepress/theme";
import "./tailwind.css";

import { inject } from "@vercel/analytics";
import Search from "../../components/Search.vue";

/** @type {import('vitepress').Theme} */
export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    inject();
  },
  Layout() {
    return h(DefaultTheme.Layout, null, {
      "nav-bar-content-before": () => h(Search),
    });
  },
};
