import { h } from "vue";
import { useRoute } from "vitepress";
import DefaultTheme from "vitepress/theme";
import "virtual:uno.css";
import "./global.css";

import { inject } from "@vercel/analytics";
import CloudSearch from "../../components/CloudSearch.vue";

/** @type {import('vitepress').Theme} */
export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    inject();
  },
  Layout() {
    const route = useRoute();
    const isHome = () => route.path === "/";
    const isDoc = () => /^\/docs/.test(route.path);
    const show = isHome() || isDoc();

    return h(DefaultTheme.Layout, null, {
      "nav-bar-content-before": () => (show ? h(CloudSearch) : null),
    });
  },
};
