import { h } from "vue";
// import { useRoute } from "vitepress";
import DefaultTheme from "vitepress/theme";
import "./tailwind.css";

import { inject } from "@vercel/analytics";
// import Search from "../../components/CloudSearch.vue";
import Footer from "../../components/Footer.vue";

/** @type {import('vitepress').Theme} */
export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    inject();
  },
  Layout() {
    // const route = useRoute();
    // const isDoc = () => /^\/docs/.test(route.path);

    return h(DefaultTheme.Layout, null, {
      // "nav-bar-content-before": () => (showSearch() ? h(Search) : null),
      "doc-footer-before": () => h(Footer),
    });
  },
};
