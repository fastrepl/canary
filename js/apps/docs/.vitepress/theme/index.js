import { h } from "vue";
// import { useRoute } from "vitepress";
import DefaultTheme from "vitepress/theme";
import "./tailwind.css";

import { inject } from "@vercel/analytics";
import CloudSearch from "../../components/CloudSearch.vue";
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
      "nav-bar-content-before": () => h(CloudSearch),
      "doc-footer-before": () => h(Footer),
    });
  },
};
